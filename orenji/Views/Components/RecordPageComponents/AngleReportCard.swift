//
//  AngleReportCard.swift
//  RecordFeature
//
//  Created by Fariz Ajy Putra on 22/06/25.
//

import SwiftUI

struct AngleCardView: View {
    var angleType: String
    var angle: Int
    var angleFeedback: String
    var feedback1: String
    var feedback2: String
    var hexBackroundColour: String
    var hexFeedbackColour: String
    var imageName: String

    var body: some View {
        HStack{
            VStack {
                HStack {
                    Image(systemName: "angle")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundColor(.gray)
                    Text("\(angleType) Angle")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.gray)
                }
                .padding(.top, 12)
                .padding(.bottom, 16)
                HStack{
                    Image("\(imageName)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 87.5, height: 87.5)
                    VStack{
                        Text("\(angle)°")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(Color(uiColor: UIColor(hex: "\(hexFeedbackColour)")))
                        Text("\(angleFeedback)")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(uiColor: UIColor(hex: "\(hexFeedbackColour)")))
                            .fontWeight(.bold)
                    }
                }
                VStack {
                    Text("\(feedback1)").bold() +
                    Text("\(feedback2)")
                }
                .foregroundColor(.white)
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: UIColor(hex: "\(hexBackroundColour)")).opacity(0.2))
        .cornerRadius(24)
        .padding(.horizontal, 48)
    }
}
