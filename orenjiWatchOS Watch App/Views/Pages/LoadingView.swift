//
//  LoadingView.swift
//  orenji
//
//  Created by Muhamad Fannan Najma Falahi on 20/06/25.
//


import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                CircularLoadingIndicator()
                Text("Hold on while\nwe check your form...")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }
            .padding()
        }
    }
}

struct CircularLoadingIndicator: View {
    private let dotCount = 8
    private let dotSize: CGFloat = 10
    private let spinnerRadius: CGFloat = 18
    
    @State private var activeIndex = 0
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            ForEach(0..<dotCount, id: \.self) { index in
                Circle()
                    .frame(width: dotSize, height: dotSize)
                    .foregroundColor(color(for: index))
                    .offset(y: -spinnerRadius)
                    .rotationEffect(.degrees(Double(index) * (360.0 / Double(dotCount))))
            }
        }
        .frame(width: spinnerRadius * 2, height: spinnerRadius * 2)
        .onReceive(timer) { _ in
            activeIndex = (activeIndex + 1) % dotCount
        }
    }
    
    private func color(for index: Int) -> Color {
        let offset = (dotCount + activeIndex - index) % dotCount
        let opacity = 1.0 - (Double(offset) * (1.0 / Double(dotCount)))
        return Color.white.opacity(max(0.15, opacity))
    }
}

#Preview {
    LoadingView()
}
