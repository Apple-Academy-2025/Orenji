//
//  Example.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 13/06/25.
//

import Foundation
import SwiftUI
import SwiftData


// Guys ini contoh buat sistem pages route biar scaleable

indirect enum Route: Hashable {
    case Home
    case History
    case Prefereces
    case Instruksi(destination: Route, idPage: String)
    case RecordAnalysisView
    case HistoryDetailView(PhaseData: PhaseData, selectedTab: Int)
    case Tutorial(destination: Route)
    case RecordPose
    case RealtimePose
    case FinishRealtime(loopCount: Int, durationInSeconds: Int)
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
