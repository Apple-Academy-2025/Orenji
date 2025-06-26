import Foundation
import Vision
import AVFoundation
import UIKit
import SwiftUI

class PoseDetectionViewModel: ObservableObject {
    @Published var isUserInFrame: Bool = false
    @Published var jointPoints: [PoseJoint] = []
    @StateObject var connectivity =  WatchConnectivityManager.shared
    @Published var recognizedPoints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint] = [:]

    @Published var holdProgress: CGFloat = 0       // Progress fill hijau
    @Published var isHoldingPose: Bool = false     // true saat proses hold aktif
    @Published var holdCompleted: Bool = false     // true jika sukses hold 3 detik

    @Published var legAngleNow: Int = 0
    @Published var elbowAngleNow: Int = 0

    private var sequenceHandler = VNSequenceRequestHandler()
    private var holdTimer: Timer? = nil
    private var holdTime: CGFloat = 0

    var overlayFrame: CGRect = .zero

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
        holdTimer?.invalidate()
        holdTime = 0
        holdProgress = 0
        holdCompleted = false
        isHoldingPose = true

        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] t in
            guard let self = self else { return }

            let currentPhase = self.currentPhaseType()

            if self.isCorrectPoseForCurrentPhase(currentPhase) {
                self.holdTime += 0.1
                self.holdProgress = min(self.holdTime / 3.0, 1.0)

                if self.holdTime >= 3.0 {
                    t.invalidate()
                    self.holdCompleted = true
                    self.isHoldingPose = false
                    print("✅ Pose '\(currentPhase)' sukses ditahan 3 detik")
                }
            } else {
                self.holdTime = 0
                self.holdProgress = 0
                print("🔁 Gagal tahan pose, ulangi dari awal")
            }
        }
    }

    func isCorrectPoseForCurrentPhase(_ current: ShootingPhase) -> Bool {
        switch current {
        case .preparation: return EvaluateRealtimeView.currentGlobalPhase == .checkPhase1
        case .bending: return EvaluateRealtimeView.currentGlobalPhase == .checkPhase2
        case .release: return EvaluateRealtimeView.currentGlobalPhase == .checkPhase3
        default: return false
        }
    }

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

        if (140...165).contains(legAngle) && (80...125).contains(elbowAngle) {
            return .preparation
        } else if (70...150).contains(legAngle) && (65...120).contains(elbowAngle) {
            return .bending
        } else if (145...170).contains(legAngle) && (165...190).contains(elbowAngle) {
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
