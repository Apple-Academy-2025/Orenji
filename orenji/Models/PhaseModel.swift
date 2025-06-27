//
//  Phase.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 16/06/25.
//

import Foundation

struct PhaseModel: Identifiable, Codable {
    let id: UUID
    var name: String
    var image: String
    var elbowAngle: Double?
    var legAngle: Double?
    var improvements: [String]
    var imageModel: Data?
    
    init(
        id: UUID = UUID(),
        name: String,
        image: String,
        elbowAngle: Double? = nil,
        legAngle: Double? = nil,
        improvements: [String] = [],
        imageModel: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.image = image
        self.elbowAngle = elbowAngle
        self.legAngle = legAngle
        self.improvements = improvements
        self.imageModel = imageModel
    }
}

