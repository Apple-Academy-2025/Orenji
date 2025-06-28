import Foundation
import Vision
import AVFoundation
import UIKit
import SwiftUI

class PoseDetectionViewModel: ObservableObject {
    @Published var isUserInFrame: Bool = false
    @Published var jointPoints: [PoseJoint] = []
    @Published var recognizedPoints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint] = [:]
    
    @Published var holdProgress: CGFloat = 0
    @Published var isHoldingPose: Bool = false
    @Published var holdCompleted: Bool = false
    @Published var isEvaluatingPose: Bool = false
    
    @Published var elbowAngleNow: Int = 0
    @Published var legAngleNow: Int = 0
    @Published var isPoseCorrect: Bool = false
    
    private var sequenceHandler = VNSequenceRequestHandler()
    private var holdTimer: Timer? = nil
    private var holdTime: CGFloat = 0
    var overlayFrame: CGRect = .zero
    private var audioPlayer: AVAudioPlayer?
    
    struct PoseJoint: Identifiable {
        let id = UUID()
        let position: CGPoint
        let inFrame: Bool
    }
    
    // MARK: - Main Detection
    func processBuffer(_ buffer: CVPixelBuffer) {
        let request = VNDetectHumanBodyPoseRequest { [weak self] req, err in
            guard let self else { return }
            
            guard let observations = req.results as? [VNHumanBodyPoseObservation],
                  let person = observations.first,
                  let recognizedPoints = try? person.recognizedPoints(.all) else {
                DispatchQueue.main.async {
                    self.isUserInFrame = false
                    self.jointPoints = []
                    self.recognizedPoints = [:]
                }
                return
            }
            
            let importantJoints: [VNHumanBodyPoseObservation.JointName] = [
                .rightWrist, .rightShoulder
            ]
            
            let screen = UIScreen.main.bounds
            var detected: [PoseJoint] = []
            
            let allInside = importantJoints.allSatisfy { joint in
                guard let point = recognizedPoints[joint], point.confidence > 0.3 else { return false }
                let mirroredX = 1 - point.x
                let converted = CGPoint(
                    x: mirroredX * screen.width,
                    y: (1 - point.y) * screen.height
                )
                let inside = self.overlayFrame.contains(converted)
                detected.append(PoseJoint(position: converted, inFrame: inside))
                return inside
            }
            
            DispatchQueue.main.async {
                self.isUserInFrame = allInside
                self.jointPoints = detected
                self.recognizedPoints = recognizedPoints
            }
        }
        
        try? sequenceHandler.perform([request], on: buffer)
    }
    
    // MARK: - Holding Logic
    func startHoldPose() {
        guard !isEvaluatingPose else { return }
        isEvaluatingPose = true
        holdTimer?.invalidate()
        holdTime = 0
        holdProgress = 0
        holdCompleted = false
        isHoldingPose = true
        
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            self.updatePoseCorrectness(for: EvaluateRealtimeView.currentGlobalPhase)
            
            if self.isPoseCorrect {
                self.holdTime += 0.1
                self.holdProgress = min(self.holdTime / 3.0, 1.0)
                
                if self.holdTime >= 3.0 {
                    timer.invalidate()
                    self.holdCompleted = true
                    self.isHoldingPose = false
                    self.isEvaluatingPose = false
                    self.playSuccessFeedback(withMessage: "Great! You nailed it.")
                }
            } else {
                self.holdTime = 0
                self.holdProgress = 0
            }
        }
    }
    
    func playSuccessFeedback(withMessage message: String) {
//        DispatchQueue.main.async {
//            NotificationCenter.default.post(name: .speakFromViewModel, object: message)
//        }
        
        guard let url = Bundle.main.url(forResource: "soundbel", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("❌ Failed to play bell: \(error)")
        }
    }
    
    func updatePoseCorrectness(for phase: EvaluateRealtimeView.Phase) {
        let useLeft = UserDefaults.standard.string(forKey: "shootingHand") == "Left"
        
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
              ankle.confidence > 0.3
        else {
            isPoseCorrect = false
            return
        }
        
        let elbowAngle = calculateAngle(a: shoulder.location, b: elbow.location, c: wrist.location)
        let legAngle = calculateAngle(a: hip.location, b: knee.location, c: ankle.location)
        
        DispatchQueue.main.async {
            self.elbowAngleNow = Int(elbowAngle)
            self.legAngleNow = Int(legAngle)
            
            switch phase {
            case .checkPhase1:
                self.isPoseCorrect = abs(elbowAngle - 90) < 5
            case .checkPhase2:
                self.isPoseCorrect = abs(legAngle - 75) < 5
            case .checkPhase3:
                let elbowOK = abs(elbowAngle - 170) < 10
                let legOK = legAngle > 150
                self.isPoseCorrect = elbowOK && legOK
            default:
                self.isPoseCorrect = false
            }
            
            print("📌 [\(phase)] elbow: \(Int(elbowAngle)), leg: \(Int(legAngle)), correct: \(self.isPoseCorrect)")
        }
    }
    
    
    
    //    func updatePoseCorrectness(for phase: EvaluateRealtimeView.Phase) {
    //        switch phase {
    //        case .checkPhase1:
    //            let elbowOK = abs(elbowAngleNow - 120) < 5
    //            let legOK = (150...165).contains(CGFloat(legAngleNow))
    //            isPoseCorrect = elbowOK && legOK
    //
    //        case .checkPhase2:
    //            let legOK = abs(legAngleNow - 75) < 5
    //            let elbowOK = abs(elbowAngleNow - 85) < 5
    ////            let elbowOK = (45...90).contains(CGFloat(elbowAngleNow))
    //            isPoseCorrect = legOK && elbowOK
    //
    //        case .checkPhase3:
    //            let elbowOK = abs(elbowAngleNow - 170) < 5
    //            let legOK = (160...170).contains(CGFloat(legAngleNow))
    //            isPoseCorrect = elbowOK && legOK
    //
    //        default:
    //            isPoseCorrect = false
    //        }
    //    }
    
    func cancelHold() {
        holdTimer?.invalidate()
        holdProgress = 0
        holdTime = 0
        isHoldingPose = false
        holdCompleted = false
    }
    
    // MARK: - Pose Phase Detection
    enum ShootingPhase {
        case preparation, bending, release, unknown
    }
    
    func currentPhaseType() -> ShootingPhase {
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
            return .unknown
        }
        
        let legAngle = calculateAngle(a: rightHip.location, b: rightKnee.location, c: rightAnkle.location)
        let elbowAngle = calculateAngle(a: rightShoulder.location, b: rightElbow.location, c: rightWrist.location)
        
        DispatchQueue.main.async {
            self.legAngleNow = Int(legAngle)
            self.elbowAngleNow = Int(elbowAngle)
        }
        
        print("🔍 Leg Angle: \(Int(legAngle))°, Elbow Angle: \(Int(elbowAngle))°")
        
        if (150...165).contains(legAngle) && (115...125).contains(elbowAngle) {
            return .preparation
        } else if (70...80).contains(legAngle) && (45...55).contains(elbowAngle) {
            return .bending
        } else if (160...170).contains(legAngle) && (165...175).contains(elbowAngle) {
            return .release
        } else {
            return .unknown
        }
    }
    
    // MARK: - Angle Calculation
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
}
