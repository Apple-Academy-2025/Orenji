    import SwiftUI
    import Vision
    import AVFoundation

    struct EvaluateRealtimeView: View {
        @EnvironmentObject var router: Router
        @StateObject private var cameraService = CameraService()
        @StateObject private var poseDetector = PoseDetectionViewModel()
        @StateObject var connectivity = WatchConnectivityManager.shared
        @StateObject private var speechManager = SpeechManager()
        
        enum Phase {
            case preRecord, checkPhase1, checkPhase2, checkPhase3, finished
        }
        
        @State private var phase: Phase = .preRecord
        @State private var showWarning = false
        @State private var warningScale: CGFloat = 1.0
        @State private var warningTimer: Timer?
        @State private var showWarningText = false
        
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
        
        @State private var loopCount = 0
        @State private var showExitConfirmation = false
        @State private var lastSpokenMessage: String = ""
        
        @State private var speechQueue: [String] = []
        @State private var isSpeaking = false
        
        
        
        private let boxSize = CGSize(width: 250, height: 500)
        static var currentGlobalPhase: Phase = .preRecord
        
        var statusTitle = "For best result"
        
        var evaluationColors: [VNHumanBodyPoseObservation.JointName: Color] {
            var colors: [VNHumanBodyPoseObservation.JointName: Color] = [:]
            
            if phase == .checkPhase1 {
                let angle = poseDetector.elbowAngleNow
                let color = colorForElbowAngle(Double(angle), target: 120)
                let joint: VNHumanBodyPoseObservation.JointName = UserDefaults.standard.string(forKey: "shootingHand") == "Left" ? .leftElbow : .rightElbow
                colors[joint] = color
            }
            
            if phase == .checkPhase2 {
                let angle = poseDetector.legAngleNow
                let color = colorForLegAngle(Double(angle), target: 75)
                let joint: VNHumanBodyPoseObservation.JointName = UserDefaults.standard.string(forKey: "shootingHand") == "Left" ? .leftKnee : .rightKnee
                colors[joint] = color
            }
            
            if phase == .checkPhase3 {
                let angle = poseDetector.elbowAngleNow
                let color = colorForElbowAngle(Double(angle), target: 170)
                let joint: VNHumanBodyPoseObservation.JointName = UserDefaults.standard.string(forKey: "shootingHand") == "Left" ? .leftElbow : .rightElbow
                colors[joint] = color
            }
            
            return colors
        }
        
        
        
        var body: some View {
            ZStack {
                CameraPreview(service: cameraService).ignoresSafeArea()
                
                
                // 👇 Baru tampilkan PoseOverlayView dengan evaluationColors
                if !poseDetector.recognizedPoints.isEmpty {
                    PoseOverlayView(
                        points: poseDetector.recognizedPoints,
                        evaluationColors: evaluationColors,
                        isRightHand: UserDefaults.standard.string(forKey: "shootingHand") != "Left"
                    )
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
                        statusText: statusText,
                        statusTitle: statusTitle
                    ).environmentObject(router)
                }
                
                switch phase {
                case .checkPhase1 , .checkPhase2, .checkPhase3 :
                    HoldPose(
                        phaseTitle: phaseTitleText,
                        holdProgress: poseDetector.holdProgress,
                        warningMessage: currentWarningMessage,
                        warningScale: warningScale,
                        correct: poseDetector.isPoseCorrect
                    ).environmentObject(router)
                
                case .finished:
                    EvaluationFinishedView(loopCount: loopCount)
                        .environmentObject(router)
                default:
                    EmptyView()
                }
                
                if [.checkPhase1, .checkPhase2, .checkPhase3].contains(phase) {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: { showExitConfirmation = true }) {
                                Text("STOP")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.red)
                                    .clipShape(Circle())
                            }
                            .padding(24)
                            .confirmationDialog("Are you sure you want to stop?", isPresented: $showExitConfirmation, titleVisibility: .visible) {
                                Button("Yes, Stop", role: .destructive) { phase = .finished }
                                Button("Cancel", role: .cancel) {}
                            }
                        }
                    }
                }
            }
            .onAppear {
                setupCamera()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    speechManager.speak("Voice system is ready")
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .speakFromViewModel)) { notif in
                if let message = notif.object as? String {
                    speechManager.speak(message)
                }
            }
            .onChange(of: poseDetector.holdCompleted) { oldCompleted, completed in
                if completed {
                    poseDetector.cancelHold()
                    loopCount += 1
                    switch phase {
                    case .checkPhase1: phase = .checkPhase2
                    case .checkPhase2: phase = .checkPhase3
                    case .checkPhase3: phase = .checkPhase1
                    default: break
                    }
                    EvaluateRealtimeView.currentGlobalPhase = phase
                    poseDetector.startHoldPose()
                }
            }
            .onChange(of: poseDetector.isUserInFrame, perform: handleFrameChange)
            .onChange(of: phase) { oldPhase, newPhase in
                EvaluateRealtimeView.currentGlobalPhase = newPhase
                print("📍 Phase berubah dari \(oldPhase) ke \(newPhase)")
                    
                if [.checkPhase1, .checkPhase2, .checkPhase3].contains(newPhase) {
                    startWarningLoop()
                    
                    // 🔧 Delay untuk memastikan phase sudah update
                    DispatchQueue.main.async {
                        poseDetector.startHoldPose()
                    }
                } else {
                    stopWarningLoop()
                }
            }
            .onChange(of: poseDetector.holdProgress) { oldProgress, progress in
                guard progress > 0, progress < 1 else { return }
                let countdown = Int(ceil(3.0 - (progress * 3.0)))
                sendRealtimePoseToWatch(isCorrect: true, correctionMessage: nil, countdown: countdown)
            }
            .navigationBarBackButtonHidden(true)
        }
        
        private func startWarningLoop() {
            warningTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                guard poseDetector.isUserInFrame, !poseDetector.isEvaluatingPose else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showWarning = false
                        warningScale = 1.0
                    }
                    return
                }
                
                if poseDetector.isHoldingPose, let msg = currentWarningMessage {
                    print("🔊 Attempting to speak: \(msg)")
                    sendRealtimePoseToWatch(isCorrect: false, correctionMessage: msg, countdown: nil)
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showWarning = true
                        warningScale = 1.2
                    }
                    speechManager.speak(msg)
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showWarning = false
                        warningScale = 1.0
                    }
                }
            }
        }
        
        var evaluationColor: Color {
            switch phase {
            case .checkPhase1:
                return colorForElbowAngle(Double(poseDetector.elbowAngleNow), target: 120)
            case .checkPhase2:
                return colorForLegAngle(Double(poseDetector.legAngleNow), target: 75)
            case .checkPhase3:
                return colorForElbowAngle(Double(poseDetector.elbowAngleNow), target: 170)
            default:
                return .yellow
            }
        }
        
        
        // ✅ Perbaikan audio session setup
        //    private func setupAudioSession() {
        //        do {
        //            let audioSession = AVAudioSession.sharedInstance()
        //            try audioSession.setCategory(
        //                .playback,
        //                mode: .spokenAudio,
        //                options: [.duckOthers, .defaultToSpeaker, .mixWithOthers] // ini penting!
        //            )
        //            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        //            print("🔊 Audio session setup successful")
        //        } catch {
        //            print("❌ Audio session setup failed: \(error)")
        //        }
        //    }
        
        
        
        
        private var phaseTitleText: String {
            switch phase {
            case .checkPhase1: return "Preparation"
            case .checkPhase2: return "Bending"
            case .checkPhase3: return "Release"
            default: return ""
            }
        }
        
        private var currentWarningMessage: String? {
            if !poseDetector.isUserInFrame {
                return "You're out of frame!"
            }
            
            let currentPhase = poseDetector.currentPhaseType()
            
            switch phase {
            case .checkPhase1 where currentPhase != .preparation:
                if poseDetector.elbowAngleNow < 115 {
                    return "Elbow too close, stretch more"
                } else if poseDetector.elbowAngleNow > 125 {
                    return "Elbow too wide, lower slightly"
                }
                return "Hold Preparation Pose!"
                
            case .checkPhase2 where currentPhase != .bending:
                if poseDetector.legAngleNow < 70 {
                    return "Leg too bent, straighten slightly"
                } else if poseDetector.legAngleNow > 80 {
                    return "Leg too straight, bend more"
                }
                return "Hold Bending Pose!"
                
            case .checkPhase3 where currentPhase != .release:
                if poseDetector.elbowAngleNow < 165 {
                    return "Elbow too low, raise your arm"
                } else if poseDetector.elbowAngleNow > 175 {
                    return "Elbow too high, relax a bit"
                }
                return "Hold Release Pose!"
                
            default:
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
                    connectivity.sendDisplayStateToWatch("showMessage")
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
                    connectivity.sendDisplayStateToWatch("showNumber", value: countdown)
                    countdown -= 1
                } else {
                    timer.invalidate()
                    isCountingDown = false
                    connectivity.sendDisplayStateToWatch("showStart")
                    withAnimation(.easeIn(duration: 0.2)) { showStartText = true }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation(.easeOut(duration: 0.2)) { showStartText = false }
                        beginRecording()
                    }
                }
            }
        }
        
        private func beginRecording() {
            connectivity.sendDisplayStateToWatch("activelyRealtime")
            isRecordingStarted = true
            phase = .checkPhase1
            poseDetector.startHoldPose()
        }
        
       
        
        private func configureAudioSessionOnce() {
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playback, mode: .default, options: [.duckOthers, .mixWithOthers, .defaultToSpeaker])
                try session.setActive(true)
                print("🔊 Audio session ready")
            } catch {
                print("❌ Audio session error: \(error)")
            }
        }
        
        
        private func stopWarningLoop() {
            warningTimer?.invalidate()
            warningTimer = nil
        }
        
        private var borderColor: Color {
            if poseDetector.isUserInFrame {
                connectivity.sendCameraPoseStatusToWatch(isCorrect: true)
                return .green
            }
            else if everDetected {
                connectivity.sendCameraPoseStatusToWatch(isCorrect: false)
                return .red
            }
            else { return Color.clear }
        }
        
        private var statusText: String {
            if poseDetector.isUserInFrame { return "DETECTED" }
            else if everDetected { return "TOO CLOSE" }
            else { return "Make sure to keep your ball and feet visible within the frame" }
        }
        
        func colorForElbowAngle(_ angle: Double, target: Double) -> Color {
            let delta = abs(angle - target)
            if delta < 5 {
                return .green
            } else if delta < 15 {
                return .yellow
            } else {
                return .red
            }
        }
        
        func colorForLegAngle(_ angle: Double, target: Double) -> Color {
            let delta = abs(angle - target)
            if delta < 5 {
                return .green
            } else if delta < 15 {
                return .yellow
            } else {
                return .red
            }
        }
        
        
        
        func sendRealtimePoseToWatch(isCorrect: Bool, correctionMessage: String?, countdown: Int?) {
            let phaseName = self.phaseTitleText
            
            let poseData = RealtimePoseData(
                phase: phaseName,
                isPoseCorrect: isCorrect,
                correctionMessage: correctionMessage,
                holdCountdown: countdown
            )
            
            if let encoded = try? JSONEncoder().encode(poseData) {
                WatchConnectivityManager.shared.sendPoseUpdate(data: encoded)
            }
        }
    }


    extension Notification.Name {
        static let speakFromViewModel = Notification.Name("SpeakFromViewModel")
    }


    struct EvaluationFinishedView: View {
        @EnvironmentObject var router: Router
        var loopCount: Int
        
        var body: some View {
            ZStack {
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
