//
//  InstruksiView.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 22/06/25.
//

import SwiftUI

struct InstruksiView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Router
    var destination: Route
    var idPage: String
    @StateObject var connectivity = WatchConnectivityManager.shared
    @State private var currentPage = 0
    let totalPages = 3
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Background hitam + konten TabView
            TabView(selection: $currentPage) {
                getInstructionPages()
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // ✅ "Skip all" button always on top
            HStack(alignment: .top){
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .padding(.leading, 20)
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                }
                Spacer()
                Button("Skip all") {
                    startSession()
                    router.goTo(destination)
                }
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .medium))
                .padding(.trailing, 20)
                .zIndex(999)
            }
                .frame(maxWidth: .infinity, maxHeight: 140)
        }
        .ignoresSafeArea()
        .background(Color.black)
        .overlay(
            // ✅ Page indicators (di bawah)
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Capsule()
                        .fill(currentPage == index ? Color.orange : Color.white.opacity(0.3))
                        .frame(width: currentPage == index ? 18 : 8, height: 8)
                }
            }
                .offset(y:40)
                .padding(.bottom, 40),
            alignment: .bottom
            
        )
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true) // ini harus TRUE
    }
    
    @ViewBuilder
    private func getInstructionPages() -> some View {
        if idPage == "realtime" {
            InstructionContainer(imageName: "instruction1", title: "Put your tripod on your side", subtitle: "Make sure to capture your full body and from your side.", showStartButton: false, currentPage: $currentPage, destination: destination)
                .tag(0)
            InstructionContainer(imageName: "instruction2", title: "Shoot Alone", subtitle: "Keep the background clear to avoid analysis errors.", showStartButton: false, currentPage: $currentPage, destination: destination)
                .tag(1)
            InstructionContainer(imageName: "instruction3", title: "Wrap Up When You're Done", subtitle: "The session will keep going until you press Stop.", showStartButton: true, currentPage: $currentPage, destination: destination, onStart: { startSession() })
                .tag(2)
        } else {
            InstructionContainer(imageName: "instruction1", title: "Put your tripod on your side", subtitle: "Make sure to capture your full body and from your side.", showStartButton: false, currentPage: $currentPage, destination: destination)
                .tag(0)
            InstructionContainer(imageName: "instruction2", title: "One Shot, One Throw", subtitle: "Record only one free throw per video. Keep it clean and focused.", showStartButton: false, currentPage: $currentPage, destination: destination)
                .tag(1)
            InstructionContainer(imageName: "instruction3", title: "Correct Your Posture Instantly", subtitle: "Keep the background clear to avoid analysis errors.", showStartButton: true, currentPage: $currentPage, destination: destination, onStart: { startSession() })
                .tag(2)
        }
    }
    
    private func startSession() {
        if idPage == "realtime" {
            connectivity.sendStartSessionCommand(type: .realtime)
        } else if idPage == "record" {
            connectivity.sendStartSessionCommand(type: .recording)
        }
    }
}

struct InstructionContainer: View {
    @EnvironmentObject var router: Router
    
    var imageName: String
    var title: String
    var subtitle: String
    var showStartButton: Bool
    @Binding var currentPage: Int
    var destination: Route
    var onStart: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // 🔳 Gambar full screen
            Image(imageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // 🔳 Box hitam teks menumpuk di bawah gambar (offset naik)
            ZStack(alignment: .top) {
                Color.black
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(subtitle)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(width: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                            
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                   
                    Spacer()
                    Spacer()
                    // Tombol diletakkan di bawah dengan tinggi penuh
                    VStack {
                        Spacer()
                        Button(action: {
                            if showStartButton {
                                onStart?()
                                router.goTo(destination)
                            } else {
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                        }) {
                            Image(systemName: showStartButton ? "play.fill" : "chevron.right")
                                .foregroundColor(.black)
                                .font(.system(size: 20, weight: .bold))
                                .frame(width: 56, height: 56)
                                .background(Color.orange)
                                .clipShape(Circle())
                        }
                    }
                    .frame(maxHeight: .infinity) // ✅ Tombol isi tinggi HStack
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
                .frame(maxWidth: .infinity, minHeight: 170)
                
                
                
            }
            .frame(maxWidth: .infinity, minHeight: 170, alignment: .top)
            .offset(y: -24) // naikin agar overlapping ke gambar
        }
        
    }
    
}







extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

extension UIApplication {
    static var safeAreaTop: CGFloat {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        return keyWindow?.safeAreaInsets.top ?? 44
    }
}


struct RoundedCorner: Shape {
    var radius: CGFloat = 16
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    InstruksiView(destination: .RecordPose, idPage: "realtime")
        .environmentObject(Router())
}
