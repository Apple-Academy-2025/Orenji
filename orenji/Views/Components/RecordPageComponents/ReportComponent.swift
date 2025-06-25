//
//  ReportView.swift
//  RecordFeature
//
//  Created by Fariz Ajy Putra on 23/06/25.
//

import SwiftUI
import Vision

struct ReportComponent: View {
    var myImage: UIImage?
    var joints: [VNHumanBodyPoseObservation.JointName: CGPoint]?
    var phase: String
    var elbowAngle: Int
    var elbowImprovement: String
    var elbowfeedback1: String
    var elbowfeedback2: String
    var legAngle: Int
    var legImprovement: String
    var legFeedback1: String
    var legFeedback2: String
    
    var body: some View {
        ZStack{
            Color.black
                .ignoresSafeArea(edges: .top)
                VStack(spacing: 16) {
                    // MARK: – Foto Utama
                    Group {
                      if let uiImg = myImage {
                        // Jika ada foto dari myImage
                        Image(uiImage: uiImg)
                              .resizable()
                              .scaledToFill()
                              .clipped()
                      } else {
                        // Placeholder kalau nil
                        Color.gray.opacity(0.3)
                          .overlay(
                            Image(systemName: "photo")
                              .font(.largeTitle)
                              .foregroundColor(.white.opacity(0.7))
                          )
                      }
                    }
                    .frame(
                      width: UIScreen.main.bounds.width,
                      height: UIScreen.main.bounds.width - UIScreen.main.bounds.width/10
                    )
                    .clipped()
                    .cornerRadius(10)

                    // MARK: – Kartu Elbow Angle
                    VStack(alignment: .leading, spacing: 12) {
                        // Header
                        HStack {
                            Image(systemName: "angle")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                            Text("ELBOW ANGLE")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 12)

                        // Konten: Badge + Deskripsi
                        HStack(alignment: .center, spacing: 16) {
                            // Badge Lingkaran
                            ZStack {
                                Circle()
                                    .fill(Color(uiColor: UIColor(hex: "#FF0E00")).opacity(0.75))
                                    .opacity(0.2)
                                    .frame(width: 115, height: 115)
                                VStack(spacing: 4) {
                                    Text("\(elbowImprovement)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(Color(uiColor: UIColor(hex: "#FF3B30")))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text("\(elbowAngle)°")
                                        .font(.system(size: 44, weight: .bold))
                                    
                                        .foregroundColor(Color(uiColor: UIColor(hex: "#FF3B30")))
                                }
                            }
                            Spacer()
                            // Deskripsi
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(elbowfeedback1)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(uiColor: UIColor(hex: "#FF0E00")))
                                
                                Text("\(elbowfeedback2)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                            }
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 150)


                        }
                        .padding(.trailing, 32)
                        .padding(.leading, 16)
                        .padding(.bottom, 16)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(uiColor: UIColor(hex: "#FF7200")).opacity(0.2))
                        
                    )
                    .padding(.horizontal, 16)
                
                    VStack(alignment: .leading, spacing: 12) {
                        // Header
                        HStack {
                            Image(systemName: "angle")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                            Text("LEG ANGLE")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 12)

                        // Konten: Badge + Deskripsi
                        HStack(alignment: .center, spacing: 16) {
                            // Badge Lingkaran
                            ZStack {
                                Circle()
                                    .fill(Color(uiColor: UIColor(hex: "#11FF00")).opacity(0.6))
                                    .opacity(0.2)
                                    .frame(width: 115, height: 115)
                                VStack(spacing: 4) {
                                    Text("\(legImprovement)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(Color(uiColor: UIColor(hex: "#11FF00")))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text("\(legAngle)°")
                                        .font(.system(size: 44, weight: .bold))
                                    
                                        .foregroundColor(Color(uiColor: UIColor(hex: "#11FF00")))
                                }
                            }
                            Spacer()
                            // Deskripsi
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(legFeedback1)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(uiColor: UIColor(hex: "#11FF00")))
                                
                                Text("\(legFeedback2)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                            }
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 150)


                        }
                        .padding(.trailing, 32)
                        .padding(.leading, 16)
                        .padding(.bottom, 16)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(uiColor: UIColor(hex: "#071A00")).opacity(0.75))
                        
                    )
                    .padding(.horizontal, 16)
                    Spacer()
                    
                }
                .ignoresSafeArea()
            HStack{
                Spacer()
                Text("\(phase)")
                    .foregroundColor(.white)
                    .frame(alignment: .center)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 8)
                    .font(.system(size: 22, weight: .bold))
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(uiColor: UIColor(hex: "#1B1F26")).opacity(0.5))
                    )
                    .position(x:UIScreen.main.bounds.width/2,y:UIScreen.main.bounds.width-100)
                Spacer()
            }
 
            }
            .background(Color.black)
            .ignoresSafeArea()
    }
}

#Preview {
    ReportComponent(myImage: nil, joints: nil , phase: "Test", elbowAngle: 90, elbowImprovement: "Test", elbowfeedback1: "Test", elbowfeedback2: "Test", legAngle: 90, legImprovement: "Test", legFeedback1: "Test", legFeedback2: "Test")
}
