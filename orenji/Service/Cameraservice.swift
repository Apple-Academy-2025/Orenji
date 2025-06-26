//
//  Cameraserive.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 22/06/25.
//


import AVFoundation
import Combine
import CoreImage
import UIKit

/// Menangani seluruh setup kamera dan meneruskan frame (jika perlu).
final class CameraService: NSObject, ObservableObject {

    // Publikasikan status supaya UI bisa tahu kapan siap dipakai
    @Published var isSessionRunning = false

    // Callback ke luar jika ada frame baru
    var onFrameCaptured: ((CVPixelBuffer) -> Void)?

    // AVCapture
    private let videoOutput = AVCaptureVideoDataOutput()
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var lastFrameTimestamp: TimeInterval = 0

    // MARK: - Setup
    func configure() {
        sessionQueue.async { [weak self] in
            self?._configure()
        }
    }

    private func _configure() {
        session.beginConfiguration()
        session.sessionPreset = .high

        // 1) INPUT kamera depan
        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                 for: .video,
                                                 position: .front),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)

        // 2) OUTPUT (stream frame)
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "output.queue"))

        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)

            // ⬇️ iOS 17 compatible
            if let connection = videoOutput.connection(with: .video) {
                connection.videoRotationAngle = 90
            }
        }


        session.commitConfiguration()
        start()
    }

    // MARK: - Control
    func start() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
                DispatchQueue.main.async { self.isSessionRunning = true }
            }
        }
    }

    func stop() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
                DispatchQueue.main.async { self.isSessionRunning = false }
            }
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let currentTime = CFAbsoluteTimeGetCurrent()
        if currentTime - lastFrameTimestamp > 0.1 {
            self.lastFrameTimestamp = currentTime
            
            if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
                let context = CIContext()
                if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                    let originalUIImage = UIImage(cgImage: cgImage)
                    if let resizedImage = resizeImage(image: originalUIImage, targetWidth: 250) {
                        if let imageData = resizedImage.jpegData(compressionQuality: 0.2) {
                            WatchConnectivityManager.shared.sendFrameToWatch(imageData)
                        }
                    }
                }
                onFrameCaptured?(pixelBuffer)
            }
        }
    }
    
    private func resizeImage(image: UIImage, targetWidth: CGFloat) -> UIImage? {
        let size = image.size
        let widthRatio  = targetWidth / size.width
        let newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
