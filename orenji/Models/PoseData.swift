//
//  ModelData.swift
//  RecordFeature
//
//  Created by Fariz Ajy Putra on 21/06/25.
//

import SwiftUI
import Vision
import SwiftData

struct FramePrediction {
    var imageForDisplay : UIImage?
    let imageForMLProcess: UIImage
    let imageTime: Double
    let label: String
    let joints: [VNHumanBodyPoseObservation.JointName: CGPoint]?
    let detectedDominant: String?
    let elbowAngle: CGFloat?
    let kneeAngle: CGFloat?
    let date: Date?
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

@Model
class PhaseData {
    var uuid = UUID()
    var frames: [FrameData] = [] // Ganti nama lebih jelas!
    var date: Date?
    
    init(uuid: UUID = UUID(), frames: [FrameData], date: Date? = nil) {
        self.uuid = uuid
        self.frames = frames
        self.date = date
    }
}


@Model
class FrameData {
    var uuid = UUID()
    var imageForDisplay: Data?
    var label: String?
    var detectedDominant: String?
    var elbowAngle: Double?
    var kneeAngle: Double?
    var improvement: [String?]
    
    init(
        imageForDisplay: UIImage? = nil,
        label: String,
        detectedDominant: String? = nil,
        elbowAngle: Double? = nil,
        kneeAngle: Double? = nil,
        improvement: [String?] = [nil]
    ) {
        if let img = imageForDisplay {
            self.imageForDisplay = img.jpegData(compressionQuality: 1.0)
        }
        self.label = label
        self.detectedDominant = detectedDominant
        self.elbowAngle = elbowAngle
        self.kneeAngle = kneeAngle
        self.improvement = improvement
    }
}


