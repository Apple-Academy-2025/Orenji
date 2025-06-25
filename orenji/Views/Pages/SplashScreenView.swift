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
                Spacer()
                Image("AppLogo") // LOGO
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.top,200)
               
                Spacer()
                Image("WaveSplash")
                    .scaledToFit()
                    .frame(width: 300, height:200)

            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
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
