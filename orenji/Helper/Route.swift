//
//  Example.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 13/06/25.
//

import Foundation
import SwiftUI


// Guys ini contoh buat sistem pages route biar scaleable

enum Route: Hashable {
    case Home
    case History
    case RecordPose(titlePage: String)
    case RealtimePose(titlePage: String)
}


// jangan di ubah ubah ya bre yg ini
class Router: ObservableObject {
    @Published var path = NavigationPath()

    func goTo(_ route: Route) {
        path.append(route)
    }

    func pop() {
        path.removeLast()
    }

    func reset() {
        path = NavigationPath()
    }
}
