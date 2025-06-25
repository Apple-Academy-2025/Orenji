import SwiftUI
import AVFoundation

struct EvaluateRealtimeView: View {
    @EnvironmentObject var router: Router
    @StateObject private var cameraService = CameraService()
    @StateObject private var poseDetector = PoseDetectionViewModel()

    enum Phase {
        case preRecord, checkPhase1, checkPhase2, finished
    }

    @State private var phase: Phase = .preRecord
    @State private var showWarning = false
    @State private var warningScale: CGFloat = 1.0
    @State private var warningTimer: Timer?
    @State private var showWarningText = false

    // PreRecord
    @State private var showInFrameText = false
    @State private var countdown = 3
    @State private var isCountingDown = false
    @State private var showStartText = false
    @State private var isRecordingStarted = false
    @State private var warningText: String = "FOLLOW THE INSTRUCTIONS EACH PHASE!"
    @State private var isOverlayVisible = true
    @State private var holdSeconds = 3
    @State private var holdTimer: Timer? = nil
    @State private var everDetected = false

    // Loop tracking
    @State private var loopCount = 0
    @State private var showExitConfirmation = false

    private let boxSize = CGSize(width: 250, height: 500)

    var body: some View {
        ZStack {
            CameraPreview(service: cameraService)
                .ignoresSafeArea()

            if !poseDetector.recognizedPoints.isEmpty {
                PoseOverlayView(points: poseDetector.recognizedPoints, evaluationColor: .yellow)
            }

            if phase == .preRecord {
                PreRecordOverlay(
                    isRecordingStarted: isRecordingStarted,
                    isOverlayVisible: isOverlayVisible,
                    isUserInFrame: poseDetector.isUserInFrame,
                    holdSeconds: holdSeconds,
                    showWarningText: showWarningText,
                    warningText: warningText,
                    warningScale: warningScale,
                    isCountingDown: isCountingDown,
                    countdown: countdown,
                    showStartText: showStartText,
                    boxSize: boxSize,
                    borderColor: borderColor,
                    statusText: statusText
                )
                .environmentObject(router)
            }

            switch phase {
            case .checkPhase1, .checkPhase2:
                HoldPose(
                    phaseTitle: phase == .checkPhase1 ? "Phase 1: Raise Hand" : "Phase 2: Repeat Pose",
                    holdProgress: poseDetector.holdProgress,
                    warningMessage: currentWarningMessage,
                    warningScale: warningScale
                    
                )
                .environmentObject(router)

            case .finished:
                EvaluationFinishedView(loopCount: loopCount)
                    .environmentObject(router)

            default: EmptyView()
            }

            // Global STOP button
            if phase == .checkPhase1 || phase == .checkPhase2 {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showExitConfirmation = true
                        }) {
                            Text("STOP")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                        .padding(24)
                        .confirmationDialog("Are you sure you want to stop?", isPresented: $showExitConfirmation, titleVisibility: .visible) {
                            Button("Yes, Stop", role: .destructive) {
                                phase = .finished
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                    }
                }
            }
        }
        .onAppear(perform: setupCamera)
        .onChange(of: poseDetector.holdCompleted) { completed in
            if completed {
                poseDetector.cancelHold()
                loopCount += 1
                phase = (phase == .checkPhase1) ? .checkPhase2 : .checkPhase1
                poseDetector.startHoldPose()
            }
        }
        .onChange(of: poseDetector.isUserInFrame, perform: handleFrameChange)
        .onChange(of: phase) { newPhase in
            if newPhase == .checkPhase1 || newPhase == .checkPhase2 {
                startWarningLoop()
                poseDetector.startHoldPose()
            } else {
                stopWarningLoop()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var currentWarningMessage: String? {
        if !poseDetector.isUserInFrame {
            return "You're out of frame!"
        } else if poseDetector.isHoldingPose && !poseDetector.isRightHandRaised() {
            return "Raise your right hand!"
        } else {
            return nil
        }
    }

    private func setupCamera() {
        cameraService.configure()
        cameraService.start()
        cameraService.onFrameCaptured = { buffer in
            poseDetector.processBuffer(buffer)
        }

        DispatchQueue.main.async {
            let screen = UIScreen.main.bounds
            let boxWidth = screen.width * 0.8
            let boxHeight = screen.height * 0.7
            let originX = (screen.width - boxWidth) / 2
            let originY = (screen.height - boxHeight) / 2 + 60
            poseDetector.overlayFrame = CGRect(x: originX, y: originY, width: boxWidth, height: boxHeight)
        }
    }

    private func handleFrameChange(_ inFrame: Bool) {
        if phase != .preRecord { return }
        if inFrame {
            everDetected = true
            if holdTimer == nil {
                holdSeconds = 3
                holdTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                    if holdSeconds > 1 {
                        holdSeconds -= 1
                    } else {
                        timer.invalidate()
                        holdTimer = nil
                        triggerRecordingSequence()
                    }
                }
            }
        } else {
            holdTimer?.invalidate()
            holdTimer = nil
            holdSeconds = 3
        }
    }

    private func triggerRecordingSequence() {
        guard !isRecordingStarted && !isCountingDown else { return }
        withAnimation(.easeOut(duration: 0.4)) { showInFrameText = true }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                isOverlayVisible = false
                showWarningText = true
                warningScale = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showWarningText = false
                    startCountdown()
                }
            }
        }
    }

    private func startCountdown() {
        isCountingDown = true
        countdown = 3
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                isCountingDown = false
                withAnimation(.easeIn(duration: 0.2)) { showStartText = true }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeOut(duration: 0.2)) { showStartText = false }
                    beginRecording()
                }
            }
        }
    }

    private func beginRecording() {
        isRecordingStarted = true
        phase = .checkPhase1
        poseDetector.startHoldPose()
    }

    private func startWarningLoop() {
        warningTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            let show = poseDetector.isHoldingPose && !poseDetector.isRightHandRaised()
            withAnimation(.easeInOut(duration: 0.3)) {
                showWarning = show
                warningScale = show ? 1.2 : 1.0
            }
        }
    }

    private func stopWarningLoop() {
        warningTimer?.invalidate()
        warningTimer = nil
    }

    private var borderColor: Color {
        if poseDetector.isUserInFrame { return .green }
        else if everDetected { return .red }
        else { return Color("") }
    }

    private var statusText: String {
        if poseDetector.isUserInFrame { return "DETECTED" }
        else if everDetected { return "TOO CLOSE" }
        else { return "Make sure to **keep your body**\naligned within this frame to start" }
    }
}



struct EvaluationFinishedView: View {
    @EnvironmentObject var router: Router
    var loopCount: Int

    var body: some View {
        ZStack {
            // Latar gelap transparan
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("✅ You have completed")
                    .font(.title2)
                    .foregroundColor(.white)

                Text("\(loopCount) phase\(loopCount > 1 ? "s" : "")!")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.green)

                Button(action: {
                    router.pop()
                }) {
                    Text("Done")
                        .font(.headline)
                        .padding()
                        .frame(width: 120)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
            .padding()
            .background(Color.black.opacity(0.75))
            .cornerRadius(20)
            .padding(.horizontal, 40)
        }
    }
}


#Preview {
    EvaluateRealtimeView()
        .environmentObject(Router())
}
