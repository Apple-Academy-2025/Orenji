// PoseOverlayView.swift
import SwiftUI
import Vision

struct PoseOverlayView: View {
    let points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    let evaluationColors: [VNHumanBodyPoseObservation.JointName: Color]
    let isRightHand: Bool

    var jointPairs: [(VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName)] {
        if isRightHand {
            return [
                (.rightShoulder, .rightElbow),
                (.rightElbow, .rightWrist),
                (.rightShoulder, .rightHip),
                (.rightHip, .rightKnee),
                (.rightKnee, .rightAnkle)
            ]
        } else {
            return [
                (.leftShoulder, .leftElbow),
                (.leftElbow, .leftWrist),
                (.leftShoulder, .leftHip),
                (.leftHip, .leftKnee),
                (.leftKnee, .leftAnkle)
            ]
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Garis antar joint dengan warna evaluasi
                ForEach(Array(jointPairs.enumerated()), id: \.offset) { _, pair in
                    let jointA = pair.0
                    let jointB = pair.1
                    if let pointA = points[jointA], let pointB = points[jointB],
                       pointA.confidence > 0.1, pointB.confidence > 0.1 {

                        let color = evaluationColors[jointA] ?? .primer

                        Path { path in
                            let x1 = (1 - pointA.location.y) * geometry.size.width
                            let y1 = pointA.location.x * geometry.size.height
                            let x2 = (1 - pointB.location.y) * geometry.size.width
                            let y2 = pointB.location.x * geometry.size.height
                            path.move(to: CGPoint(x: x1, y: y1))
                            path.addLine(to: CGPoint(x: x2, y: y2))
                        }
                        .stroke(color, lineWidth: 3)
                    }
                }

                // Titik semua joint
                ForEach(Array(jointPairs.enumerated()), id: \.offset) { _, pair in
                    let jointA = pair.0
                    let jointB = pair.1
                    
                    // Draw joint A if it has sufficient confidence
                    if let pointA = points[jointA], pointA.confidence > 0.1 {
                        let rotatedX = 1 - pointA.location.y
                        let rotatedY = pointA.location.x
                        
                        let color = evaluationColors[jointA] ?? .primer
                        
                        Circle()
                            .fill(color)
                            .frame(width: 10, height: 10)
                            .position(
                                x: rotatedX * geometry.size.width,
                                y: rotatedY * geometry.size.height
                            )
                    }
                    
                    // Draw joint B if it has sufficient confidence
                    if let pointB = points[jointB], pointB.confidence > 0.1 {
                        let rotatedX = 1 - pointB.location.y
                        let rotatedY = pointB.location.x
                        
                        let color = evaluationColors[jointB] ?? .primer
                        
                        Circle()
                            .fill(color)
                            .frame(width: 10, height: 10)
                            .position(
                                x: rotatedX * geometry.size.width,
                                y: rotatedY * geometry.size.height
                            )
                    }
                }
            }
        }
    }
}
