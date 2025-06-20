//
//  PosePhase.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 20/06/25.
//

import Foundation

enum PosePhase: String, CaseIterable, Codable {
    case preparation = "Preparation"
    case bending = "Bending"
    case followThrough = "FollowThrough"
    case unknown = "Negative"
}

