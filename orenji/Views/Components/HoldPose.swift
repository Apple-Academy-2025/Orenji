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
    var correct: Bool

    
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

                
                VStack{
                    // Warning banner di ujung atas layar
                    if let message = warningMessage {
                        VStack(spacing: 0) {
                            Color.red.opacity(0.6)
                                .frame(height: 120) // tinggi minimal, seperti nav bar
                                .overlay(
                                    Text(message)
                                        .font(.system(size: 20, weight: .bold))
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
                    
                    
                }
                
               
                VStack(spacing: 8) {
                    // phaseTitle (selalu tampil, di bawah warning)
                    Text(phaseTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .offset(y:-90)
                    

                      
                    if correct {
                        Text("HOLD POSITION IN")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("\(Int((1 - holdProgress) * 3))") // hitung mundur dari 3 ke 0
                            .font(.system(size: 72, weight: .heavy))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * 0.45)

               
            }
            .edgesIgnoringSafeArea(.top) // pastikan banner naik ke top
        }
    }
}

