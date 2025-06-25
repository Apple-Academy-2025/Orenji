//
//  orenjiApp.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 13/06/25.
//

import SwiftUI
import AVFoundation // ⬅️ Tambahkan ini untuk akses audio session

@main
struct PostureBasketApp: App {
    @State private var showSplash = true
    @StateObject private var router = Router()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    // ✅ Aktifkan audio session saat app dijalankan
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
                                case .History:
                                    HistoryView()
                                case .Prefereces:
                                    PreferencesView()
                                }
                            }
                    }
                    .environmentObject(router)
                }
            }
        }
    }

    /// 🔊 Fungsi untuk setup audio session
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ AVAudioSession is active and ready for TTS playback")
        } catch {
            print("❌ Failed to set AVAudioSession: \(error.localizedDescription)")
        }
    }
}
