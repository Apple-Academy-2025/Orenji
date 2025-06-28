//
//  PreferencesView.swift
//  orenji
//
//  Created by Muhamad Fannan Najma Falahi on 25/06/25.
//


import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var router: Router
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
                        .foregroundStyle(selectedHand == "Right" ? Color.black : Color.white)
                }
                .frame(maxWidth: .infinity, maxHeight: 112)
                .padding(.horizontal, 10)
                .padding(.top, 8)
                .background(selectedHand == "Right" ? Color.primer : Color.clear)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.primer, lineWidth: 2)
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
                        .foregroundStyle(selectedHand == "Left" ? Color.black : Color.white)
                    Image("imageLeftHand")
                        .resizable()
                        .scaledToFit()
                }
                .frame(maxWidth: .infinity, maxHeight: 112)
                .padding(.horizontal, 10)
                .padding(.top, 8)
                .background(selectedHand == "Left" ? Color.primer : Color.clear)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.primer, lineWidth: 2)
                )
            }
            .padding(.horizontal,25)

            Spacer()
            Spacer()

            Button(action: {
                router.goTo(.Home)
            }) {
                Text("Save")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.primer)
            .foregroundStyle(.black)
            .cornerRadius(14)
        }
        .padding()
        .frame(maxHeight: .infinity)
        .background(.black)
    }
}


#Preview {
    PreferencesView()
        .environmentObject(Router())
}
