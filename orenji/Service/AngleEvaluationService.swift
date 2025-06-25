//
//  AngleEvaluationService.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 19/06/25.
//

import Foundation
import CoreGraphics

protocol AngleEvaluationService {
    /// Mengevaluasi sudut tubuh dari kumpulan landmark tubuh
    func evaluateAngles(from landmarks: [BodyLandmark]) -> BodyAngleResult
}
