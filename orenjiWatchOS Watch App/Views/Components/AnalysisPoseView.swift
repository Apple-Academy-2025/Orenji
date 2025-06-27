//
//  AnalysisPoseView.swift
//  orenji
//
//  Created by Muhamad Fannan Najma Falahi on 22/06/25.
//

import SwiftUI

struct AnalysisPoseView: View {
    @ObservedObject var connectivity = WatchConnectivityManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            if let data = connectivity.realtimePoseData {
                VStack(spacing: 8) {
                    Text(data.phase.uppercased())
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                    
                    Spacer()
                    imageForPhase(data.phase, isCorrect: data.isPoseCorrect)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                }
                .padding()
                .frame(maxHeight: .infinity)
                .frame(width: 130)
                .background(data.isPoseCorrect ? .primerGreen.opacity(0.2) : .primer.opacity(0.2))
                .cornerRadius(16)
                
                Spacer()
                
                if let message = data.correctionMessage {
                    Text(message)
                        .font(.title3.bold())
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                } else if let countdown = data.holdCountdown {
                    Text("Hold Position in \(countdown)")
                        .font(.title3.bold())
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                }
            } else {
                Text("Waiting for pose data...")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            
            Spacer()
        }
        .padding()
        .animation(.easeInOut, value: connectivity.realtimePoseData?.isPoseCorrect)
    }
    
    private func imageForPhase(_ phase: String, isCorrect: Bool) -> Image {
        let formattedPhase = phase.lowercased()
        let suffix = isCorrect ? "Good" : "Bad"
        let imageName = "\(formattedPhase)\(suffix)"
        if UIImage(named: imageName) != nil {
            return Image(imageName)
        } else {
            return Image(systemName: "figure.stand")
        }
    }
}
