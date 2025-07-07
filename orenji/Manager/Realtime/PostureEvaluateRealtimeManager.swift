//
//  PostureEvaluateRealtimeManager.swift
//  orenji
//
//  Created by Muhamad Fannan Najma Falahi on 02/07/25.
//

import SwiftUI
import Vision
import AVFAudio

class PostureEvaluateRealtimeManager {
    private var holdTimer: Timer?
    private var holdTime: CGFloat = 0
    private let holdDuration: CGFloat = 3.0
    var updatePoseCorrectness: ((Phase) -> Void)?
    
    private var isPoseCorrect: Bool = false
    private var isEvaluating = false
    private let sequenceHandler = VNSequenceRequestHandler()
    private var audioPlayer: AVAudioPlayer?
    
    func detectPose(in buffer: CVPixelBuffer, overlayFrame: CGRect, completion: @escaping (PoseDetectionModel) -> Void) {
        let request = VNDetectHumanBodyPoseRequest { req, err in
            guard let observations = req.results as? [VNHumanBodyPoseObservation],
                  let person = observations.first,
                  let recognizedPoints = try? person.recognizedPoints(.all) else {
                completion(PoseDetectionModel(isUserInFrame: false, jointPoints: [], recognizedPoints: [:]))
                return
            }
            
            let importantJoints: [VNHumanBodyPoseObservation.JointName] = [.rightWrist, .rightShoulder]
            let screen = UIScreen.main.bounds
            var detected: [PoseJoint] = []
            
            let allInside = importantJoints.allSatisfy { joint in
                guard let point = recognizedPoints[joint], point.confidence > 0.3 else { return false }
                let mirroredX = 1 - point.x
                let converted = CGPoint(
                    x: mirroredX * screen.width,
                    y: (1 - point.y) * screen.height
                )
                let inside = overlayFrame.contains(converted)
                detected.append(PoseJoint(position: converted, inFrame: inside))
                return inside
            }
            completion(PoseDetectionModel(isUserInFrame: allInside, jointPoints: detected, recognizedPoints: recognizedPoints))
        }
        try? sequenceHandler.perform([request], on: buffer)
    }
    
    func calculateAngle(a: CGPoint, b: CGPoint, c: CGPoint) -> CGFloat {
        let ab = CGVector(dx: a.x - b.x, dy: a.y - b.y)
        let cb = CGVector(dx: c.x - b.x, dy: c.y - b.y)
        let dot = ab.dx * cb.dx + ab.dy * cb.dy
        let magnitudeAB = sqrt(ab.dx * ab.dx + ab.dy * ab.dy)
        let magnitudeCB = sqrt(cb.dx * cb.dx + cb.dy * cb.dy)
        let cosineAngle = dot / (magnitudeAB * magnitudeCB)
        let angle = acos(cosineAngle) * 180 / .pi
        return angle
    }
    
    func evaluatePoseCorrectness(
        from recognizedPoints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint],
        phase: Phase,
        useLeft: Bool
    ) -> (isCorrect: Bool, elbow: Int, leg: Int) {
        
        guard let shoulder = recognizedPoints[useLeft ? .leftShoulder : .rightShoulder],
              let elbow = recognizedPoints[useLeft ? .leftElbow : .rightElbow],
              let wrist = recognizedPoints[useLeft ? .leftWrist : .rightWrist],
              let hip = recognizedPoints[useLeft ? .leftHip : .rightHip],
              let knee = recognizedPoints[useLeft ? .leftKnee : .rightKnee],
              let ankle = recognizedPoints[useLeft ? .leftAnkle : .rightAnkle],
              shoulder.confidence > 0.3,
              elbow.confidence > 0.3,
              wrist.confidence > 0.3,
              hip.confidence > 0.3,
              knee.confidence > 0.3,
              ankle.confidence > 0.3 else {
            return (false, 0, 0)
        }
        
        let elbowAngle = calculateAngle(a: shoulder.location, b: elbow.location, c: wrist.location)
        let legAngle = calculateAngle(a: hip.location, b: knee.location, c: ankle.location)
        
        let isCorrect: Bool
        switch phase {
        case .checkPhase1:
            isCorrect = abs(elbowAngle - 90) < 5
        case .checkPhase2:
            isCorrect = abs(legAngle - 75) < 5
        case .checkPhase3:
            isCorrect = abs(elbowAngle - 180) < 5
        default:
            isCorrect = false
        }
        
        return (isCorrect, Int(elbowAngle), Int(legAngle))
    }
    
    func playSuccessFeedback(withMessage message: String) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .speakFromViewModel, object: message)
        }
        
        guard let url = Bundle.main.url(forResource: "soundbel", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("❌ Failed to play bell: \(error)")
        }
    }
    
    func currentPhaseType(from recognizedPoints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) -> ShootingPhase {
        guard let rightHip = recognizedPoints[.rightHip],
              let rightKnee = recognizedPoints[.rightKnee],
              let rightAnkle = recognizedPoints[.rightAnkle],
              let rightShoulder = recognizedPoints[.rightShoulder],
              let rightElbow = recognizedPoints[.rightElbow],
              let rightWrist = recognizedPoints[.rightWrist],
              rightHip.confidence > 0.3,
              rightKnee.confidence > 0.3,
              rightAnkle.confidence > 0.3,
              rightShoulder.confidence > 0.3,
              rightElbow.confidence > 0.3,
              rightWrist.confidence > 0.3 else {
            return (.unknown)
        }
        
        let legAngle = calculateAngle(a: rightHip.location, b: rightKnee.location, c: rightAnkle.location)
        let elbowAngle = calculateAngle(a: rightShoulder.location, b: rightElbow.location, c: rightWrist.location)
        
        if (150...165).contains(legAngle) && (115...125).contains(elbowAngle) {
            return .preparation
        } else if (70...80).contains(legAngle) && (45...55).contains(elbowAngle) {
            return .bending
        } else if (160...170).contains(legAngle) && (120...180).contains(elbowAngle) {
            return .release
        } else {
            return .unknown
        }
    }
    
    func startHoldPose(
        phase: Phase,
        update: @escaping (_ progress: CGFloat, _ isCorrect: Bool) -> Void,
        checkCorrectness: @escaping () -> Bool,
        completion: @escaping () -> Void
    ) {
        holdTimer?.invalidate()
        holdTime = 0
        
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.updatePoseCorrectness?(phase)
            let isCorrect = checkCorrectness()
            
            if isCorrect {
                self.holdTime += 0.1
                let progress = min(self.holdTime / 3.0, 1.0)
                update(progress, true)
                
                if self.holdTime >= 3.0 {
                    timer.invalidate()
                    completion()
                }
            } else {
                self.holdTime = 0
                update(0, false)
            }
        }
        RunLoop.main.add(holdTimer!, forMode: .common)
    }
    
    func cancelHold() {
        holdTimer?.invalidate()
        holdTime = 0
    }
}
