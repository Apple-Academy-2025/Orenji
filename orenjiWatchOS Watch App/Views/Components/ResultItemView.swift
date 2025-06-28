//
//  ResultItemView.swift
//  orenji
//
//  Created by Muhamad Fannan Najma Falahi on 21/06/25.
//

import SwiftUI

import SwiftUI

struct ResultItemView: View {
    let title: String
    let angle: Int
    let improvement: String
    let target: Int

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "angle")
                Text("\(title.uppercased()) ANGLE")
            }
            .foregroundStyle(.grayText)
            Spacer()
            HStack {
                Text("\(angle)°")
                    .bold()
                    .font(.largeTitle)
                    .foregroundStyle(.orange)
                Text("\(target)")
                    .bold()
                    .font(.title2)
                    .foregroundStyle(.green)
            }
            Spacer()
            Text(improvement)
                .bold()
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 16)
            Spacer()
        }
        .frame(height: 140)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 19)
        .padding(.horizontal)
        .background(.grayCard)
        .cornerRadius(12)
    }
}


#Preview {
    ResultItemView(title: "sa", angle: 50, improvement: "ss", target: 90)
}
