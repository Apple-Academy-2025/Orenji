//
//  HistoryDetailView.swift
//  orenji
//
//  Created by Fariz Ajy Putra on 27/06/25.
//

import SwiftUI

struct HistoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State var PhaseDatas: PhaseData
    @State var selectedTab: Int = 0
    @State var Number : Int = 0
    @State var showFullImage: Bool = false
    
    // Urutan label yang diinginkan
    let labelOrder = ["preparation", "bending", "followthrough"]
    
    // Sorted frames berdasarkan label
    var sortedFrames: [FrameData] {
        PhaseDatas.frames.sorted {
            let idx0 = labelOrder.firstIndex(of: $0.label?.lowercased() ?? "") ?? Int.max
            let idx1 = labelOrder.firstIndex(of: $1.label?.lowercased() ?? "") ?? Int.max
            return idx0 < idx1
        }
    }
    
    var body: some View {
        // Agar aman saat frames kosong, jangan akses selectedTab di luar range
        let elbowAngle = selectedTab < sortedFrames.count ? Int(sortedFrames[selectedTab].elbowAngle ?? 0) : 0
        let legAngle = selectedTab < sortedFrames.count ? Int(sortedFrames[selectedTab].kneeAngle ?? 0) : 0
        
        ZStack {
            VStack {
                // Kalau semua frame tidak bisa dianalisis atau kosong
                if sortedFrames.isEmpty || sortedFrames.allSatisfy({ $0.detectedDominant == nil }) {
                    CantAnalyzeAllComponent()
                } else {
                    TabView(selection: $selectedTab) {
                        ForEach(Array(sortedFrames.enumerated()), id: \.offset) { idx, prediction in
                            DetailCardHistory(prediction: prediction, idx: idx)
                        }
                    }
                    .tag(selectedTab)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(alignment: .top)
                }
            }
            VStack {
                LinearGradient(colors: [Color.black.opacity(1), Color.black.opacity(0)], startPoint: .top, endPoint: .bottom)
                    .frame(height: 300)
                Spacer()
                LinearGradient(colors: [Color.black, Color(uiColor: UIColor(hex: "#FF7200")).opacity(0.5)], startPoint: .top, endPoint: .bottom)
                    .frame(height: 30)
            }
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack {
                Spacer()
                if sortedFrames.isEmpty || sortedFrames.allSatisfy({ $0.detectedDominant == nil }) {
                }else{
                    HStack {
                        ForEach(0..<sortedFrames.count, id: \.self) { idx in
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
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 32)
            
            VStack {
                ZStack {
                    Text("Report Analysis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(.system(size: 16))
                            .foregroundColor(Color(uiColor: UIColor(hex: "#FF7200")))
                        }
                        Spacer()
                        if sortedFrames.isEmpty || sortedFrames.allSatisfy({ $0.detectedDominant == nil }) {
                        } else {
                            Button {
                                showFullImage = true
                            } label: {
                                Image(systemName: "plus.magnifyingglass")
                                    .font(.system(size: 26))
                                    .foregroundColor(Color(uiColor: UIColor(hex: "#FF7200")))
                            }
                        }
  
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                }
                Spacer()
            }
            .padding(.top, 54)
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
        .background(Color.black)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fullScreenCover(isPresented: $showFullImage) {
            ZStack(alignment: .topLeading) {
                if selectedTab < sortedFrames.count,
                   let uiImg = drawSkeleton(
                        image: convertDataToUIImage(sortedFrames[selectedTab].imageForDisplay) ?? UIImage(),
                        handLineColor: (elbowAngle < 75 || elbowAngle > 90) ? .red : .green,
                        legLineColor: (legAngle < 160 || legAngle > 160) ? .red : .green
                   ) {
                    Image(uiImage: uiImg)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            .ignoresSafeArea(edges: .all)
        }
    }
}


