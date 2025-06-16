//
//  ExamplePagesView.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 13/06/25.
//

import SwiftUI

struct EvaluateRealtimeView: View {
    
    let titlePage: String
        @EnvironmentObject var router: Router

        var body: some View {
            VStack(spacing: 20) {
                Text("👤 Pages : \(titlePage)").font(.title)

                Button("🔙 Back") {
                    router.pop()
                }
            }
            .padding()
        }
}

#Preview {
    EvaluateRealtimeView(titlePage: "Realtime")
        .environmentObject(Router())
}
