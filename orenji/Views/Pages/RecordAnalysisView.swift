//
//  ExamplePagesView.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 13/06/25.
//

import SwiftUI



struct RecordAnalysisView: View {
    @EnvironmentObject var router: Router
    @Environment(\.modelContext) private var modelContext
    @State private var lastVideoURL: URL? = nil
    @State private var showCamera = true
    @StateObject private var vm = RecordFeatureViewModel()
    @State private var reportView: Bool = false
    @StateObject var connectivity = WatchConnectivityManager.shared
    
    var body: some View {
        ZStack {
            if vm.isExtracting {
                RecordLoadingView()
            }
            else if vm.isProcessingML {
                RecordLoadingView()
                
            }
            else if showCamera {
                RecordPageCameraFrame(showCamera: $showCamera) { url in
                    DispatchQueue.main.async {
                        vm.extractAllFramesProcess(from: url, completion: {
                            reportView = true
                        })
                    }
                }
            }
            else if reportView {
                ReportView(vm: vm, reportView: $reportView, showCamera: $showCamera)
                    .environmentObject(router)
                    .onAppear {
                        vm.konversiSemuaPredictionKeFrameData()
                        let allAnalysisResults = vm.bestFrameData.map { phaseModel(for: $0) }
                        connectivity.sendAnalysisResultsToWatch(sessions: allAnalysisResults)
                        vm.simpanKeDataset(context: modelContext, frames: vm.bestFrameData, date: Date.now)
                    }
            }
        }
        .environmentObject(Router())
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }
    
    private func phaseModel(for frameData: FrameData) -> RecordAnalysisModel {
        let phaseName = frameData.label ?? "Unknown"
        let elbowImprovements = generateElbowFeedback(angle: frameData.elbowAngle, phase: phaseName)
        let kneeImprovements = generateKneeFeedback(angle: frameData.kneeAngle, phase: phaseName)
        let phase = PhaseModel(
            name: frameData.label ?? "",
            image: "",
            elbowAngle: frameData.elbowAngle ?? 0,
            legAngle: frameData.kneeAngle ?? 0,
            improvements: [
                elbowImprovements[0] ,
                kneeImprovements[0]
            ],
            imageModel: frameData.imageForDisplay
        )
        return RecordAnalysisModel(date: Date(), phases: [phase])
    }
    
    private func generateElbowFeedback(angle: Double?, phase: String) -> [String] {
        guard let angle = angle else {
            return ["Elbow angle not detected.", ""]
        }
        
        switch phase.lowercased() {
        case "preparation":
            return elbowFeedback(angle: angle, low: 86, high: 93)
        case "bending":
            return elbowFeedback(angle: angle, low: 75, high: 90)
        case "followthrough":
            return elbowFeedback(angle: angle, low: 160, high: 170)
        default:
            return ["Unknown phase for elbow feedback.", ""]
        }
    }
    
    private func generateKneeFeedback(angle: Double?, phase: String) -> [String] {
        guard let angle = angle else {
            return ["Knee angle not detected.", ""]
        }
        
        switch phase.lowercased() {
        case "preparation":
            return kneeFeedback(angle: angle, low: 160, high: 160)
        case "bending":
            return kneeFeedback(angle: angle, low: 124, high: 124)
        case "followthrough":
            return kneeFeedback(angle: angle, low: 160, high: 160)
        default:
            return ["Unknown phase for knee feedback.", ""]
        }
    }
    
    private func elbowFeedback(angle: Double, low: Double, high: Double) -> [String] {
        let needImprovement = (angle < low || angle > high)
        return [
            needImprovement ? "Should be close to \(Int(low))°–\(Int(high))°" : "Already close to \(Int(low))°–\(Int(high))°",
            feedbackMethod(angle: Int(angle), lowAngle: Int(low), highAngle: Int(high), whatAngle: "elbow")
        ]
    }

    private func kneeFeedback(angle: Double, low: Double, high: Double) -> [String] {
        let needImprovement = (angle < low || angle > high)
        return [
            needImprovement ? "Should be close to \(Int(low))°" : "Already close to \(Int(low))°",
            feedbackMethod(angle: Int(angle), lowAngle: Int(low), highAngle: Int(high), whatAngle: "leg")
        ]
    }

    
}

#Preview {
    RecordAnalysisView()
        .environmentObject(Router())
}
