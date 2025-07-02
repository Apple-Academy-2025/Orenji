//
//  TutorialView.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 22/06/25.
//

import SwiftUI
import AVKit

struct TutorialView: View {
    @EnvironmentObject var router: Router
    var destination: Route
    var onStart: (() -> Void)? = nil
    
    private let player = AVPlayer(url: Bundle.main.url(forResource: "video-tutorial-postur", withExtension: "mp4")!)
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                VideoPlayer(player: player)
                    .aspectRatio(contentMode: .fill)
                    .frame(height: UIScreen.main.bounds.height * 0.7)
                    .clipped()
                    .onAppear {
                        player.play()
                        player.actionAtItemEnd = .none
                        NotificationCenter.default.addObserver(
                            forName: .AVPlayerItemDidPlayToEndTime,
                            object: player.currentItem,
                            queue: .main
                        ) { _ in
                            player.seek(to: .zero)
                            player.play()
                        }
                    }
                
                HStack {
                    VStack(spacing: 8) {
                        Text("Do your shot step by step!")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                        Text("HOW TO FREE-THROW")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top,20)
                    .frame(width: 301)
                    .offset(x:27)
                    
                    Button(action: {
                        onStart?() // optional callback
                        router.goTo(destination) // navigasi ke tujuan
                    }) {
                        Text("Start")
                            .foregroundColor(.black)
                            .font(.system(size: 24, weight: .semibold))
                            .frame(width: 95, height: 46)
                            .background(Color.orange)
                            .cornerRadius(12)
                            .offset(y:32)
                    }
                    .padding(.trailing,80)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}




//#Preview {
//    TutorialView(destination: "destination")
//        .environmentObject(Router())
//}
