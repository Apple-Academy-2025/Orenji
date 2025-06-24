import Foundation
import Vision
import AVFoundation
import UIKit
import SwiftUI

class PoseDetectionViewModel: ObservableObject {
    @Published var isUserInFrame: Bool = false
    @Published var jointPoints: [PoseJoint] = []
    @Published var recognizedPoints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint] = [:]

    @Published var holdProgress: CGFloat = 0       // 🔁 untuk fill hijau
    @Published var isHoldingPose: Bool = false     // true saat proses hold aktif
    @Published var holdCompleted: Bool = false     // true jika sukses hold 3 detik

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

        // Timer update per 0.1 detik
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] t in
            guard let self = self else { return }

            if self.isRightHandRaised() {
                self.holdTime += 0.1
                self.holdProgress = min(self.holdTime / 3.0, 1.0)

                if self.holdTime >= 3.0 {
                    t.invalidate()
                    self.holdCompleted = true
                    self.isHoldingPose = false
                    print("✅ Pose sukses ditahan 3 detik")
                }
            } else {
                // Reset jika gagal
                self.holdTime = 0
                self.holdProgress = 0
                print("🔁 Gagal tahan pose, ulangi dari awal")
            }
        }
    }

    func cancelHold() {
        holdTimer?.invalidate()
        holdProgress = 0
        holdTime = 0
        isHoldingPose = false
        holdCompleted = false
    }

    // MARK: - Pose Check

    func isRightHandRaised() -> Bool {
        guard let wrist = recognizedPoints[.rightWrist],
              let shoulder = recognizedPoints[.rightShoulder],
              wrist.confidence > 0.4,
              shoulder.confidence > 0.4 else {
            return false
        }

        let deltaY = shoulder.y - wrist.y
        return deltaY > 0.05 // makin besar makin ketat
    }

}
