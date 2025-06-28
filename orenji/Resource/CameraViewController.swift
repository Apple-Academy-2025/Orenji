//
//  VideoRecorderModelView.swift
//  RecordFeature
//
//  Created by Fariz Ajy Putra on 21/06/25.
//


import UIKit
import AVFoundation
import SwiftUI

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var movieOutput = AVCaptureMovieFileOutput()
    var onFinishRecording: ((URL) -> Void)?
    var isRecordingBinding: Binding<Bool>?
    
    var isRecording: Bool = false {
        didSet {
            if isRecording && !movieOutput.isRecording {
                startRecording()
            } else if !isRecording && movieOutput.isRecording {
                stopRecording()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        
        // Video Input
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else {
            print("Gagal inisialisasi kamera depan")
            return
        }
        captureSession.addInput(videoInput)

//        if let audioCaptureDevice = AVCaptureDevice.default(for: .audio),
//           let audioInput = try? AVCaptureDeviceInput(device: audioCaptureDevice),
//           captureSession.canAddInput(audioInput) {
//            captureSession.addInput(audioInput)
//        }
        
        // Output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        captureSession.commitConfiguration()
        
        // Preview
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.frame = view.layer.bounds
        videoPreviewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(videoPreviewLayer)
        
        // Start session di background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func startRecording() {
        let outputPath = NSTemporaryDirectory() + "\(UUID().uuidString).mov"
        let outputURL = URL(fileURLWithPath: outputPath)
        movieOutput.startRecording(to: outputURL, recordingDelegate: self)
    }
    
    func stopRecording() {
        movieOutput.stopRecording()
    }
    
    // Delegate
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection], error: Error?) {
        print("Recording selesai. File di: \(outputFileURL)")
        isRecordingBinding?.wrappedValue = false
        
        // Callback ke SwiftUI/parent
        onFinishRecording?(outputFileURL)
    }
}


struct CameraView: UIViewControllerRepresentable {
    @Binding var isRecording: Bool
    var onFinish: (URL) -> Void

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.onFinishRecording = onFinish
        controller.isRecordingBinding = $isRecording
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        uiViewController.isRecording = isRecording
        uiViewController.isRecordingBinding = $isRecording
    }
}
