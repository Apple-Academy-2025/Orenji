//
//  ResultRecordView.swift
//  orenji
//
//  Created by Muhamad Fannan Najma Falahi on 26/06/25.
//

import SwiftUI

struct ResultRealtimeView: View {
    @StateObject var connectivity = WatchConnectivityManager.shared
    var body: some View {
        ScrollView{
            VStack(spacing: 8) {
                Spacer()
                VStack(spacing: 12) {
                    Text("Congratulations!")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(connectivity.realtimeResult ?? 0)")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(Color.green)
                    Text("Total of shoot with\ngreat posture!")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))

                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.sRGB, red: 0.15, green: 0.15, blue: 0.17))
                )
                
                Spacer()
                
                Button(action: {
                    connectivity.resetToIdle()
                    connectivity.sendRealtimeAction(["endSessionChoice": true])
                }) {
                    Text("Close")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: .infinity, height: 70)
                .background(.grayButton)
                .cornerRadius(.infinity)
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Evaluate Realtime")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    ResultRealtimeView()
}
