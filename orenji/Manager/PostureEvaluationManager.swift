//
//  PostureEvaluationManager.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 20/06/25.
//

import Foundation
import UIKit

class PostureEvaluationManager {
    
    private let classifier: PosePhaseClassifierService
    private let angleService: AngleEvaluationService
    private let feedbackService: FeedbackService
    private let imageService: ImageCaptureService
    private let recordService: RecordStorageService
    private let ballService: BallDetectionService

    private var wasBallInHand: Bool = true

    init(
        classifier: PosePhaseClassifierService,
        angleService: AngleEvaluationService,
        feedbackService: FeedbackService,
        imageService: ImageCaptureService,
        recordService: RecordStorageService,
        ballService: BallDetectionService
    ) {
        self.classifier = classifier
        self.angleService = angleService
        self.feedbackService = feedbackService
        self.imageService = imageService
        self.recordService = recordService
        self.ballService = ballService
    }

    func evaluateSession(
        frames: [UIImage],
        landmarks: [[BodyLandmark]]
    ) throws {
        guard frames.count == landmarks.count else {
            throw NSError(domain: "Mismatched frames & landmarks", code: -99)
        }

        var bestFrameByPhase: [PosePhase: (UIImage, [BodyLandmark])] = [:]

        for (index, image) in frames.enumerated() {
            let ballStillInHand = try ballService.isBallInHand(from: image)
            if wasBallInHand && !ballStillInHand {
                print("🚨 Bola sudah tidak di tangan → STOP evaluasi")
                break
            }
            wasBallInHand = ballStillInHand
            let predictedPhase = try classifier.classifyPhase(from: image)
            guard predictedPhase != .unknown else { continue }
            if bestFrameByPhase[predictedPhase] == nil {
                bestFrameByPhase[predictedPhase] = (image, landmarks[index])
            }
        }
        var phaseModels: [PhaseModel] = []
        for phase in PosePhase.allCases where phase != .unknown {
            guard let (image, landmark) = bestFrameByPhase[phase] else { continue }

            let filename = try imageService.saveImage(image, for: phase.rawValue)
            let result = angleService.evaluateAngles(from: landmark)
            let feedback = feedbackService.provideVisualFeedback(for: result)

            let model = PhaseModel(
                name: phase.rawValue,
                image: filename,
                elbowAngle: result.elbowAngle,
                legAngle: result.legAngle,
                improvements: [feedback.message]
            )
            phaseModels.append(model)
        }

        let record = RecordAnalysisModel(date: Date(), phases: phaseModels)
        try recordService.saveAnalysisRecord(record)
    }
    
}
