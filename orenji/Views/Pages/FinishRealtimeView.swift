//
//  FinishRealtime.swift
//  orenji
//
//  Created by Adithya Firmansyah Putra on 26/06/25.
//

import SwiftUI

struct FinishRealtimeView: View {
    @EnvironmentObject var router: Router
    @State var loopCount: Int = 0
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Text("SESSION WRAP UP!")
                .padding(.horizontal, 80)
                .multilineTextAlignment(.center)
                .frame(alignment: .center)
                .background(.black)
                .font(.system(size: 32, weight: .bold, design: .default))
                .foregroundColor(.white)
                
            Spacer()
            
            VStack {
                Text("You Spend")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white)
                    
                Text("01:00")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                    )
                
                    Text("Minutes")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.white)
                        
                
            }
            .frame(width: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(LinearGradient(colors: [.primer, .primer.opacity(0.2)], startPoint: .top, endPoint: .bottom), lineWidth: 2)
            )
            .padding(.bottom, 32)
            
            VStack {
                Text("You did Shooting")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white)
                    
                Text("\(loopCount)")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                    )
                
                    Text("Times")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.white)
                        
                
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(LinearGradient(colors: [.primer, .primer.opacity(0.2)], startPoint: .top, endPoint: .bottom), lineWidth: 2)
            )
            
            Spacer()
            
            
            Button(action: {
                router.goTo(.Home)
            }) {
                Text("Finish")
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
        .frame(maxHeight: .infinity)
        .padding()
        .navigationBarBackButtonHidden()
        .background(.black)
    }
}

#Preview {
    FinishRealtimeView(loopCount: 4)
        .environmentObject(Router())
}
