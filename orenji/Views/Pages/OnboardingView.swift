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
    
    let totalPages = 4
    
    var body: some View {
        VStack() {
            
            TabView(selection: $currentPage) {
                
                OnboardingContainer(
                    imageName: "onboardiwave1",
                    anotherImage: "Hands",
                    downWave: true,
                    title: "Know What Went Wrong",
                    subtitle: "Identify incorrect postures with a detailed report.",
                    showStartButton: false,
                    onFinish: onFinish
                )
                .tag(0)
                
                OnboardingContainer(
                    imageName: "onboardiwave2",
                    anotherImage: "Hands",
                    title: "Correct Your Posture Instantly",
                    subtitle: "Real-time tips to help perfect your free-throw form.",
                    showStartButton: false,
                    onFinish: onFinish
                )
                .tag(1)
                
                OnboardingContainer(
                    imageName: "onboardiwave3",
                    anotherImage: "Hands",
                    title: "Hands-Free Session Control",
                    subtitle: "Integrated with your Apple Watch — stop sessions and view posture guidance from a distance!",
                    showStartButton: true,
                    onFinish: onFinish
                )
                .tag(2)
                
            }
            
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(maxHeight: .infinity) // 💡 Tambahkan ini agar TabView ambil ruang penuh
            
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Circle()
                        .fill(currentPage == index ? Color.primer : Color.gray.opacity(0.4))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 30) // tambahkan jarak aman dari bawah
        }
        .frame(maxHeight: .infinity)
        .background(Color.black)
        
        
    }
}


struct OnboardingContainer: View {
    var imageName: String
    var anotherImage: String? = nil
    var downWave: Bool? = nil
    var title: String
    var subtitle: String
    var showStartButton: Bool
    var onFinish: () -> Void // ✅ Tambahkan ini
    
    var body: some View {
        VStack(spacing:17) {
            
            Spacer()
            ZStack{
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 350)
                    .clipped()

                if let overlay = anotherImage {
                    Image(overlay)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 580)
                        .offset(x:20, y: -45)
                }
            }
            .frame(height: 350)
            
            
            VStack{
                VStack(spacing: 17){
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
                        .padding(.horizontal)
                        .fixedSize(horizontal: false, vertical: true)
                    
                }
                .frame(height:180, alignment: .top)
                .offset(y:30)
                
                
                if showStartButton {
                    Spacer(minLength: 40)
                    
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
                    .padding(.bottom, 10)
                    .offset(y:30)
                }
                
            }
            
            Spacer(minLength: 30)
        }
    }
}


#Preview {
    OnboardingView(onFinish: {})
    
}

