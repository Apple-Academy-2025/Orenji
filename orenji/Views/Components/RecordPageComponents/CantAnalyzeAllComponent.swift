//
//  CantAnalyzeAllComponent.swift
//  orenji
//
//  Created by Fariz Ajy Putra on 27/06/25.
//

//
//  CantAnalyzeComponent.swift
//  orenji
//
//  Created by Fariz Ajy Putra on 27/06/25.
//

import SwiftUI

struct CantAnalyzeAllComponent: View {
    @EnvironmentObject var router: Router
    var phase: String = "Bending"
    var body: some View {
        VStack {
            Image("Warning")
            Spacer().frame(height: 48)
            Text("Can’t analyze your form :(")
                .multilineTextAlignment(.center)
                .font(.system(size: 36,weight: .bold))
                .foregroundColor(.white)
                .frame(maxHeight:100)
            Spacer().frame(height: 18)
            Text("we cannot recognize your form of\nshoot, please try again your shoot.")
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(.system(size: 16, design: .default))

        }
        .frame(maxWidth: .infinity)
        .background(Color.black)
    }

}


#Preview {
    CantAnalyzeAllComponent(phase: "FollowThrough")
}
