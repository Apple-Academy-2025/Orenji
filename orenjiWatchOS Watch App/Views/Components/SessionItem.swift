//
//  SessionItem.swift
//  orenji
//
//  Created by Muhamad Fannan Najma Falahi on 21/06/25.
//

import SwiftUI

struct SessionItemView: View {
    let session: RecordAnalysisModel
    @ObservedObject var connectivity = WatchConnectivityManager.shared
    
    var body: some View {
        VStack {
            ScrollView {
                ZStack(alignment: .top) {
                    Image("image1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange, lineWidth: 2)
                        )
                        .overlay(
                            Text("Preparation")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(.black.opacity(0.6))
                                .clipShape(RoundedRectangle(cornerRadius: 10)),
                            alignment: .bottom
                        )
                }
                .padding(.vertical,20)
                .padding(.horizontal)
                ForEach(session.phases) { item in
                    VStack {
                            ResultItemView(
                                title: "Elbow",
                                angle: Int(item.elbowAngle ?? 0),
                                improvement: item.improvements[0]
                            )
                            .padding()

                            ResultItemView(
                                title: "Leg",
                                angle: Int(item.legAngle ?? 0),
                                improvement: item.improvements[1]
                            )
                            .padding()
                        }
                }
                Button(action: {
                    connectivity.resetToIdle()
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SessionItemView(session: RecordAnalysisModel(
        date: Date(),
        phases: [
            PhaseModel(name: "Preparation", image: "",elbowAngle: 60,legAngle: 80, improvements: ["Good form on the elbow, keep it up!","The knee bend was shallow."])
        ]
    ))
}


