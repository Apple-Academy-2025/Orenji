//
//  BallDetectionService.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 20/06/25.
//

import Foundation
import UIKit

protocol BallDetectionService {
    /// Mengembalikan true jika bola masih di tangan pemain
    func isBallInHand(from image: UIImage) throws -> Bool
}
