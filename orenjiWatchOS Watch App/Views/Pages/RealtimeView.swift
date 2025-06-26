//
//  RealtimeView.swift
//  orenjiWatch Watch App
//
//  Created by Muhamad Fannan Najma Falahi on 22/06/25.
//

import SwiftUI

struct RealtimeView: View {
    @ObservedObject var connectivityManager = WatchConnectivityManager.shared
    var body: some View {
        TabView {
            AnalysisPoseView()
            if let image = connectivityManager.receivedImage {
                ZStack{
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                }
                .ignoresSafeArea()
            } else {
                ZStack{
                    Rectangle().foregroundColor(.gray.opacity(0.5))
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.largeTitle).foregroundColor(.white)
                    Text("Menunggu iPhone...").font(.caption).foregroundColor(.white).offset(y: 30)
                }
            }
            VStack(spacing: 8) {
                Button(action: {
                    connectivityManager.sendRealtimeAction(["endSessionChoice": true])
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.primerRed.opacity(0.2))
                        Image(systemName: "xmark")
                            .font(.system(size: 70, weight: .bold))
                            .foregroundColor(.primerRed)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                
                Text("End Session?")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
        }
        .tabViewStyle(.page)
        .navigationTitle(Text("Evaluate Realtime").foregroundColor(.blue))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    RealtimeView()
}
