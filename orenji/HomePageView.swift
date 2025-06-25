//
//  HomePageView.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 13/06/25.
//

import SwiftUI

struct HomePageView: View {
    @EnvironmentObject var router: Router

    var body: some View {
        VStack(spacing: 20) {
            Text("🏠 Home Page").font(.largeTitle)
            
            Button("Go to History "){
                router.goTo(.History)
            }

            Button("🔵 Go to Record") {
                router.goTo(.Instruksi(destination: .RecordPose(titlePage: "Record"), idPage: "record"))
            }

            Button("⚙️ Go to Realtime") {
                router.goTo(.Instruksi(destination: .RealtimePose(titlePage: "Realtime"), idPage: "realtime"))
            }

        }
        .padding()
    }
}

#Preview {
    HomePageView()
        .environmentObject(Router())
}
