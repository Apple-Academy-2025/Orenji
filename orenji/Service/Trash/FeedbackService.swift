//
//  FeedbackService.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 20/06/25.
//

import Foundation

protocol FeedbackService {
    func provideVisualFeedback(for result: BodyAngleResult) -> FeedbackVisual
    func provideHapticFeedback(for result: BodyAngleResult)
}
