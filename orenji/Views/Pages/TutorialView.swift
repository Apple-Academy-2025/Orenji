//
//  TutorialView.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 22/06/25.
//

import SwiftUI

struct TutorialView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        VStack{
            VStack{
                Text("Record Analysis")
                Text("Free-Throw Shooting").foregroundStyle(Color("Primer"))
                Text("Guidelines")
            }.font(.system(size: 28))
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        
        
        
        
        
    }
    
}

#Preview {
    TutorialView()
        .environmentObject(Router())
}
