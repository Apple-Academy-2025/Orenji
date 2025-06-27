//
//  OnboardingView.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 17/06/25.
//

import SwiftUI


struct OnboardingView: View {
    @State private var currentPage = 0
    var onFinish: () -> Void
    
    let totalPages = 3
    
    var body: some View {
        VStack() {
            TabView(selection: $currentPage) {
                
                OnboardingContainer(
                    imageName: "onboardwave3",
                    anotherImage: "imageOnboarding1",
                    downWave: true,
                    title: "Know What Went Wrong",
                    subtitle: "Capturing your posture and Identify incorrect postures with a detailed report.",
                    showStartButton: false,
                    onFinish: onFinish
                )
                .tag(0)
                
                OnboardingContainer(
                    imageName: "onboardwave2",
                    anotherImage: "imageOnboarding2",
                    title: "Correct Your Posture Instantly",
                    subtitle: "Real-time tips to help perfect your free-throw form.",
                    showStartButton: false,
                    onFinish: onFinish,
                    pageIndex: 2
                )
                .tag(1)
                
                OnboardingContainer(
                    imageName: "onboardwave1",
                    anotherImage: "Hand",
                    title: "Hands-Free Session Control",
                    subtitle: "Integrated with your Apple Watch — stop sessions and view posture guidance from a distance!",
                    showStartButton: true,
                    onFinish: onFinish,
                    pageIndex: 3
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
        .frame(maxHeight: .infinity)
        .background(Color.black)
        .ignoresSafeArea()
    }
}


struct OnboardingContainer: View {
    var imageName: String
    var anotherImage: String? = nil
    var downWave: Bool? = nil
    var title: String
    var subtitle: String
    var showStartButton: Bool
    var onFinish: () -> Void
    var pageIndex: Int?
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ZStack {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 1)
                        .offset(y: {
                            if pageIndex == 2 {
                                return geo.size.height * -0.01
                            } else if pageIndex == 3 {
                                return geo.size.height * 0.095
                            } else {
                                return geo.size.height * 0.125
                            }
                        }())

                    switch pageIndex {
                    case 2:
                        if let overlay = anotherImage {
                            Image(overlay)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 500)
                                .offset(x: 15, y: 50)
                        }
                    case 3:
                        if let overlay = anotherImage {
                            Image(overlay)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 580)
                                .offset(x: 15, y: 20)
                        }
                    default:
                        if let overlay = anotherImage {
                            Image(overlay)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 480)
                                .offset(x:50, y: 50)
                        }
                    }
                }
                .frame(height: geo.size.height * 0.5)
                
                Spacer()

                VStack(spacing: 17) {
                    Text(title)
                        .font(.system(size: 45))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundStyle(Color("Primer"))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(subtitle)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal,20)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if showStartButton {
                        Button(action: {
                            onFinish()
                        }) {
                            Text("Let’s Get Started")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.primer)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                    }
                }
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}



#Preview {
    OnboardingView(onFinish: {})
    
}

