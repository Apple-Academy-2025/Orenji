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
                    if let data = session.phases.first?.imageModel, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
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
                                Text(session.phases.first?.name ?? "")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(.black.opacity(0.6))
                                    .clipShape(RoundedRectangle(cornerRadius: 10)),
                                alignment: .bottom
                            )
                    }
                }
                .padding(.vertical,20)
                .padding(.horizontal)
                ForEach(session.phases) { item in
                    VStack {
                        let (_, elbowTarget) = targetAndTitle(for: "elbow", phaseName: item.name.lowercased())
                        let (_, legTarget) = targetAndTitle(for: "leg", phaseName: item.name.lowercased())
                                                
                            ResultItemView(
                                title: "Elbow",
                                angle: Int(item.elbowAngle ?? 0),
                                improvement: item.improvements[0],
                                target: elbowTarget
                            )
                            .padding()

                            ResultItemView(
                                title: "Leg",
                                angle: Int(item.legAngle ?? 0),
                                improvement: item.improvements[1],
                                target: legTarget
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
    
    private func targetAndTitle(for bodyPart: String, phaseName: String) -> (String, Int) {
            switch (bodyPart.lowercased(), phaseName.lowercased()) {
            case ("elbow", "preparation"):
                return ("Elbow Position", 90)
            case ("elbow", "bending"):
                return ("Elbow Depth", 90)
            case ("elbow", "release"):
                return ("Elbow Finish", 160)
            case ("leg", "preparation"):
                return ("Leg Stand", 160)
            case ("leg", "bending"):
                return ("Leg Bend", 118)
            case ("leg", "release"):
                return ("Leg Follow Through", 160)
            default:
                return ("Unknown", 0)
            }
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


