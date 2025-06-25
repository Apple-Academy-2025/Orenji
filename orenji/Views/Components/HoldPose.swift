//
//  HoldPose.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 24/06/25.
//

import SwiftUI


struct HoldPose: View {
    @EnvironmentObject var router: Router

    var phaseTitle: String
    var holdProgress: Double
    var warningMessage: String? // nil = tidak tampil
    var warningScale: CGFloat

    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background fill progress
                Rectangle()
                    .fill(Color.green.opacity(0.4))
                    .frame(height: geo.size.height * holdProgress)
                    .position(
                        x: geo.size.width / 2,
                        y: geo.size.height - (geo.size.height * holdProgress / 2)
                    )
                    .animation(.linear(duration: 0.1), value: holdProgress)

                // Warning banner di ujung atas layar
                if let message = warningMessage {
                    VStack(spacing: 0) {
                        Color.red
                            .frame(height: 120) // tinggi minimal, seperti nav bar
                            .overlay(
                                Text(message)
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .scaleEffect(warningScale)
                                    .offset(y:20)
                            )
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.25), value: warningScale)
                }

                VStack(spacing: 16) {
                    Spacer()
                    Text(phaseTitle)
                        .font(.title2)
                        .foregroundColor(.white)
                        .bold()
                    Text("Hold: \(Int(holdProgress * 100))%")
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.bottom, 40)

               
            }
            .edgesIgnoringSafeArea(.top) // pastikan banner naik ke top
        }
    }
}

