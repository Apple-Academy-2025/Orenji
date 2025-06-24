//
//  HoldPose.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 24/06/25.
//

import SwiftUI

struct HoldPose: View {
    var phaseTitle: String
    var holdProgress: Double
    var showWarning: Bool
    var warningScale: CGFloat

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Rectangle()
                    .fill(Color.green.opacity(0.4))
                    .frame(height: geo.size.height * holdProgress)
                    .position(x: geo.size.width / 2,
                              y: geo.size.height - (geo.size.height * holdProgress / 2))
                    .animation(.linear(duration: 0.1), value: holdProgress)

                VStack(spacing: 16) {
                    Spacer()
                    Text(phaseTitle)
                        .font(.title2)
                        .foregroundColor(.white)
                        .bold()

                    Text("Hold: \(Int(holdProgress * 100))%")
                        .foregroundColor(.white)

                    if showWarning {
                        Text("⚠️ Raise your right hand!")
                            .foregroundColor(.red)
                            .bold()
                            .scaleEffect(warningScale)
                    }
                    Spacer()
                }
                .padding(.bottom, 40)
            }
        }
    }
}

