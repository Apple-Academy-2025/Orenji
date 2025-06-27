//
//  MockData.swift
//  orenji
//
//  Created by Muhamad Fannan Najma Falahi on 21/06/25.
//

import Foundation
import UIKit

class MockData {
    static let sessions: [RecordAnalysisModel] = [
        RecordAnalysisModel(
            date: Date(),
            phases: [
                PhaseModel(name: "Preparation", image: "",elbowAngle: 60,legAngle: 80, improvements: ["Good form on the elbow, keep it up!","The knee bend was shallow."])
            ]
        ),
        RecordAnalysisModel(
            date: Date(),
            phases: [
                PhaseModel(name: "Bending", image: "",elbowAngle: 60,legAngle: 80, improvements: ["Good form on the elbow, keep it up!","The knee bend was shallow."])
            ]
        ),
        RecordAnalysisModel(
            date: Date(),
            phases: [
                PhaseModel(name: "Realese", image: "",elbowAngle: 60,legAngle: 80, improvements: ["Good form on the elbow, keep it up!","The knee bend was shallow."])
            ]
        ),
    ]
}
