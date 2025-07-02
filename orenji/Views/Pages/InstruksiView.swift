//
//  InstruksiView.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 22/06/25.
//

import SwiftUI

struct InstruksiView: View {
    @EnvironmentObject var router: Router
    var destination: Route
    var idPage: String
    @StateObject var connectivity = WatchConnectivityManager.shared
    @State private var currentPage = 0
    let totalPages = 3

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $currentPage) {
                getInstructionPages()
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

            Button("Skip all") {
                startSession()
                router.goTo(destination)
            }
            .foregroundColor(.white)
            .font(.system(size: 14, weight: .medium))
            .padding(.top, UIApplication.safeAreaTop + 8)
            .padding(.trailing, 20)
            .zIndex(999)
        }
        .ignoresSafeArea()
        .background(Color.black)
        .overlay(
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Capsule()
                        .fill(currentPage == index ? Color.orange : Color.white.opacity(0.3))
                        .frame(width: currentPage == index ? 18 : 8, height: 8)
                }
            }
            .offset(y: 40)
            .padding(.bottom, 40),
            alignment: .bottom
        )
        .navigationBarHidden(false)
    }

    @ViewBuilder
    private func getInstructionPages() -> some View {
        let pages: [(String, String, String)] = {
            if idPage == "realtime" {
                return [
                    ("instruction1", "Put your tripod on your side", "Make sure to capture your full body and from your side."),
                    ("instruction2", "Shoot Alone", "Keep the background clear to avoid analysis errors."),
                    ("instruction3", "Wrap Up When You're Done", "The session will keep going until you press Stop.")
                ]
            } else {
                return [
                    ("instruction1", "Put your tripod on your side", "Make sure to capture your full body and from your side."),
                    ("instruction2", "One Shot, One Throw", "Record only one free throw per video. Keep it clean and focused."),
                    ("instruction3", "Correct Your Posture Instantly", "Keep the background clear to avoid analysis errors.")
                ]
            }
        }()

        ForEach(0..<pages.count, id: \.self) { index in
            InstructionContainer(
                imageName: pages[index].0,
                title: pages[index].1,
                subtitle: pages[index].2,
                showStartButton: index == pages.count - 1,
                currentPage: $currentPage,
                destination: destination,
                onStart: {
                    startSession()
                    router.goTo(.Tutorial(destination: destination)) // ✅ dinamis ke Tutorial tujuan
                }
            )
            .tag(index)
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
    var imageName: String
    var title: String
    var subtitle: String
    var showStartButton: Bool
    @Binding var currentPage: Int
    var destination: Route
    var onStart: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

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
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()
                    Spacer()

                    VStack {
                        Spacer()
                        Button(action: {
                            if showStartButton {
                                onStart?()
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
                    .frame(maxHeight: .infinity)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
                .frame(maxWidth: .infinity, minHeight: 170)
            }
            .frame(maxWidth: .infinity, minHeight: 170, alignment: .top)
            .offset(y: -24)
        }
    }
}

// MARK: - Utilities
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
