//
//  ModelData.swift
//  RecordFeature
//
//  Created by Fariz Ajy Putra on 21/06/25.
//

import SwiftUI
import Vision

struct FramePrediction {
    var imageForDisplay : UIImage?
    let imageForMLProcess: UIImage
    let imageTime: Double
    let label: String
    let joints: [VNHumanBodyPoseObservation.JointName: CGPoint]?
    let detectedDominant: String?
    let elbowAngle: CGFloat?
    let kneeAngle: CGFloat?
}

struct PhaseTarget {
    let name: ShotPhase
    let elbowRange: ClosedRange<CGFloat>
    let kneeValue: CGFloat
}

enum ShotPhase: String, CaseIterable {
    case preparation, bending, followthrough
}

let phaseTargets: [PhaseTarget] = [
    .init(name: .preparation, elbowRange: 86...93, kneeValue: 160),
    .init(name: .bending, elbowRange: 75...90, kneeValue: 124),
    .init(name: .followthrough, elbowRange: 160...170, kneeValue: 160)
]
