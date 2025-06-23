// PoseDetectionViewModel.swift
import Foundation
import Vision
import AVFoundation
import UIKit

class PoseDetectionViewModel: ObservableObject {
    @Published var isUserInFrame: Bool = false
    @Published var jointPoints: [PoseJoint] = []
    @Published var recognizedPoints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint] = [:]

    private var sequenceHandler = VNSequenceRequestHandler()
    var overlayFrame: CGRect = .zero

    struct PoseJoint: Identifiable {
        let id = UUID()
        let position: CGPoint
        let inFrame: Bool
    }

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
//                .leftWrist, .rightWrist,
//                .leftElbow, .rightElbow,
//                .leftKnee, .rightKnee,
//                .leftAnkle, .rightAnkle
                
                .rightWrist, .rightElbow, .rightKnee ,.rightAnkle
            ]

            let screen = UIScreen.main.bounds
            var detected: [PoseJoint] = []

            let allInside = importantJoints.allSatisfy { joint in
                guard let point = recognizedPoints[joint], point.confidence > 0.3 else {
                    return false
                }

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
}
