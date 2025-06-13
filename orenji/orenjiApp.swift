//
//  orenjiApp.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 13/06/25.
//

import SwiftUI

@main
struct orenjiApp: App {
    @StateObject var router = Router()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                HomePageView()
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .Home:
                            HomePageView()
                        case .RecordPose(let titlePage):
                            RecordPageView(titlePage: titlePage)
                        case .RealtimePose(let titlePage):
                            RealtimePageView(titlePage: titlePage)
                        }
                    }
            }
            .environmentObject(router) // HARUS di sini
        }
    }
}

