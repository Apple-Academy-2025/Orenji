//
//  CompanionAppNeededView.swift
//  orenji
//
//  Created by Muhamad Fannan Najma Falahi on 22/06/25.
//


import SwiftUI
import WatchKit

struct CompanionAppNeededView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Orenji app was closed on your iphone")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            Spacer()
        }
    }
}

#Preview {
    CompanionAppNeededView()
}
