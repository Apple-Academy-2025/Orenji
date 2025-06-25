//
//  PreferencesView.swift
//  orenji
//
//  Created by Muhamad Fannan Najma Falahi on 25/06/25.
//


import SwiftUI

struct PreferencesView: View {
    @AppStorage("shootingHand") private var selectedHand: String = ""

    var body: some View {
        VStack {
            Spacer()
            
            Text("Which one is your \(Text("Shooting Hand?").bold())")
                .font(.largeTitle)
                .foregroundStyle(.white)
            Spacer()
            Button(action: {
                selectedHand = "Right"
            }) {
                HStack {
                    Image("imageRightHand")
                        .resizable()
                        .scaledToFit()
                    Text("Right Hand")
                        .bold()
                        .font(.title)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: 112)
                .padding(.horizontal, 10)
                .padding(.top, 8)
                .background(selectedHand == "Right" ? Color.primaryApp : Color.clear)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.primaryApp, lineWidth: 2)
                )
            }
            .padding(.horizontal,25)
            .padding(.bottom,16)
            
            Button(action: {
                selectedHand = "Left"
            }) {
                HStack {
                    Text("Left Hand")
                        .bold()
                        .font(.title)
                        .foregroundStyle(.white)
                    Image("imageLeftHand")
                        .resizable()
                        .scaledToFit()
                }
                .frame(maxWidth: .infinity, maxHeight: 112)
                .padding(.horizontal, 10)
                .padding(.top, 8)
                .background(selectedHand == "Left" ? Color.primaryApp : Color.clear)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.primaryApp, lineWidth: 2)
                )
            }
            .padding(.horizontal,25)

            Spacer()
            Spacer()

            Button("Let's Get Started", action: {
                
            })
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.primaryApp)
            .foregroundStyle(.black)
            .cornerRadius(14)
        }
        .padding()
        .frame(maxHeight: .infinity)
        .background(.black)
        .navigationBarBackButtonHidden(true)
    }
}


#Preview {
    PreferencesView()
}
