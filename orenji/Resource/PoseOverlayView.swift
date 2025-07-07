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

    func pointInView(_ point: CGPoint, in size: CGSize) -> CGPoint {
        CGPoint(x: point.x * size.width, y: (1 - point.y) * size.height)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(jointPairs.enumerated().map { index, pair in
                    (id: "\(pair.0.rawValue)-\(pair.1.rawValue)", pair: pair)
                }, id: \.id) { item in
                    let pair = item.pair
                    if let pointA = points[pair.0], let pointB = points[pair.1] {
                        let minConfidence = min(pointA.confidence, pointB.confidence)
                        let color = evaluationColors[pair.0] ?? .blue
                        let lineWidth: CGFloat = minConfidence > 0.3 ? 3 : 1.5
                        let lineStyle: StrokeStyle = minConfidence > 0.3
                            ? StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                            : StrokeStyle(lineWidth: lineWidth, lineCap: .round, dash: [5, 5])

                        Path { path in
                            path.move(to: pointInView(pointA.location, in: geometry.size))
                            path.addLine(to: pointInView(pointB.location, in: geometry.size))
                        }
                        .stroke(color, style: lineStyle)
                        .animation(.easeInOut(duration: 0.2), value: points)
                    } else {
                        EmptyView()
                    }
                }

                let uniqueJoints = Set(jointPairs.flatMap { [$0.0, $0.1] })
                ForEach(Array(uniqueJoints).map { joint in
                    (id: joint.rawValue, joint: joint)
                }, id: \.id) { item in
                    let joint = item.joint
                    if let point = points[joint], point.confidence > 0.1 {
                        let position = pointInView(point.location, in: geometry.size)
                        let color = evaluationColors[joint] ?? .blue

                        Circle()
                            .fill(color)
                            .frame(width: 12, height: 12)
                            .position(position)
                            .shadow(color: color.opacity(0.8), radius: 8, x: 0, y: 0)
                            .animation(.easeInOut(duration: 0.3), value: points)
                    } else {
                        EmptyView()
                    }
                }
            }
        }
        .drawingGroup()
    }
}
