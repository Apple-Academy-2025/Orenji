import SwiftUI
import Vision

struct PoseOverlayView: View {
    let points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    let evaluationColor: Color
    let isRightHand: Bool  // ✅ Tambahkan ini

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
                // Garis antar joint
                ForEach(Array(jointPairs.enumerated()), id: \.offset) { _, pair in
                    let jointA = pair.0
                    let jointB = pair.1
                    
                    if let pointA = points[jointA],
                       let pointB = points[jointB],
                       pointA.confidence > 0.1,
                       pointB.confidence > 0.1 {
                        
                        Path { path in
                            let rotatedX1 = 1 - pointA.location.y
                            let rotatedY1 = pointA.location.x
                            let rotatedX2 = 1 - pointB.location.y
                            let rotatedY2 = pointB.location.x
                            
                            path.move(to: CGPoint(x: rotatedX1 * geometry.size.width, y: rotatedY1 * geometry.size.height))
                            path.addLine(to: CGPoint(x: rotatedX2 * geometry.size.width, y: rotatedY2 * geometry.size.height))
                        }
                        .stroke(evaluationColor, lineWidth: 2)
                    }
                }
                
                // Titik semua joint
                ForEach(points.keys.sorted(by: { $0.rawValue.rawValue < $1.rawValue.rawValue }), id: \.self) { key in
                    if let point = points[key], point.confidence > 0.1 {
                        let rotatedX = 1 - point.location.y
                        let rotatedY = point.location.x
                        
                        Circle()
                            .fill(Color.blue.opacity(0.7))
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
