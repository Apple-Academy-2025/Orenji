//
//  orenjiApp.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 13/06/25.
//

import SwiftUI
import AVFoundation

@main
struct PostureBasketApp: App {
    @State private var showSplash = true
    @StateObject var connectivity = WatchConnectivityManager.shared
    @StateObject private var router = Router()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    @Environment(\.scenePhase) private var scenePhase

    init() {
        configureAudioSession()
    }

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                if !hasSeenOnboarding {
                    OnboardingView {
                        hasSeenOnboarding = true
                        router.goTo(.Prefereces)
                    }
                } else {
                    NavigationStack(path: $router.path) {
                        HomePageView()
                            .navigationDestination(for: Route.self) { route in
                                switch route {
                                case .Home:
                                    HomePageView()
                                case .Tutorial:
                                    TutorialView()
                                case .Instruksi(let destination, let idPage):
                                    InstruksiView(destination: destination, idPage: idPage)
                                case .RecordPose:
                                    RecordAnalysisView()
                                case .RealtimePose:
                                    EvaluateRealtimeView()
                                case .HistoryDetailView(let PhaseData, let selectedTab):
                                    HistoryDetailView(PhaseDatas: PhaseData, selectedTab:selectedTab)
                                case .History:
                                    HistoryView()
                                case .Prefereces:
                                    PreferencesView()
                                case .RecordAnalysisView:
                                    EmptyView()
                                case .TutorialView:
                                    EmptyView()
                                case .FinishRealtime(let loopCount, let durationInSeconds):
                                    FinishRealtimeView(loopCount: loopCount, durationInSeconds: durationInSeconds)

                                }
                            } 
                    }

                    .onChange(of: scenePhase) { oldPhase, newPhase in
                        switch newPhase {
                        case .active:
                            connectivity.sendAppState(state: true)
                        case .inactive:
                            connectivity.sendAppState(state: false)
                        case .background:
                            break
                        @unknown default:
                            break
                        }
                    }
                    .modelContainer(for: [FrameData.self, PhaseData.self])
                    .environmentObject(router)
                }
            }
        }
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .spokenAudio,
                options: [.duckOthers, .defaultToSpeaker, .mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ AVAudioSession configured successfully for TTS")
        } catch {
            print("❌ Failed to configure AVAudioSession: \(error.localizedDescription)")
        }
    }
}
