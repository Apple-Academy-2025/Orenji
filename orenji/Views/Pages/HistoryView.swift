//
//  HistoryView.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 16/06/25.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @EnvironmentObject var router: Router
    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor(\PhaseData.date, order: .reverse)])
    var PhaseDatas: [PhaseData]
    @State private var selectedTab: Int = 0
    @StateObject var connectivity = WatchConnectivityManager.shared
    
    func colorFunction(angle: Int, whatAngle: String) -> UIColor {
        if whatAngle == "elbowPreparation" {
            if angle < 86 {
                return .red
            } else if angle > 93 {
                return .red
            } else {
                return .green
            }
        } else if whatAngle == "kneePreparation" {
            if angle < 160 {
                return .red
            } else if angle > 160 {
                return .red
            } else {
                return .green
            }
        } else if whatAngle == "elbowBending" {
            if angle < 75 {
                return .red
            } else if angle > 90 {
                return .red
            } else {
                return .green
            }
        } else if whatAngle == "kneeBending" {
            if angle < 124 {
                return .red
            } else if angle > 124 {
                return .red
            } else {
                return .green
            }
        } else if whatAngle == "elbowFollowThrough" {
            if angle < 160 {
                return .red
            } else if angle > 170 {
                return .red
            } else {
                return .green
            }
        } else if whatAngle == "kneeFollowThrough" {
            if angle < 160 {
                return .red
            } else if angle > 160 {
                return .red
            } else {
                return .green
            }
        }
        return .gray // fallback jika label tidak cocok
    }
    
    var body: some View {
        ZStack() {
            if PhaseDatas.isEmpty {
                ZStack {
                    EmptyView()
                    VStack() {
                        VStack {
                            HStack() {
                                Text("Record History")
                                    .foregroundColor(.white)
                                    .font(.system(size: 28, weight: .bold))
                                Spacer()
                            }.padding(.top,24)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                ScrollView{
                    VStack() {
                        VStack {
                            Button(action: {
                                dismiss()
                                connectivity.sendIdleState()}
                            ) {
                                    HStack(spacing: 4) {

                                        Image(systemName: "chevron.left")
                                        Text("Back")
                                        Spacer()
                                    }
                                    .foregroundColor(.orange)
                                    .cornerRadius(24)
                                }
                            HStack() {
                                Text("Record History")
                                    .padding(.top,24)
                                    .foregroundColor(.white)
                                    .font(.system(size: 28, weight: .bold))
                                Spacer()
                            }
                            Spacer().frame(height: 42)
                            
                            ForEach(Array(PhaseDatas), id: \.self) { phaseData in
                                cardHistoryView(for: phaseData,selectedTab: $selectedTab)
                            }

                        }
                        Spacer()
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .background(Color.black)
    }
}

#Preview {
    HistoryView()
}


private func cardHistoryView(for phaseData: PhaseData, selectedTab: Binding<Int>) -> some View {
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    // Cari frame berdasarkan label
    let framePreparation = phaseData.frames.first(where: { $0.label?.lowercased() == "preparation" })
    let frameBending = phaseData.frames.first(where: { $0.label?.lowercased() == "bending" })
    let frameFollowThrough = phaseData.frames.first(where: { $0.label?.lowercased() == "followthrough" })
    
    let prepElbow = String(framePreparation?.elbowAngle ?? 0)
    let prepLeg = String(framePreparation?.kneeAngle ?? 0)
    let bendElbow = String(frameBending?.elbowAngle ?? 0)
    let bendLeg = String(frameBending?.kneeAngle ?? 0)
    let ftElbow = String(frameFollowThrough?.elbowAngle ?? 0)
    let ftLeg = String(frameFollowThrough?.kneeAngle ?? 0)
    
    let prepElbowColor = colorFunction(angle: Int(framePreparation?.elbowAngle ?? 0), whatAngle: "elbowPreparation")
    let prepLegColor = colorFunction(angle: Int(framePreparation?.kneeAngle ?? 0), whatAngle: "kneePreparation")
    let bendElbowColor = colorFunction(angle: Int(frameBending?.elbowAngle ?? 0), whatAngle: "elbowBending")
    let bendLegColor = colorFunction(angle: Int(frameBending?.kneeAngle ?? 0), whatAngle: "kneeBending")
    let ftElbowColor = colorFunction(angle: Int(frameFollowThrough?.elbowAngle ?? 0), whatAngle: "elbowFollowThrough")
    let ftLegColor = colorFunction(angle: Int(frameFollowThrough?.kneeAngle ?? 0), whatAngle: "kneeFollowThrough")
    let timeString = phaseData.date.map { dateFormatter.string(from: $0) } ?? "Unknown"
    
    func colorFunction(angle: Int, whatAngle: String) -> UIColor {
        if whatAngle == "elbowPreparation" {
            if angle < 86 { return .red }
            else if angle > 93 { return .red }
            else { return .green }
        } else if whatAngle == "kneePreparation" {
            if angle < 160 { return .red }
            else if angle > 160 { return .red }
            else { return .green }
        } else if whatAngle == "elbowBending" {
            if angle < 75 { return .red }
            else if angle > 90 { return .red }
            else { return .green }
        } else if whatAngle == "kneeBending" {
            if angle < 124 { return .red }
            else if angle > 124 { return .red }
            else { return .green }
        } else if whatAngle == "elbowFollowThrough" {
            if angle < 160 { return .red }
            else if angle > 170 { return .red }
            else { return .green }
        } else if whatAngle == "kneeFollowThrough" {
            if angle < 160 { return .red }
            else if angle > 160 { return .red }
            else { return .green }
        }
        return .gray // fallback jika label tidak cocok
    }
    
    return CardHistory(
        preparationElbow: prepElbow,
        preparationLeg: prepLeg,
        bendingElbow: bendElbow,
        bendingLeg: bendLeg,
        followThroughElbow: ftElbow,
        followThroughLeg: ftLeg,
        preparationElbowColor: prepElbowColor,
        preparationLegColor: prepLegColor,
        bendingElbowColor: bendElbowColor,
        bendingLegColor: bendLegColor,
        followThroughElbowColor: ftElbowColor,
        followThroughLegColor: ftLegColor,
        Time: timeString,
        PhaseDatas: phaseData,
        selectedTab: selectedTab
    )
}
