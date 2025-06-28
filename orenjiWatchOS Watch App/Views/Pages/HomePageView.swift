//
//  HomePageView.swift
//  orenji
//
//  Created by Muhamad Fannan Najma Falahi on 22/06/25.
//

import SwiftUI

struct HomePageView: View {
    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    @State private var path = [AppState]()
    
    var body: some View {
        ZStack{
            NavigationStack(path: $path) {
                IdleView()
                    .navigationDestination(for: AppState.self) { state in
                        switch state {
                        case .record:
                            RecordingView()
                                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                        case .resultRecord:
                            ResultRecordView()
                                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        case .resultRealtime:
                            ResultRealtimeView()
                                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        case .idle:
                            EmptyView()
                        }
                    }
            }
            .onChange(of: connectivityManager.appState) { oldState, newState in
                if newState == .idle {
                    path.removeAll()
                } else if newState != oldState {
                    path = [newState]
                }
            }
            .onChange(of: path) { oldPath, newPath in
                if newPath.isEmpty && connectivityManager.appState != .idle {
                    connectivityManager.resetToIdle()
                }
            }
            
            if !connectivityManager.isCompanionAppReachable {
                CompanionAppNeededView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.edgesIgnoringSafeArea(.all))
                    .transition(.opacity.animation(.easeInOut))
            }
        }
    }
}

struct IdleView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "iphone")
                .font(.system(size: 80))
            Text("Start your shoot on your iOS app")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .navigationTitle("Orenji")
    }
}

#Preview {
    HomePageView()
}
