//
//  ExamplePagesView.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 13/06/25.
//

import SwiftUI



struct RecordAnalysisView: View {
    @State private var lastVideoURL: URL? = nil
    @State private var showCamera = true
    @StateObject private var vm = RecordFeatureViewModel()
    @State private var reportView: Bool = false
    
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
                        vm.extractAllFramesProcess(from: url)
                        reportView = true
                    }
                }
            }
            else if reportView {
                ReportView(vm: vm)
            }
            else{
                RecordLoadingView()
            }
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }
}

#Preview {
    RecordAnalysisView()
        .environmentObject(Router())
}
