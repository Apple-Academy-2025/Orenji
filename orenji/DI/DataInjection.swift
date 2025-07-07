//
//  DataInjection.swift
//  orenji
//
//  Created by Muhamad Fannan Najma Falahi on 04/07/25.
//

import SwiftUI

final class DIContainer {
    static let shared = DIContainer()
    private lazy var postureManager = PostureEvaluateRealtimeManager()

    private(set) lazy var poseService: RealtimeService = {
        RealtimeServiceImpl(manager: postureManager)
    }()
    
    @MainActor func makeEvaluateRealtimeViewModel() -> EvaluateRealtimeViewModels {
        EvaluateRealtimeViewModels(poseService: poseService)
    }
}
