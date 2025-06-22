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
        Text("Ini tutorial page")
        Button("instruksi analisis "){
            router.goTo(.Instruksi)
        }
    }
}

#Preview {
    TutorialView()
        .environmentObject(Router())
}
