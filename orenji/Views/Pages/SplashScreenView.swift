//
//  SplashScreenview.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 16/06/25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false

        var body: some View {
            VStack {
                Image("AppLogo")
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                Text("PostureBasket")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
}

#Preview {
    SplashScreenView()
}
