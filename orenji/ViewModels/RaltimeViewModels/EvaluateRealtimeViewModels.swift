//
//  EvaluateRealtimeViewModels.swift
//  orenji
//
//  Created by Muhamad Fannan Najma Falahi on 02/07/25.
//

import SwiftUI
import Vision

@MainActor
class EvaluateRealtimeViewModels: ObservableObject {
    // Pose Evaluation
    @Published var isPoseCorrect: Bool = false
    @Published var elbowAngleNow: Int = 0
    @Published var legAngleNow: Int = 0
    @Published var currentPhase: ShootingPhase = .unknown
    
    // Hold Progress
    @Published var holdProgress: CGFloat = 0
    @Published var isHoldingPose: Bool = false
    @Published var holdCompleted: Bool = false
    @Published var isEvaluatingPose: Bool = false
    
    // Vision Points
    @Published var recognizedPoints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint] = [:]
    @Published var jointPoints: [PoseJoint] = []
    @Published var isUserInFrame = false
    
    let connectivity = WatchConnectivityManager.shared
    private let poseService: RealtimeService
    var overlayFrame: CGRect = .zero
    
    init(poseService: RealtimeService) {
        self.poseService = poseService
        poseService.setUpdatePoseCorrectnessHandler { [weak self] phase in
            self?.updatePoseCorrectness(for: phase)
        }
    }
    
    func processBuffer(_ buffer: CVPixelBuffer) {
        poseService.processBuffer(buffer, overlayFrame: overlayFrame) { [weak self] result in
            Task { @MainActor in
                self?.isUserInFrame = result.isUserInFrame
                self?.jointPoints = result.jointPoints
                self?.recognizedPoints = result.recognizedPoints
            }
        }
    }
    
    func startHoldPose(currentPhase: Phase) {
        poseService.startHoldPose(
            phase: currentPhase,
            update: { [weak self] progress, isCorrect in
                self?.holdProgress = progress
                self?.isPoseCorrect = isCorrect
            },
            checkCorrectness: { [weak self] in
                return self?.isPoseCorrect ?? false
            },
            completion: { [weak self] in
                self?.holdCompleted = true
                self?.playSuccessFeedback(message: "Great! You nailed it.")
            }
        )
    }
    
    func cancelHold() {
        poseService.cancelHold()
        holdProgress = 0
        holdCompleted = false
        isHoldingPose = false
        isEvaluatingPose = false
    }
    
    func updatePoseCorrectness(for phase: Phase) {
        let useLeft = UserDefaults.standard.string(forKey: "shootingHand") == "Left"
        let result = poseService.evaluatePoseCorrectness(
            recognizedPoints: recognizedPoints,
            phase: phase,
            useLeft: useLeft
        )
        
        isPoseCorrect = result.isCorrect
        elbowAngleNow = result.elbow
        legAngleNow = result.leg
    }
    
    func playSuccessFeedback(message: String) {
        poseService.provideSuccessFeedback(withMessage: message)
    }
    
    func updatePhase() {
        currentPhase = poseService.detectShootingPhase(from: recognizedPoints)
    }
    
    func sendRealtimePoseToWatch(phaseName: String, isCorrect: Bool, correctionMessage: String?, countdown: Int?) {
        let poseData = RealtimePoseData(
            phase: phaseName,
            isPoseCorrect: isCorrect,
            correctionMessage: correctionMessage,
            holdCountdown: countdown
        )
        if let encoded = try? JSONEncoder().encode(poseData) {
            connectivity.sendPoseUpdate(data: encoded)
        }
    }
    
    func colorForJoint(angle: Double, target: Double) -> Color {
        let delta = abs(angle - target)
        switch delta {
        case ..<5: return .green
        case ..<15: return .yellow
        default: return .red
        }
    }
}
