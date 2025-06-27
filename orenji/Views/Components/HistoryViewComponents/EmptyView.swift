//
//  EmptyView.swift
//  orenji
//
//  Created by Fariz Ajy Putra on 27/06/25.
//

import SwiftUI

struct EmptyView: View {
    var body: some View {
        VStack{
            Image("?")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.primary)
            Spacer().frame(height: 16)
            Text("there is no recorded\nhistory yet")
                .foregroundColor(.white)
                .font(.system(size: 20).bold())
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    EmptyView()
}
