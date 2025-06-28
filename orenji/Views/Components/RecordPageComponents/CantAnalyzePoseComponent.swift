//
//  CantAnalyzeComponent.swift
//  orenji
//
//  Created by Fariz Ajy Putra on 27/06/25.
//

import SwiftUI

struct CantAnalyzePoseComponent: View {
    
    @EnvironmentObject var router: Router
    var onTap: () -> Void
    var phase: String = "Bending"
    var body: some View {
        VStack {
            Image("Warning")
            Spacer().frame(height: 48)
            Text("Can’t analyze \nYour \(phase)")
                .multilineTextAlignment(.center)
                .font(.system(size: 36,weight: .bold))
                .foregroundColor(.white)
                .frame(maxHeight:100)
            Spacer().frame(height: 18)
            Text("Your form lack of Bending, try to\nrecord again with all of the form of\n shoot. You can learn how to shoot on\n Evaluate Realtime feature")
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(.system(size: 16, design: .default))
            Spacer().frame(height: 12)

            Button {
                onTap()
//                router.goTo(.Instruksi(destination: .RealtimePose(titlePage: "Realtime"), idPage: "realtime"))
            } label: {
                Text("Try Evaluate Realtime")
                    .font(.system(size: 16, design: .default))
                    .foregroundColor(.orange)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.black)
    }

}


//#Preview {
//    CantAnalyzeComponent(phase: "FollowThrough", onTap: { presentationMode.wrappedValue.dismiss()})
//}
