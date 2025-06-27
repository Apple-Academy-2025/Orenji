//
//  DetailCardHistory.swift
//  orenji
//
//  Created by Fariz Ajy Putra on 27/06/25.
//

import SwiftUI
import SwiftData

struct DetailCardHistory: View {
    @EnvironmentObject var router: Router
    let prediction: FrameData
    let idx: Int

    var body: some View {
        let elbowAngle = Int(prediction.elbowAngle ?? 0)
        let legAngle = Int(prediction.kneeAngle ?? 0)

        VStack {
            if prediction.label?.lowercased() == "preparation"{
                if prediction.detectedDominant == nil {
                    CantAnalyzePoseComponent(onTap: {
                        router.pop()
                        router.goTo(.RealtimePose(titlePage: "Test"))
                    }, phase: prediction.label!)
                } else {
                    ReportHistory(
                        myImage: drawSkeleton(
                            image: convertDataToUIImage(prediction.imageForDisplay) ?? UIImage(),
                            handLineColor:(elbowAngle < 86 || elbowAngle > 93) ? .red : .green,
                            legLineColor:(elbowAngle < 160 || legAngle > 160) ? .red : .green
                        ),
                        phase: prediction.label ?? "-",
                        elbowAngle: elbowAngle,
                        elbowImprovement:
                            (elbowAngle < 86 || elbowAngle > 93) ? "Need\nImprovement" : "Pass",
                        elbowfeedback1:
                            (elbowAngle < 86 || elbowAngle > 93) ? "Should be close to 86°–93°" : "Already close to 86°–93°",
                        elbowfeedback2:
                            feedbackMethod(angle: elbowAngle, lowAngle: 86, highAngle: 93, whatAngle: "elbow"),
                        legAngle: legAngle,
                        legImprovement:
                            (legAngle < 160 || legAngle > 160) ? "Need\nImprovement" : "Pass",
                        legFeedback1:
                            (legAngle < 160 || legAngle > 160) ? "Should be close to 160°" : "Already close to 160°",
                        legFeedback2:
                            feedbackMethod(angle: legAngle, lowAngle: 160, highAngle: 160, whatAngle: "leg")
                    )
                    Spacer()
                }
            } else if prediction.label?.lowercased() == "bending" {
                if prediction.detectedDominant == nil {
                    CantAnalyzePoseComponent(onTap: {
                        router.pop()
                        router.goTo(.RealtimePose(titlePage: "Test"))
                    }, phase: prediction.label!)
                } else {
                    ReportHistory(
                        myImage: drawSkeleton(
                            image: convertDataToUIImage(prediction.imageForDisplay) ?? UIImage(),
                            handLineColor:(elbowAngle < 75 || elbowAngle > 90) ? .red : .green,
                            legLineColor:(elbowAngle < 160 || legAngle > 160) ? .red : .green
                        ),
                        phase: prediction.label ?? "-",
                        elbowAngle: elbowAngle,
                        elbowImprovement:
                            (elbowAngle < 75 || elbowAngle > 90) ? "Need\nImprovement" : "Pass",
                        elbowfeedback1:
                            (elbowAngle < 75 || elbowAngle > 90) ? "Should be close to 75°–93°" : "Already close to 86°–93°",
                        elbowfeedback2:
                            feedbackMethod(angle: elbowAngle, lowAngle: 86, highAngle: 93, whatAngle: "elbow"),
                        legAngle: legAngle,
                        legImprovement:
                            (legAngle < 124 || legAngle > 124) ? "Need\nImprovement" : "Pass",
                        legFeedback1:
                            (legAngle < 124 || legAngle > 124) ? "Should be close to 124°" : "Already close to 124°",
                        legFeedback2:
                            feedbackMethod(angle: legAngle, lowAngle: 160, highAngle: 160, whatAngle: "leg")
                    )
                    Spacer()
                }
            } else if prediction.label?.lowercased() == "followthrough" {
                if prediction.detectedDominant == nil {
                    CantAnalyzePoseComponent(onTap: {
                        router.pop()
                        router.goTo(.RealtimePose(titlePage: "Test"))
                    }, phase: prediction.label!)
                } else {
                    ReportHistory(
                        myImage: drawSkeleton(
                            image: convertDataToUIImage(prediction.imageForDisplay) ?? UIImage(),
                            handLineColor:(elbowAngle < 160 || elbowAngle > 170) ? .red : .green,
                            legLineColor:(elbowAngle < 160 || legAngle > 160) ? .red : .green
                        ),
                        phase: prediction.label ?? "-",
                        elbowAngle: elbowAngle,
                        elbowImprovement:
                            (elbowAngle < 160 || elbowAngle > 170) ? "Need\nImprovement" : "Pass",
                        elbowfeedback1:
                            (elbowAngle < 160 || elbowAngle > 170) ? "Should be close to 160°–170°" : "Already close to 160°–170°",
                        elbowfeedback2:
                            feedbackMethod(angle: elbowAngle, lowAngle: 86, highAngle: 93, whatAngle: "elbow"),
                        legAngle: legAngle,
                        legImprovement:
                            (legAngle < 160 || legAngle > 160) ? "Need\nImprovement" : "Pass",
                        legFeedback1:
                            (legAngle < 160 || legAngle > 160) ? "Should be close to 160°" : "Already close to 160°",
                        legFeedback2:
                            feedbackMethod(angle: legAngle, lowAngle: 160, highAngle: 160, whatAngle: "leg")
                    )
                    Spacer()
                }
            }
        }
        .tag(idx)
        .ignoresSafeArea()
    }
}

struct DetailCardView: View {
    @State private var showFullImage = false
    @State private var selectedTab: Int = 0
    @Query var phase: [PhaseData]
    let prediction: PhaseData

    // Urutan label yang diinginkan
    let order: [String] = ["Preparation", "Bending", "FollowThrough"]

    func orderedFrames() -> [FrameData] {
        prediction.frames.sorted {
            let first = $0.label?.lowercased() ?? ""
            let second = $1.label?.lowercased() ?? ""
            // urutkan berdasarkan urutan array 'order'
            return (order.firstIndex(of: first) ?? .max) < (order.firstIndex(of: second) ?? .max)
        }
    }

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

    var body: some View {
        // Pakai frames yang sudah diurutkan sesuai label
        let frames = orderedFrames()

        ZStack {
            VStack {
                TabView(selection: $selectedTab) {
                    ForEach(Array(frames.enumerated()), id: \.offset) { idx, phaseData in
                        DetailCardHistory(
                            prediction: phaseData,
                            idx: idx
                        )
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(alignment: .top)
                HStack {
                    ForEach(0..<frames.count, id: \.self) { idx in
                        if idx == selectedTab {
                            Capsule()
                                .frame(width: 24, height: 8)
                                .foregroundColor(.orange)
                        } else {
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundColor(.brown)
                        }
                    }
                }
                Spacer()
            }

            VStack {
                LinearGradient(colors: [Color.black.opacity(1), Color.black.opacity(0)], startPoint: .top, endPoint:.bottom )
                    .frame(height: 300)
                Spacer()
                LinearGradient(colors: [Color.black, Color(uiColor: UIColor(hex: "#FF7200")).opacity(0.5)], startPoint: .top, endPoint:.bottom )
                    .frame(height: 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack {
                ZStack {
                    Text("Report Analysis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    HStack{
                        Spacer()
                        Button {
                            showFullImage = true
                        } label: {
                            Image(systemName: "plus.magnifyingglass")
                                .font(.system(size: 27))
                                .foregroundColor(Color(uiColor: UIColor(hex: "#FF7200")))
                        }
                    }
                    .padding(.trailing, 16)
                    .frame(maxWidth: .infinity)
                }
                Spacer()
            }
            .padding(.top, 54)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fullScreenCover(isPresented: $showFullImage) {
            ZStack(alignment: .topLeading) {
                Color.black.ignoresSafeArea()

                if selectedTab < frames.count,
                   let uiImg = drawSkeleton(
                        image: convertDataToUIImage(frames[selectedTab].imageForDisplay) ?? UIImage(),
                        handLineColor: colorFunction(angle: Int(frames[selectedTab].elbowAngle ?? 0), whatAngle: "elbow\(String(describing: frames[selectedTab].label))"),
                        legLineColor: colorFunction(angle: Int(frames[selectedTab].elbowAngle ?? 0), whatAngle: "knee\(String(describing: frames[selectedTab].label))")
                   ) {
                    Image(uiImage: uiImg)
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea()
                } else {
                    Color.gray.opacity(0.3)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.white.opacity(0.7))
                        )
                        .ignoresSafeArea()
                }

                Button(action: { showFullImage = false }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.orange)
                    .padding(12)
                    .cornerRadius(24)
                    .padding(.top, 54)
                    .padding(.leading, 16)
                }
            }
        }
    }
}

// Fungsi convertDataToUIImage dan feedbackMethod tetap sama
func convertDataToUIImage(_ data: Data?) -> UIImage? {
    guard let data = data else { return nil }
    return UIImage(data: data)
}

func feedbackMethod(angle: Int, lowAngle: Int, highAngle: Int, whatAngle: String) -> String {
    if angle < lowAngle {
        return "Your \(whatAngle) was too low. Try to open more your elbow"
    } else if angle > highAngle {
        return "Your \(whatAngle) was too high. Try to close more your elbow"
    } else {
        return "Your \(whatAngle) fit perfectly on your posture"
    }
}
