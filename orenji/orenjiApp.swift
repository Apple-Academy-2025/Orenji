//
//  orenjiApp.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 13/06/25.
//

import SwiftUI

@main
struct orenjiApp: App {
    
    @StateObject var router = Router()
    @State private var showSplash = true 
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.orange
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.brown
    }
    

    var body: some Scene {
        WindowGroup {
                NavigationStack(path: $router.path) {
                    if showSplash {
                        HomePageView()
                            .navigationDestination(for: Route.self) { route in
                                switch route {
                                case .Home:
                                    HomePageView()
                                case .Tutorial:
                                    TutorialView()
                                case .Instruksi(let destination, let idPage):
                                    InstruksiView(destination: destination, idPage: idPage)
                                case .RecordAnalysisView:
                                    RecordAnalysisView()
                                case .RealtimePose(let titlePage):
                                    EvaluateRealtimeView()
                                case .History:
                                    HistoryView()
                                case .HistoryView:
                                    HistoryView()
                                case .TutorialView:
                                    TutorialView()
                                }
                            }.environmentObject(router)   
                    } else {
                        if !hasSeenOnboarding {
                            OnboardingView {
                                hasSeenOnboarding = true
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
                                        case .RecordAnalysisView:
                                            RecordAnalysisView()
                                        case .RealtimePose(let titlePage):
                                            EvaluateRealtimeView()
                                        case .History:
                                            HistoryView()
                                        case .HistoryView:
                                            HistoryView()
                                        case .TutorialView:
                                            TutorialView()
                                        }
                                    }
                            }
                            .environmentObject(router)
                        }
                        
                    }

                }
        }
                }
            }
            




