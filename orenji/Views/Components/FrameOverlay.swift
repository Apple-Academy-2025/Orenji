//
//  FrameOverlay.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 23/06/25.
//

import SwiftUI

struct FrameOverlay: View {
    var boxSize: CGSize
    var borderColor: Color

    var body: some View {
        GeometryReader { geo in
            let screen = geo.size
            let boxWidth = screen.width * 0.8
            let boxHeight = screen.height * 0.7
            let boxX = (screen.width - boxWidth) / 2
            let boxY = (screen.height - boxHeight) / 2 + 60

            ZStack {
                Color.black.opacity(0.45)
                RoundedRectangle(cornerRadius: 24)
                    .blendMode(.destinationOut)
                    .frame(width: boxWidth, height: boxHeight)
                    .position(x: screen.width / 2, y: boxY + boxHeight / 2)

                RoundedRectangle(cornerRadius: 24)
                    .stroke(borderColor, style: StrokeStyle(lineWidth: 4, dash: [8, 6]))
                    .frame(width: boxWidth, height: boxHeight)
                    .position(x: screen.width / 2, y: boxY + boxHeight / 2)
            }
            .compositingGroup()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    FrameOverlay(
        boxSize: CGSize(width: 250, height: 500),
        borderColor: .blue
    )
}
