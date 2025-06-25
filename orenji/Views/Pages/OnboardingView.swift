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

    let totalPages = 5

    var body: some View {
        VStack() {
               
                TabView(selection: $currentPage) {
                    OnboardingContainer(
                        imageName: "dummy",
                        title: "Recorded Free-Throw Analysis",
                        subtitle: "Start by analyzing your free-throw form using the recorded analysis feature.",
                        showStartButton: false,
                        onFinish: onFinish
                    )
                    .tag(0)

                    OnboardingContainer(
                        imageName: "dummy",
                        title: "Know What Went Wrong",
                        subtitle: "Identify incorrect postures with a detailed report.",
                        showStartButton: false,
                        onFinish: onFinish
                    )
                    .tag(1)
                    
                    OnboardingContainer(
                        imageName: "dummy",
                        title: "Correct Your Posture Instantly",
                        subtitle: "Real-time tips to help perfect your free-throw form.",
                        showStartButton: false,
                        onFinish: onFinish
                    )
                    .tag(2)
                    
                    OnboardingContainer(
                        imageName: "dummy",
                        title: "Hands-Free Session Control",
                        subtitle: "Integrated with your Apple Watch — stop sessions and view posture guidance from a distance!",
                        showStartButton: false,
                        onFinish: onFinish
                    )
                    .tag(3)
                    
                    OnboardingContainer(
                        imageName: "dummy",
                        title: "Pilih tangan",
                        subtitle: "Identify incorrect postures with a detailed report.",
                        showStartButton: true,
                        onFinish: onFinish
                    )
                    .tag(4)
                    PreferencesView()
                }
            
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(maxHeight: .infinity) // 💡 Tambahkan ini agar TabView ambil ruang penuh

                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.blue : Color.gray.opacity(0.4))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 30) // tambahkan jarak aman dari bawah
            }
            .frame(maxHeight: .infinity)
            .background(Color.white)
        
//        Button(action: {
//            onFinish()
//        }) {
//            Text("GET STARTED")
//                .fontWeight(.semibold)
//                .frame(maxWidth: UIScreen.main.bounds.width/2)
//                .padding()
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(12)
//                .padding(.horizontal)
//        }
        
    }
}


struct OnboardingContainer: View {
    var imageName: String
    var title: String
    var subtitle: String
    var showStartButton: Bool
    var onFinish: () -> Void // ✅ Tambahkan ini

    var body: some View {
        VStack(spacing:16) {
            
            Spacer()
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 350)
                .padding()
            
            
            VStack{
                Text(title)
                    .font(.system(size: 25))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
                    
            }
            .frame(height:90, alignment: .top)
//            .background(.blue)

            if showStartButton {
                Button(action: {
                    onFinish()
                }) {
                    Text("GET STARTED")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }

            Spacer(minLength: 30)
        }
    }
}


#Preview {
    OnboardingView(onFinish: {})
}

