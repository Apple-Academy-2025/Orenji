//
//  RecordLoadingView.swift
//  RecordFeature
//
//  Created by Fariz Ajy Putra on 22/06/25.
//

import SwiftUI
import AVKit

struct RecordLoadingView: View {
    @State private var player: AVPlayer? = nil
    @State private var dotCount = 0

    let dotTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 24) {
                if let player = player {
                      VideoPlayer(player: player)
                          .frame(width: 350, height: 350)
                          .clipShape(Circle())
                          .onAppear {
                              player.play()
                              NotificationCenter.default.addObserver(
                                  forName: .AVPlayerItemDidPlayToEndTime,
                                  object: player.currentItem,
                                  queue: .main
                              ) { _ in
                                  player.seek(to: .zero)
                                  player.play()
                              }
                          }
                  } else {
                      Text("Video not found").foregroundColor(.white)
                  }
                Text("Hold on while we check your form" + String(repeating: ".", count: dotCount))
                    .font(.system(size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .onReceive(dotTimer) { _ in
                        dotCount = (dotCount + 1) % 4
                    }
              }
              .onAppear {
                  if let url = Bundle.main.url(forResource: "recording-analysis-loading-screen", withExtension: "mp4") {
                      player = AVPlayer(url: url)
                  }
              }

            }
            .padding(32)
        }
    }

#Preview {
    RecordLoadingView()
}
