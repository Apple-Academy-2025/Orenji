//
//  RealtimeServiceImpl.swift
//  orenji
//
//  Created by Muhamad Fannan Najma Falahi on 02/07/25.
//

import SwiftUI
import Vision


class RealtimeServiceImpl: RealtimeService {
    private var poseManager = PostureEvaluateRealtimeManager()
    
    func setUpdatePoseCorrectnessHandler(_ handler: @escaping (Phase) -> Void) {
        poseManager.updatePoseCorrectness = handler
    }
    
    func startHoldPose(phase: Phase, update: @escaping (CGFloat, Bool) -> Void, checkCorrectness: @escaping () -> Bool, completion: @escaping () -> Void) {
        poseManager.startHoldPose(phase: phase, update: update, checkCorrectness: checkCorrectness, completion: completion)
    }
    
    func cancelHold() {
        poseManager.cancelHold()
    }

    init(manager: PostureEvaluateRealtimeManager) {
        self.poseManager = manager
    }
    
    func detectShootingPhase(from points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) -> ShootingPhase{
        poseManager.currentPhaseType(from: points)
    }
    
    func provideSuccessFeedback(withMessage message: String) {
        poseManager.playSuccessFeedback(withMessage: message)
    }
    
    func evaluatePoseCorrectness(recognizedPoints: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint], phase: Phase, useLeft: Bool) -> (isCorrect: Bool, elbow: Int, leg: Int) {
        return poseManager.evaluatePoseCorrectness(from: recognizedPoints, phase: phase, useLeft: useLeft)
    }
    
    func processBuffer(_ buffer: CVPixelBuffer, overlayFrame: CGRect, completion: @escaping (PoseDetectionModel) -> Void) {
        poseManager.detectPose(in: buffer, overlayFrame: overlayFrame) { result in
            completion(result)
        }
    }
    
    func handleFrameChange(_ inFrame: Bool) {}
}
