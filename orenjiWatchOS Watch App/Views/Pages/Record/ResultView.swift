





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
                TabView {
                    ForEach(connectivity.trainingSessions) { session in
                        SessionItemView(session: session)
                    }
                }
                .tabViewStyle(.page)
            } else {
                Text("Start a session from your iPhone.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
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
}

#Preview {
    ResultRecordView()
}
