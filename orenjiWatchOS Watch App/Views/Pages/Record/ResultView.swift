


import SwiftUI

struct ResultRecordView: View {
    @State var isLoading: Bool = true
    @ObservedObject var connectivity = WatchConnectivityManager.shared

    var body: some View {
        ZStack {
            if isLoading {
                LoadingView()
                    .transition(.opacity.animation(.easeOut))
            } else if !connectivity.trainingSessions.isEmpty {
                let validSessions = connectivity.trainingSessions.filter { session in
                    session.phases.contains { $0.imageModel != nil && !($0.imageModel?.isEmpty ?? true) }
                }

                if validSessions.isEmpty {
                    fallbackText
                } else {
                    TabView {
                        ForEach(validSessions) { session in
                            SessionItemView(session: session)
                        }
                    }
                    .tabViewStyle(.page)
                }
            } else {
                fallbackText
            }
        }
        .navigationTitle("Report Analysis")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation {
                    isLoading = false
                }
            }
        }
        .animation(.easeInOut, value: isLoading)
    }

    private var fallbackText: some View {
        VStack {
            Spacer()
            Text("Start a session from your iPhone.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
    }
}



#Preview {
    ResultRecordView()
}
