//
//  EvaluationFinishedView.swift
//  orenji
//
//  Created by Muhamad Fannan Najma Falahi on 04/07/25.
//

import SwiftUI

struct EvaluationFinishedView: View {
    @EnvironmentObject var router: Router
    var loopCount: Int
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("✅ You have completed")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text("\(loopCount) phase\(loopCount > 1 ? "s" : "")!")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.green)
                
                Button(action: {
                    router.pop()
                }) {
                    Text("Done")
                        .font(.headline)
                        .padding()
                        .frame(width: 120)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
            .padding()
            .background(Color.black.opacity(0.75))
            .cornerRadius(20)
            .padding(.horizontal, 40)
        }
    }
    
}
