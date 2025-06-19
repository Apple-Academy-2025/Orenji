//
//  PoseData.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 13/06/25.
//

import Foundation

struct RecordAnalysisModel: Identifiable, Codable {
    let id: UUID
    var date: Date
    var phases: [PhaseModel]
    
    init(
        id: UUID = UUID(),
        date: Date,
        phases: [PhaseModel] = []
    ) {
        self.id = id
        self.date = date
        self.phases = phases
    }
}

