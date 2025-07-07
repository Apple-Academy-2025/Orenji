//
//  PostureModels.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 19/06/25.
//

import Foundation
import CoreGraphics
import UIKit

// MARK: - Nama Titik Tubuh (Enum)
enum LandmarkName: String, CaseIterable, Codable {
    case shoulder
    case elbow
    case wrist
    case hip
    case knee
    case ankle
}

// MARK: - Titik Tubuh (Landmark)
struct BodyLandmark: Codable {
    let name: LandmarkName
    let location: CGPoint
}

// MARK: - Hasil Evaluasi Sudut Tubuh
struct BodyAngleResult: Codable {
    let elbowAngle: Double?
    let legAngle: Double?
    let isIdeal: Bool
}

// MARK: - Umpan Balik Visual
struct FeedbackVisual {
    let message: String
    let color: UIColor
}

// MARK: - Status Postur (untuk UI/Apple Watch)
enum PostureStatus: Codable {
    case ideal
    case warning(String)
    case critical(String)
}

enum SessionType: String {
    case recording
    case realtime
}

enum Phase {
    case preRecord, checkPhase1, checkPhase2, checkPhase3, finished
}

enum ShootingPhase {
    case preparation, bending, release, unknown
}

