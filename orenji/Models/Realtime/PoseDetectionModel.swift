//
//  PoseDetectionModel.swift
//  orenji
//
//  Created by Muhamad Fannan Najma Falahi on 03/07/25.
//

import SwiftUI
import Vision

struct PoseDetectionModel {
    let isUserInFrame: Bool
    let jointPoints: [PoseJoint]
    let recognizedPoints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
}

struct PoseJoint: Identifiable {
    let id = UUID()
    let position: CGPoint
    let inFrame: Bool
}
