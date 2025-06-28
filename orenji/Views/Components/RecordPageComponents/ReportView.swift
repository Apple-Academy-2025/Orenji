//
//  Test.swift
//  orenji
//
//  Created by Fariz Ajy Putra on 25/06/25.
//


import SwiftUI
import SwiftData

struct ReportTabItem: View {
    @EnvironmentObject var router: Router
    let prediction: FramePrediction
    let idx: Int
    let selectedTab: Int
    let vm: RecordFeatureViewModel
    var body: some View {
        let elbowAngle = Int(prediction.elbowAngle ?? 0)
        let legAngle = Int(prediction.kneeAngle ?? 0)
        
        VStack {
            if vm.predictions[idx].label.lowercased() == "preparation"{
                if vm.predictions[idx].detectedDominant == nil {
                    CantAnalyzePoseComponent(onTap: {
//                        router.goTo(.RealtimePose(titlePage: "Test"))
                    }, phase: vm.predictions[idx].label)
                } else {
                    ReportComponent(
                        myImage: drawSkeleton(
                            image: prediction.imageForDisplay ?? UIImage(),
                            handLineColor:(elbowAngle < 86 || elbowAngle > 93) ? .red : .green,
                            legLineColor:(elbowAngle < 160 || elbowAngle > 160) ? .red : .green),
                        joints: prediction.joints,
                        phase: vm.predictions[idx].label,
                        elbowAngle: elbowAngle,
                        elbowImprovement:
                            (elbowAngle < 86 || elbowAngle > 93) ? "Need\nImprovement" : "Pass",
                        elbowfeedback1:
                            (elbowAngle < 86 || elbowAngle > 93) ? "Should be close to 86°–93°" : "Already close to 86°–93°",
                        elbowfeedback2:
                            vm.feedbackMethod(angle: elbowAngle, lowAngle: 86, highAngle: 93, whatAngle: "elbow"),
                        legAngle: legAngle,
                        legImprovement:
                            (legAngle < 160 || legAngle > 160) ? "Need\nImprovement" : "Pass",
                        legFeedback1:
                            (legAngle < 160 || legAngle > 160) ? "Should be close to 160°" : "Already close to 160°",
                        legFeedback2:
                            vm.feedbackMethod(angle: legAngle, lowAngle: 160, highAngle: 160, whatAngle: "leg")
                    )
                    Spacer()
                }
            } else if vm.predictions[idx].label.lowercased() == "bending" {
                if vm.predictions[idx].detectedDominant == nil {
                    CantAnalyzePoseComponent(onTap: {
//                        router.goTo(.RealtimePose(titlePage: "Test"))
                    }, phase: vm.predictions[idx].label)
                }else{
                    ReportComponent(
                        myImage: drawSkeleton(
                            image: prediction.imageForDisplay ?? UIImage(),
                            handLineColor:(elbowAngle < 75 || elbowAngle > 90) ? .red : .green,
                            legLineColor:(elbowAngle < 160 || elbowAngle > 160) ? .red : .green),
                        joints: prediction.joints,
                        phase: vm.predictions[idx].label,
                        elbowAngle: elbowAngle,
                        elbowImprovement:
                            (elbowAngle < 75 || elbowAngle > 90) ? "Need\nImprovement" : "Pass",
                        elbowfeedback1:
                            (elbowAngle < 75 || elbowAngle > 90) ? "Should be close to 75°–93°" : "Already close to 86°–93°",
                        elbowfeedback2:
                            vm.feedbackMethod(angle: elbowAngle, lowAngle: 86, highAngle: 93, whatAngle: "elbow"),
                        legAngle: legAngle,
                        legImprovement:
                            (legAngle < 124 || legAngle > 124) ? "Need\nImprovement" : "Pass",
                        legFeedback1:
                            (legAngle < 124 || legAngle > 124) ? "Should be close to 124°" : "Already close to 124°",
                        legFeedback2:
                            vm.feedbackMethod(angle: legAngle, lowAngle: 160, highAngle: 160, whatAngle: "leg")
                    )
                    Spacer()
                }

            } else if vm.predictions[idx].label.lowercased() == "followthrough" {
                if vm.predictions[idx].detectedDominant == nil {
                    CantAnalyzePoseComponent(
                        onTap: {
//                            router.goTo(.RealtimePose(titlePage: "Test"))
                        },
                        phase: vm.predictions[idx].label)
                }else{
                    ReportComponent(
                        myImage: drawSkeleton(
                            image: prediction.imageForDisplay ?? UIImage(),
                            handLineColor:(elbowAngle < 160 || elbowAngle > 170) ? .red : .green,
                            legLineColor:(elbowAngle < 160 || elbowAngle > 160) ? .red : .green),
                        joints: prediction.joints,
                        phase: vm.predictions[idx].label,
                        elbowAngle: elbowAngle,
                        elbowImprovement:
                            (elbowAngle < 160 || elbowAngle > 170) ? "Need\nImprovement" : "Pass",
                        elbowfeedback1:
                            (elbowAngle < 160 || elbowAngle > 170) ? "Should be close to 160°–170°" : "Already close to 160°–170°",
                        elbowfeedback2:
                            vm.feedbackMethod(angle: elbowAngle, lowAngle: 86, highAngle: 93, whatAngle: "elbow"),
                        legAngle: legAngle,
                        legImprovement:
                            (legAngle < 160 || legAngle > 160) ? "Need\nImprovement" : "Pass",
                        legFeedback1:
                            (legAngle < 160 || legAngle > 160) ? "Should be close to 160°" : "Already close to 160°",
                        legFeedback2:
                            vm.feedbackMethod(angle: legAngle, lowAngle: 160, highAngle: 160, whatAngle: "leg")
                    )
                    Spacer()
                }
            }
        }
        .tag(idx)
        .ignoresSafeArea()
    }
}



struct ReportView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var connectivity = WatchConnectivityManager.shared
    @EnvironmentObject var router: Router
    @ObservedObject var vm: RecordFeatureViewModel
    @State private var showFullImage = false
    @Binding var reportView: Bool
    @Binding var showCamera : Bool
    @State private var selectedTab: Int = 0
    @Query var phase: [PhaseData]
    
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
        ZStack {
            if !vm.predictions.isEmpty && vm.predictions.allSatisfy({ $0.detectedDominant == nil }) {
                CantAnalyzeAllComponent()
            } else {
                TabView(selection: $selectedTab) {
                    ForEach(Array(vm.predictions.enumerated()), id: \.offset) { idx, prediction in
                        ReportTabItem(
                            prediction: prediction,
                            idx: idx,
                            selectedTab: selectedTab,
                            vm: vm
                        ).environmentObject(router)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(alignment: .top)
            }


            
            VStack {
                LinearGradient(colors: [Color.black.opacity(1), Color.black.opacity(0)], startPoint: .top, endPoint:.bottom )
                    .frame(height: 300)
                Spacer()
                LinearGradient(colors: [Color.black, Color(uiColor: UIColor(hex: "#FF7200")).opacity(0.5)], startPoint: .top, endPoint:.bottom )
                    .frame(height: 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack{
                Spacer()
                HStack{
                    if !vm.predictions.isEmpty && vm.predictions.allSatisfy({ $0.detectedDominant == nil }) {
                    }else{
                        ForEach(0..<vm.predictions.count, id: \.self) { idx in
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
                    

                }
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                VStack(spacing: 16) {
                    Button("Back to Home") {
                        router.pop()
                        reportView.toggle()
                        vm.lastVideoURL = nil
                        vm.frames = []
                        vm.frameTimes = []
                        vm.predictions = []
                        vm.bestFrame = []
                        vm.bestFrameData = []
                    }
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(uiColor: UIColor(hex: "#FF7200")))
                    .cornerRadius(12)
                    .padding(.horizontal, 48)
                    
                    Button("Try record analysis again") {
                        reportView.toggle()
                        showCamera.toggle()
                        vm.lastVideoURL = nil
                        vm.frames = []
                        vm.frameTimes = []
                        vm.predictions = []
                        vm.bestFrame = []
                        vm.bestFrameData = []
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.orange)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 32)
            
            VStack {
                ZStack {
                    Text("Report Analysis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    HStack{
                        Spacer()
                        Button {
                            showFullImage = true
                        } label:
                        {
                            if !vm.predictions.isEmpty && vm.predictions.allSatisfy({ $0.detectedDominant == nil }) {
                            }else{
                                Image(systemName: "plus.magnifyingglass")
                                    .font(.system(size: 27))
                                    .foregroundColor(Color(uiColor: UIColor(hex: "#FF7200")))
                            }
                            

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
                
                if let uiImg =
                    drawSkeleton(
                        image: vm.predictions[selectedTab].imageForDisplay ?? UIImage(),
                        handLineColor:colorFunction(angle: Int(vm.predictions[selectedTab].elbowAngle ?? 0),whatAngle:"elbow\(vm.predictions[selectedTab].label)" ),
                        legLineColor:colorFunction(angle: Int(vm.predictions[selectedTab].elbowAngle ?? 0),whatAngle:"knee\(vm.predictions[selectedTab].label)" )
                    )
                {
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

