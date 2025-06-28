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
        let phase = PhaseModel(
            name: frameData.label ?? "",
            image: "",
            elbowAngle: frameData.elbowAngle ?? 0,
            legAngle: frameData.kneeAngle ?? 0,
            improvements: [
                "Elbow feedback otomatis di sini",
                "Knee feedback otomatis di sini"
            ],
            imageModel: frameData.imageForDisplay
        )
        return RecordAnalysisModel(date: Date(), phases: [phase])
    }
}

#Preview {
    RecordAnalysisView()
        .environmentObject(Router())
}
