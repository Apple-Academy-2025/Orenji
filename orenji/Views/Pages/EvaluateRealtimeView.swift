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

    // PreRecord Logic States
    @State private var showInFrameText = false
    @State private var countdown = 3
    @State private var isCountingDown = false
    @State private var showStartText = false
    @State private var isRecordingStarted = false
    @State private var warningText: String = "Ayo mulai!"
    @State private var isOverlayVisible = true
    @State private var holdSeconds = 3
    @State private var holdTimer: Timer? = nil
    @State private var everDetected = false

    private let boxSize = CGSize(width: 250, height: 500)

    var body: some View {
        ZStack {
            CameraPreview(service: cameraService)
                .ignoresSafeArea()

            if !poseDetector.recognizedPoints.isEmpty {
                PoseOverlayView(points: poseDetector.recognizedPoints, evaluationColor: .yellow)
            }

            if phase == .preRecord {
                if !isRecordingStarted && isOverlayVisible {
                    FrameOverlay(boxSize: boxSize, borderColor: borderColor)

                    GeometryReader { geo in
                        VStack {
                            Text(statusText)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(borderColor)
                                .cornerRadius(20)
                                .padding(.top, 12)
                        }
                        .position(x: geo.size.width / 2,
                                  y: (geo.size.height - boxSize.height) / 2 - 40)
                    }
                    .offset(y: -10)

                    VStack {
                        HStack {
                            Button { router.pop() } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.black)
                                    .padding()
                                    .background(Color.orange)
                                    .clipShape(Circle())
                            }
                            Spacer()
                        }
                        .padding([.horizontal, .top], 20)
                        Spacer()
                    }
                }

                if !isRecordingStarted && isOverlayVisible && poseDetector.isUserInFrame {
                    VStack(spacing: 8) {
                        Text("✅ Hold still...")
                            .foregroundColor(.green)
                            .bold()
                        Text("\(holdSeconds)")
                            .font(.title)
                            .foregroundColor(.green)
                    }
                    .offset(y: 180)
                }

                if showWarningText {
                    VStack {
                        Text(warningText)
                            .font(.system(size: 40, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding()
                            .cornerRadius(16)
                            .scaleEffect(warningScale)
                            .opacity(showWarningText ? 1 : 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.scale.combined(with: .opacity))
                }

                if isCountingDown {
                    Text("\(countdown)")
                        .font(.system(size: 100, weight: .bold))
                        .foregroundColor(.primer)
                }

                if showStartText {
                    Text("START!")
                        .font(.system(size: 100, weight: .heavy))
                        .foregroundColor(.white)
                        .transition(.opacity)
                }
            }

            switch phase {
            case .checkPhase1, .checkPhase2:
                HoldPose(
                    phaseTitle: phase == .checkPhase1 ? "Phase 1: Raise Hand" : "Phase 2: Repeat Pose",
                    holdProgress: poseDetector.holdProgress,
                    showWarning: showWarning,
                    warningScale: warningScale
                )

            case .finished:
                VStack(spacing: 20) {
                    Text("✅ All Phases Completed!")
                        .foregroundColor(.green)
                        .font(.largeTitle)
                        .bold()
                    Button("Done") {
                        router.pop()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }

            default: EmptyView()
            }
        }
        .onAppear(perform: setupCamera)
        .onChange(of: poseDetector.holdCompleted) { completed in
            if completed {
                poseDetector.cancelHold()
                if phase == .checkPhase1 {
                    phase = .checkPhase2
                    poseDetector.startHoldPose()
                } else if phase == .checkPhase2 {
                    phase = .finished
                }
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

#Preview {
    EvaluateRealtimeView()
        .environmentObject(Router())
}
