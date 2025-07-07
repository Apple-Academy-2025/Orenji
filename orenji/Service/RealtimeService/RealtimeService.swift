//
//  RealtimeService.swift
//  orenji
//
//  Created by Muhamad Fannan Najma Falahi on 02/07/25.
//

import SwiftUI
import Vision

protocol RealtimeService {
    func detectShootingPhase(from points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) -> ShootingPhase
    func processBuffer(_ buffer: CVPixelBuffer, overlayFrame: CGRect, completion: @escaping (PoseDetectionModel) -> Void)
    func handleFrameChange(_ inFrame: Bool)
    func evaluatePoseCorrectness(
        recognizedPoints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint],
        phase: Phase,
        useLeft: Bool
    ) -> (isCorrect: Bool, elbow: Int, leg: Int)
    func provideSuccessFeedback(withMessage message: String)
    func startHoldPose(
        phase: Phase,
        update: @escaping (_ progress: CGFloat, _ isCorrect: Bool) -> Void,
        checkCorrectness: @escaping () -> Bool,
        completion: @escaping () -> Void
    )
    func cancelHold()
    func setUpdatePoseCorrectnessHandler(_ handler: @escaping (Phase) -> Void)
}
