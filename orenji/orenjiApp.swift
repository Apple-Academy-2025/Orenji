//
//  orenjiApp.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 13/06/25.
//

import SwiftUI

@main
struct PostureBasketApp: App {
    @State private var showSplash = true
    @StateObject private var router = Router()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    
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
                                case .RecordPose(let titlePage):
                                    RecordAnalysisView(titlePage: titlePage)
                                case .RealtimePose(let titlePage):
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
}


