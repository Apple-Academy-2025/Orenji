//
//  RecordLoadingView.swift
//  RecordFeature
//
//  Created by Fariz Ajy Putra on 22/06/25.
//

import SwiftUI

struct RecordLoadingView: View {
    @State private var rotateBall = false
    @State private var dotCount = 0
    
    let dotTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 24) {
                Image("BasketBallIcon")
                    .resizable()
                    .frame(width: 64, height: 64)
                    .rotationEffect(.degrees(rotateBall ? 360 : 0))
                    .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: rotateBall)
                    .onAppear { rotateBall = true }

                Text("Hold on while we check your form" + String(repeating: ".", count: dotCount))
                    .font(.system(size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .onReceive(dotTimer) { _ in
                        dotCount = (dotCount + 1) % 4
                    }
            }
            .padding(32)
        }
    }
}

#Preview {
    RecordLoadingView()
}
