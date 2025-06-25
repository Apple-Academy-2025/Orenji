//
//  JointOverlay.swift
//  RecordFeature
//
//  Created by Fariz Ajy Putra on 21/06/25.
//

import SwiftUI
import AVKit
import CoreML
import Vision

struct JointOverlayComponent: View {
    let joints: [VNHumanBodyPoseObservation.JointName: CGPoint]
    let imageSize: CGSize

    var body: some View {
        ZStack {
            if let s = joints[.leftShoulder], let e = joints[.leftElbow], let w = joints[.leftWrist] {
                Path { path in path.move(to: s); path.addLine(to: e); path.addLine(to: w) }
                    .stroke(Color.green, lineWidth: 4)
            }
            if let s = joints[.rightShoulder], let e = joints[.rightElbow], let w = joints[.rightWrist] {
                Path { path in path.move(to: s); path.addLine(to: e); path.addLine(to: w) }
                    .stroke(Color.purple, lineWidth: 4)
            }
            if let h = joints[.leftHip], let k = joints[.leftKnee], let a = joints[.leftAnkle] {
                Path { path in path.move(to: h); path.addLine(to: k); path.addLine(to: a) }
                    .stroke(Color.red, lineWidth: 4)
            }
            if let h = joints[.rightHip], let k = joints[.rightKnee], let a = joints[.rightAnkle] {
                Path { path in path.move(to: h); path.addLine(to: k); path.addLine(to: a) }
                    .stroke(Color.orange, lineWidth: 4)
            }
            // Titik-titik joint (biru)
            ForEach(Array(joints.keys), id: \.self) { key in
                if let point = joints[key] {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 9, height: 9)
                        .position(point)
                }
            }
        }
        .frame(width: imageSize.width, height: imageSize.height)
        .allowsHitTesting(false)
    }
}
