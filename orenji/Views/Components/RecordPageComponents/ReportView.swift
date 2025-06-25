//
//  ReportView.swift
//  RecordFeature
//
//  Created by Fariz Ajy Putra on 23/06/25.
//

import SwiftUI

struct ReportView: View {
    @ObservedObject var vm: RecordFeatureViewModel
    @State private var showFullImage = false
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
                VStack {
                        TabView(selection: $selectedTab) {
                            ForEach(0..<vm.predictions.count, id: \.self) { idx in
                                    ReportComponent(
                                        myImage: vm.predictions[idx].imageForDisplay,
                                        joints: vm.predictions[idx].joints,
                                        phase: vm.predictions[idx].label,
                                        elbowAngle: Int(vm.predictions[idx].elbowAngle ?? 0),
                                        elbowImprovement: "String",
                                        elbowfeedback1: "test",
                                        elbowfeedback2: "Halo",
                                        legAngle: Int(vm.predictions[idx].kneeAngle ?? 0),
                                        legImprovement: "String",
                                        legFeedback1: "String",
                                        legFeedback2: "String"
                                    )
                                
                                .tag(idx)
                            }
                        }
                        .tabViewStyle(.page)
                        .frame(height: UIScreen.main.bounds.height)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    HStack(spacing: 8) {
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
                    // Tombol aksi di bawah TabView
                    VStack(spacing: 16) {
                        Button("Back to Home") {
                            // aksi kembali home
                        }
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(uiColor: UIColor(hex: "#FF7200")))
                        .cornerRadius(12)
                        .padding(.horizontal, 48)

                        Button("Try record analysis again") {
                            // aksi ulang
                        }
                        .font(.system(size: 16))
                        .foregroundColor(.orange)
                    }
                    .padding(.bottom, 64)
                    
                    
                    
                }
            VStack {
                ZStack(alignment: .top) {
                    Text("Report Analysis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.top, 8)
                }
                HStack {
                    Spacer()
                    Button {
                        showFullImage = true
                    } label: {
                        Image(systemName: "plus.magnifyingglass")
                            .font(.system(size: 27))
                            .foregroundColor(Color(uiColor: UIColor(hex: "#FF7200")))
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, 8)   // aman dari notch
                .padding(.horizontal, 8)

                Spacer()
            }
            HStack(){
                VStack{
                    LinearGradient(colors: [Color.black,Color.black.opacity(0.5)], startPoint: .bottom, endPoint: .top)
                        .frame(maxHeight: 50)
                    Spacer()
                        LinearGradient(colors: [Color(uiColor: UIColor(hex: "#FF7200")).opacity(0.5),Color.black], startPoint: .bottom, endPoint: .top)
                            .frame(maxHeight: 30)

                }
            }
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // 3) Preview full screen
        .fullScreenCover(isPresented: $showFullImage) {
            ZStack(alignment: .topLeading) {
                Color.black.ignoresSafeArea()
                if let uiImg = vm.predictions[selectedTab].imageForDisplay {
                    Image(uiImage: uiImg)
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea()
                } else {
                    Color.gray.opacity(0.3)
                        .overlay(Image(systemName: "photo")
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
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(24)
                    .padding(.top, 40)
                    .padding(.leading, 16)
                }
            }
        }
    }
}


//HStack(spacing: 8) {
//    ForEach(0..<vm.predictions.count, id: \.self) { idx in
//        if idx == selectedTab {
//            Capsule()
//                .frame(width: 24, height: 8)
//                .foregroundColor(.orange)
//        } else {
//            Circle()
//                .frame(width: 8, height: 8)
//                .foregroundColor(.brown)
//        }
//    }
//}
