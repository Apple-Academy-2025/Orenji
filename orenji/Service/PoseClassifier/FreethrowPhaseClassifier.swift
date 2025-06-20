//
//  FreethrowPhaseClassifier.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 20/06/25.
//

import CoreML
import Vision
import UIKit

final class FreethrowPhaseClassifier: PosePhaseClassifierService {
    
    private let model: VNCoreMLModel

    init() {
        // Ambil model ML yang telah di-compile oleh Xcode
        let coreMLModel = try! FreethrowModel(configuration: MLModelConfiguration()).model
        self.model = try! VNCoreMLModel(for: coreMLModel)
    }
    
    func classifyPhase(from image: UIImage) throws -> PosePhase {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "InvalidImage", code: -1)
        }

        var predictedPhase: PosePhase = .unknown
        let request = VNCoreMLRequest(model: model) { request, _ in
            if let results = request.results as? [VNClassificationObservation],
               let top = results.first {
                predictedPhase = PosePhase(rawValue: top.identifier) ?? .unknown
            }
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])

        return predictedPhase
    }
}

