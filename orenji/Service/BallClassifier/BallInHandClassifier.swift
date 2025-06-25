//
//  BallInHandClassifier.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 20/06/25.
//

import UIKit
import CoreML
import Vision

final class BallInHandClassifier: BallDetectionService {
    
    private let model: VNCoreMLModel

    init() {
        let coreMLModel = try! hasilCheckBall(configuration: MLModelConfiguration()).model
        self.model = try! VNCoreMLModel(for: coreMLModel)
    }

    func isBallInHand(from image: UIImage) throws -> Bool {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "InvalidImage", code: -1)
        }

        var isInHand = true

        let request = VNCoreMLRequest(model: model) { request, _ in
            if let results = request.results as? [VNClassificationObservation],
               let top = results.first {
                isInHand = top.identifier.lowercased() == "ballinhand"
            }
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])

        return isInHand
    }
}

