//
//  SkeletonPreview.swift
//  RecordFeature
//
//  Created by Fariz Ajy Putra on 21/06/25.
//

import SwiftUI
import AVKit
import CoreML
import Vision


struct SkeletonPreview: View {
    let image: UIImage
    let joints: [VNHumanBodyPoseObservation.JointName: CGPoint]?
    var skeletonSize: CGFloat

    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: skeletonSize, height: skeletonSize)
                .cornerRadius(18)
            if let joints = joints, !joints.isEmpty {
                JointOverlayComponent(
                    joints: joints,
                    imageSize: CGSize(width: skeletonSize, height: skeletonSize)
                )
            }
        }
        .frame(width: skeletonSize, height: skeletonSize)
    }
}

