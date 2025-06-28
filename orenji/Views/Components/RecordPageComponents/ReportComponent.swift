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
        VStack(spacing: 16) {
            // MARK: – Foto Utama
            Group {
                if let uiImg = myImage {
                    ZStack() {
                        Color.gray
                            .overlay(
                                Image(uiImage: uiImg)
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                            )
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
                            .padding(.bottom, 42)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    }
                } else {
                    ZStack() {
                        Color.gray.opacity(0.3)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.white.opacity(0.7))
                            )
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
                            .padding(.bottom, 42)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    }
                }
            }
            .frame(
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.width - UIScreen.main.bounds.width / 6
            )
            .clipped()
            .cornerRadius(10)

            // MARK: – Kartu Elbow Angle
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: "angle")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(elbowImprovement.lowercased() == "pass"
                            ? Color(uiColor: UIColor(hex: "#11FF00"))
                            : Color(uiColor: UIColor(hex: "#FF3B30"))
                        )
                    Text("ELBOW ANGLE")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(elbowImprovement.lowercased() == "pass"
                            ? Color(uiColor: UIColor(hex: "#11FF00"))
                            : Color(uiColor: UIColor(hex: "#FF3B30"))
                        )
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.horizontal, 12)

                // Konten: Badge + Deskripsi
                HStack(alignment: .center, spacing: 16) {
                    // Badge Lingkaran
                    ZStack {
                        Circle()
                            .fill(elbowImprovement.lowercased() == "pass"
                                ? Color(uiColor: UIColor(hex: "#11FF00")).opacity(0.6)
                                : Color(uiColor: UIColor(hex: "#FF3B30")).opacity(0.6)
                            )
                            .opacity(0.2)
                            .frame(width: 115, height: 115)
                        VStack(spacing: 4) {
                            Text("\(elbowImprovement)")
                                .multilineTextAlignment(.center)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(
                                    elbowImprovement.lowercased() == "pass"
                                    ? Color(uiColor: UIColor(hex: "#11FF00"))
                                    : Color(uiColor: UIColor(hex: "#FF3B30"))
                                )
                                .fixedSize(horizontal: false, vertical: true)
                            Text("\(elbowAngle)°")
                                .font(.system(size: 44, weight: .bold))
                                .foregroundColor(
                                    elbowImprovement.lowercased() == "pass"
                                    ? Color(uiColor: UIColor(hex: "#11FF00"))
                                    : Color(uiColor: UIColor(hex: "#FF3B30"))
                                )
                        }
                    }
                    Spacer()
                    // Deskripsi
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(elbowfeedback1)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(elbowImprovement.lowercased() == "pass"
                                ? Color(uiColor: UIColor(hex: "#11FF00"))
                                : Color(uiColor: UIColor(hex: "#FF3B30"))
                            )
                        
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
                    .fill(elbowImprovement.lowercased() == "pass"
                        ? Color(uiColor: UIColor(hex: "#11FF00")).opacity(0.2)
                        : Color(uiColor: UIColor(hex: "#FF3B30")).opacity(0.2)
                    )
            )
            .padding(.horizontal, 16)

            // MARK: – Kartu Leg Angle
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: "angle")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(legImprovement.lowercased() == "pass"
                            ? Color(uiColor: UIColor(hex: "#11FF00"))
                            : Color(uiColor: UIColor(hex: "#FF3B30"))
                        )
                    Text("LEG ANGLE")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(legImprovement.lowercased() == "pass"
                            ? Color(uiColor: UIColor(hex: "#11FF00"))
                            : Color(uiColor: UIColor(hex: "#FF3B30"))
                        )
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.horizontal, 12)

                // Konten: Badge + Deskripsi
                HStack(alignment: .center, spacing: 16) {
                    // Badge Lingkaran
                    ZStack {
                        Circle()
                            .fill(legImprovement.lowercased() == "pass"
                                ? Color(uiColor: UIColor(hex: "#11FF00")).opacity(0.6)
                                : Color(uiColor: UIColor(hex: "#FF3B30")).opacity(0.6)
                            )
                            .opacity(0.2)
                            .frame(width: 115, height: 115)
                        VStack(spacing: 4) {
                            Text("\(legImprovement)")
                                .multilineTextAlignment(.center)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(
                                    legImprovement.lowercased() == "pass"
                                    ? Color(uiColor: UIColor(hex: "#11FF00"))
                                    : Color(uiColor: UIColor(hex: "#FF3B30"))
                                )
                                .fixedSize(horizontal: false, vertical: true)
                            Text("\(legAngle)°")
                                .font(.system(size: 44, weight: .bold))
                                .foregroundColor(
                                    legImprovement.lowercased() == "pass"
                                    ? Color(uiColor: UIColor(hex: "#11FF00"))
                                    : Color(uiColor: UIColor(hex: "#FF3B30"))
                                )
                        }
                    }
                    Spacer()
                    // Deskripsi
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(legFeedback1)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(legImprovement.lowercased() == "pass"
                                ? Color(uiColor: UIColor(hex: "#11FF00"))
                                : Color(uiColor: UIColor(hex: "#FF3B30"))
                            )
                        
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
                    .fill(legImprovement.lowercased() == "pass"
                        ? Color(uiColor: UIColor(hex: "#11FF00")).opacity(0.2)
                        : Color(uiColor: UIColor(hex: "#FF3B30")).opacity(0.2)
                    )
            )
            .padding(.horizontal, 16)
        }
        .background(Color.black)
    }
}

#Preview {
    ReportComponent(
        myImage: nil,
        joints: nil,
        phase: "Test",
        elbowAngle: 90,
        elbowImprovement: "pass",
        elbowfeedback1: "Good form on the elbow, keep it up!",
        elbowfeedback2: "Keep your arm steady.",
        legAngle: 160,
        legImprovement: "pass",
        legFeedback1: "Knee bend is too shallow.",
        legFeedback2: "Try to bend your knee more."
    )
}



//Text("\(phase)")
//    .foregroundColor(.white)
//    .frame(alignment: .center)
//    .padding(.horizontal, 40)
//    .padding(.vertical, 8)
//    .font(.system(size: 22, weight: .bold))
//    .background(
//        RoundedRectangle(cornerRadius: 10)
//            .fill(Color(uiColor: UIColor(hex: "#1B1F26")).opacity(0.5))
//    )
//    .padding(.horizontal, 16)


//Text("\(phase)")
//    .foregroundColor(.white)
//    .frame(alignment: .center)
//    .padding(.horizontal, 40)
//    .padding(.vertical, 8)
//    .font(.system(size: 22, weight: .bold))
//    .background(
//        RoundedRectangle(cornerRadius: 10)
//            .fill(Color(uiColor: UIColor(hex: "#1B1F26")).opacity(0.5))
//    )
//    .padding(.horizontal, 16)
