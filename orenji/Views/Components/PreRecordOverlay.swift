//
//  PreRecordOverlay.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 24/06/25.
//

import SwiftUI

struct PreRecordOverlay: View {
    @EnvironmentObject var router: Router

    let isRecordingStarted: Bool
    let isOverlayVisible: Bool
    let isUserInFrame: Bool
    let holdSeconds: Int
    let showWarningText: Bool
    let warningText: String
    let warningScale: CGFloat
    let isCountingDown: Bool
    let countdown: Int
    let showStartText: Bool
    let boxSize: CGSize
    let borderColor: Color
    let statusText: String
    let statusTitle: String

    var body: some View {
        Group {
            if !isRecordingStarted && isOverlayVisible {
                FrameOverlay(boxSize: boxSize, borderColor: borderColor)

                


                VStack {
                    HStack {
                        Button { router.pop() } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.orange)
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding([.horizontal, .top], 20)
                    
                    GeometryReader { geo in
                        VStack() { // ⬅️ Tambahkan spacing
                            Text(statusTitle)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)

                            Text(statusText)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
    
                                .background(borderColor)
                                .cornerRadius(20)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .offset(y: -20)
                    }
                }
                
            }

            if !isRecordingStarted && isOverlayVisible && isUserInFrame {
                VStack(spacing: 8) {
                    Text("✅ Hold still...")
                        .foregroundColor(.green)
                        .bold()
                    Text("\(holdSeconds)")
                        .font(.title)
                        .foregroundColor(.green)
                }
                .offset(y: 180)
            }

            if showWarningText {
                VStack {
                    Text(warningText)
                        .font(.system(size: 40, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding()
                        .cornerRadius(16)
                        .scaleEffect(warningScale)
                        .opacity(showWarningText ? 1 : 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.scale.combined(with: .opacity))
            }

            if isCountingDown {
                Text("\(countdown)")
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(.primer)
            }

            if showStartText {
                Text("START!")
                    .font(.system(size: 100, weight: .heavy))
                    .foregroundColor(.white)
                    .transition(.opacity)
            }
        }
    }
}

#Preview {
    PreRecordOverlay(
        isRecordingStarted: false,
        isOverlayVisible: true,
        isUserInFrame: false,
        holdSeconds: 3,
        showWarningText: false,
        warningText: "Follow the instructions each phase!",
        warningScale: 1.0,
        isCountingDown: false,
        countdown: 3,
        showStartText: false,
        boxSize: CGSize(width: 250, height: 500),
        borderColor: .green,
        statusText: "Make sure to keep your ball and feet visible within the frame",
        statusTitle: "For best result"
    )
    .environmentObject(Router())
    .background(Color.black)
}

