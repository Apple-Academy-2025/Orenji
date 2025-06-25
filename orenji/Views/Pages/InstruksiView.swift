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
    
    
    @State private var currentPage = 0
    let totalPages = 3

    var body: some View {
        VStack {
            if idPage == "realtime"{
                TabView(selection: $currentPage) {
                    InstructionContainer(
                        imageName: "Tutor1",
                        title: "Put your tripod on your side",
                        subtitle: "Make sure to capture your full body and from your side.",
                        showStartButton: false,
                        currentPage: $currentPage,
                        destination: destination
                    )
                    .tag(0)

                    InstructionContainer(
                        imageName: "Tutor2",
                        downWave: true,
                        title: "Shoot Alone",
                        subtitle: "Keep the background clear to avoid analysis errors.",
                        showStartButton: false,
                        currentPage: $currentPage,
                        destination: destination
                    )
                    .tag(1)

                    InstructionContainer(
                        imageName: "Tutor3",
                        title: "Wrap Up When You're Done",
                        subtitle: "The session will keep going until you press Stop.",
                        showStartButton: true,
                        currentPage: $currentPage,
                        destination: destination
                    )
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)

                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.primer : Color.gray.opacity(0.4))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 30)
            }
            
            else{
                TabView(selection: $currentPage) {
                    InstructionContainer(
                        imageName: "Tutor1",
                        title: "Put your tripod on your side",
                        subtitle: "Make sure to capture your full body and from your side.",
                        showStartButton: false,
                        currentPage: $currentPage,
                        destination: destination
                    )
                    .tag(0)

                    InstructionContainer(
                        imageName: "Tutor2",
                        downWave: true,
                        title: "One Shot, One Throw",
                        subtitle: "Record only one free throw per video. Keep it clean and focused.",
                        showStartButton: false,
                        currentPage: $currentPage,
                        destination: destination
                    )
                    .tag(1)

                    InstructionContainer(
                        imageName: "Tutor3",
                        title: "Correct Your Posture Instantly",
                        subtitle: "Keep the background clear to avoid analysis errors.",
                        showStartButton: true,
                        currentPage: $currentPage,
                        destination: destination
                    )
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)

                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.primer : Color.gray.opacity(0.4))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 30)
            }
            
        }
        .frame(maxHeight: .infinity)
        .background(Color.black)
    }
}

struct InstructionContainer: View {
    @EnvironmentObject var router: Router

    var imageName: String
    var anotherImage: String? = nil
    var downWave: Bool? = nil
    var title: String
    var subtitle: String
    var showStartButton: Bool
    @Binding var currentPage: Int
    var destination: Route

    var body: some View {
        VStack(spacing: 17) {
            Spacer()
            ZStack {
                Image(imageName)
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 650)

                if let overlay = anotherImage {
                    Image(overlay)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 580)
                        .offset(x: 20, y: -45)
                }
            }
            .frame(height: 350)

            VStack {
                HStack(alignment: .bottom, spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(title)
                            .font(.system(size: 35, weight: .bold))
                            .foregroundColor(Color("Primer"))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)

                        Text(subtitle)
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                    }
                    .padding(.leading)
                    .layoutPriority(1)

                    if showStartButton {
                        Button(action: {
                            router.goTo(destination)
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.orange)
                                .clipShape(Circle())
                        }
                        .padding(.leading)
                    } else {
                        Button {
                            withAnimation {
                                currentPage += 1
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.orange)
                                .clipShape(Circle())
                        }
                        .padding(.leading)
                    }
                }
                .frame(maxHeight: 180)
                .offset(y: 30)
            }

            Spacer(minLength: 30)
        }
    }
}

#Preview {
    InstruksiView(destination: .RecordPose, idPage: "record")
        .environmentObject(Router())
}
