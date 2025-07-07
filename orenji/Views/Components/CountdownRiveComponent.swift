//
//  CountdownRiveView.swift
//  orenji
//
//  Created by Muhamad Fannan Najma Falahi on 04/07/25.
//

import SwiftUI
import RiveRuntime

struct CountdownRiveComponent: View {
    var body: some View {
        RiveViewRepresentable(viewModel: countdownModel)
            .aspectRatio(contentMode: .fit)
            .frame(width: 300, height: 300)
    }
}
