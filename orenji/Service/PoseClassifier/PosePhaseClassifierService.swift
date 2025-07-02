//
//  PosePhaseClassifierService.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 20/06/25.
//

import Foundation
import UIKit

protocol PosePhaseClassifierService {
    func classifyPhase(from image: UIImage) throws -> PosePhase
}
