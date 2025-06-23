//
//  PreRecord.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 23/06/25.
//

import SwiftUI

struct PreRecordView: View {
    @EnvironmentObject var router: Router
    @StateObject private var cameraService = CameraService()
    @StateObject private var poseDetector = PoseDetectionViewModel()

    var warningText: String = ".."
    var onStartRecording: () -> Void = {}

    // MARK: - UI State
    @State private var showInFrameText = false
    @State private var countdown = 3
    @State private var isCountingDown = false
    @State private var showStartText = false          // ➕ "START!" flag
    @State private var isRecordingStarted = false
    @State private var warningScale: CGFloat = 0.8
    @State private var showWarningText = false
    @State private var isOverlayVisible = true
    @State private var holdSeconds = 3
    @State private var holdTimer: Timer? = nil
    @State private var everDetected = false

    private let boxSize = CGSize(width: 250, height: 500)

    var body: some View {
        ZStack {
            // 📷 Live camera
            CameraPreview(service: cameraService)
                .ignoresSafeArea()

            // 🟡 Key‑points overlay
            if !poseDetector.recognizedPoints.isEmpty {
                PoseOverlayView(points: poseDetector.recognizedPoints, evaluationColor: .yellow)
            }

            // 🔲 Frame overlay dan border
            if !isRecordingStarted && isOverlayVisible {
                FrameOverlay(boxSize: boxSize, borderColor: borderColor)
            }

            // 📝 Status text
            if !isRecordingStarted && isOverlayVisible {
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
            }

            // 🔙 Back button
            if !isRecordingStarted && isOverlayVisible {
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

            // ⏳ Hold‑still indicator
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

            // ⚠️ Warning blurb
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

            // 🔢 Countdown & "START!"
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
        // MARK: – Lifecycle hooks
        .onAppear(perform: setup)
        .onDisappear { cameraService.stop() }
        .onChange(of: poseDetector.isUserInFrame, perform: handleFrameChange)
        .navigationBarBackButtonHidden(true)
    }

    // MARK: – Setup
    private func setup() {
        cameraService.configure()
        cameraService.onFrameCaptured = { buffer in poseDetector.processBuffer(buffer) }

        DispatchQueue.main.async {
            let screen = UIScreen.main.bounds
            let boxWidth  = screen.width * 0.8
            let boxHeight = screen.height * 0.7
            let originX   = (screen.width - boxWidth) / 2
            let originY   = (screen.height - boxHeight) / 2 + 60
            poseDetector.overlayFrame = CGRect(x: originX, y: originY, width: boxWidth, height: boxHeight)
        }
    }

    // MARK: – Hold logic
    private func handleFrameChange(_ inFrame: Bool) {
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

    // MARK: – Flow to recording
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

                // Tampilkan "START!" sebentar lalu mulai recording
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeOut(duration: 0.2)) { showStartText = false }
                    beginRecording()
                }
            }
        }
    }

    private func beginRecording() {
        isRecordingStarted = true
        onStartRecording()
    }

    // MARK: – Helpers
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
    PreRecordView(warningText: "INI DINAMIS")
        .environmentObject(Router())
}
