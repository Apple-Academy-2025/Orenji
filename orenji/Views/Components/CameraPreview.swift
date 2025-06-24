//
//  CameraPreview.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 22/06/25.
//

import SwiftUI
import AVFoundation

// MARK: - Camera Preview
final class PreviewView: UIView {
    private var previewLayer: AVCaptureVideoPreviewLayer?

    func attachSession(_ session: AVCaptureSession) {
        if let existing = previewLayer {
            existing.session = session
        } else {
            let newLayer = AVCaptureVideoPreviewLayer(session: session)
            newLayer.videoGravity = .resizeAspectFill
            newLayer.frame = bounds
            layer.addSublayer(newLayer)
            previewLayer = newLayer
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}

struct CameraPreview: UIViewRepresentable {
    let service: CameraService

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.attachSession(service.session)
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.attachSession(service.session)
    }
}




