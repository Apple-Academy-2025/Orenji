//
//  HomePageView.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 13/06/25.
//

import SwiftUI

struct HomePageView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.backgroundApp
                .ignoresSafeArea()
            Image("headerHomeScreen")
                .resizable()
                .scaledToFit()
                .offset(y: -70)
            LinearGradient(colors: [.primer,.backgroundApp], startPoint: .top, endPoint: .bottom)
                .frame(height: 383)
                .opacity(0.7)
            VStack(alignment: .leading){
                Spacer()
                Spacer()
                Spacer()
                Text("Ready to kick off your")
                    .font(.title2)
                Text("Free-Throw Analysis")
                    .font(.system(size: 45))
                    .bold()
                    .padding(.bottom,40)
                
                FeatureCardView(
                    title: "Record Analysis", subtitle: "Record and review your free-throw posture", imageName: "imageRecordAnalysis", action: {
                        router.goTo(.RecordPose)
                        print("record")
                    }
                )
                
                FeatureCardView(
                    title: "Evaluate Realtime", subtitle: "Learn to free-throw shooting in realtime", imageName: "evaluateRealtimeImage", action: {
                        router.goTo(.RealtimePose)
                        print("realtime")
                    }
                )
                
                Button(action: {
                    router.goTo(.History)
                }) {
                    ZStack {
                        LinearGradient(colors: [.primer, .orangeGradient], startPoint: .top, endPoint: .bottom)
                            .cornerRadius(18)
                            .frame(maxWidth: .infinity)
                            .frame(height: 70)
                        HStack {
                            Text("History")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                            Text("Access all of your session here")
                                .font(.caption)
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 20)
                        .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color.clear)
                .cornerRadius(18)
                .padding(.top, 10)
                
                Spacer()
            }
            .padding(.horizontal,30)
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .foregroundStyle(.white)
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    HomePageView()
        .environmentObject(Router())
}


struct FeatureCardView: View {
    let title: String
    let subtitle: String
    let imageName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action, label: {
            HStack {
            ZStack(alignment: .leading) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150)
                    .frame(maxWidth: .infinity, alignment: .leading)
                LinearGradient(
                    colors: [.backgroundGray, .clear],
                    startPoint: .trailing,
                    endPoint: .leading
                )
                .frame(width: 150)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.bottom,20)
                        .multilineTextAlignment(.leading)
                    
                    Text("Start")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .background(Color.primer)
                        .cornerRadius(20)
                }
                .padding()
                .frame(width: 250)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 175)
        .background(.backgroundGray)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.primer, lineWidth: 2)
        )
            .padding(.bottom,20)}
        )
        
    }
}
