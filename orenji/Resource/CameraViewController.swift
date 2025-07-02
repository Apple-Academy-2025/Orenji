//
//  VideoRecorderModelView.swift
//  RecordFeature
//
//  Created by Fariz Ajy Putra on 21/06/25.
//


import UIKit
import AVFoundation
import SwiftUI


class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    var lastFrameTimestamp: TimeInterval = 0
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

        captureSession.sessionPreset = .high
        
        // Input kamera belakang
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                               for: .video,
                                                               position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else {
            print("Gagal inisialisasi kamera belakang")
            return
        }
        captureSession.addInput(videoInput)
        
        // Tambah output movie file (rekaman)
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        // Tambah output video data (frame realtime)
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.alwaysDiscardsLateVideoFrames = false
        let videoDataOutputQueue = DispatchQueue(label: "video_data_output_queue")
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }
        
        captureSession.commitConfiguration()
        
        // Setup preview layer
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.frame = view.layer.bounds
        videoPreviewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(videoPreviewLayer)
        

        // Mulai sesi
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    
    func captureOutput(_ output: AVCaptureOutput,
                           didOutput sampleBuffer: CMSampleBuffer,
                           from connection: AVCaptureConnection) {
            guard !isRecording else {
                // Sedang rekam, skip kirim frame
                return
            }
            
            let currentTime = CFAbsoluteTimeGetCurrent()
            if currentTime - lastFrameTimestamp > 0.1 {
                lastFrameTimestamp = currentTime
                
                if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
                    let context = CIContext()
                    if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                        let originalUIImage = UIImage(cgImage: cgImage)
                        if let resizedImage = resizeImage(image: originalUIImage, targetWidth: 250),
                           let rotatedImage = rotateUIImage(resizedImage, byDegrees: 90),
                           let imageData = rotatedImage.jpegData(compressionQuality: 0.2) {
                            WatchConnectivityManager.shared.sendFrameToWatch(imageData)
                        }
                    }
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
    
    private func rotateUIImage(_ image: UIImage, byDegrees degrees: CGFloat) -> UIImage? {
        let radians = degrees * .pi / 180
        var newSize = CGRect(origin: .zero, size: image.size)
            .applying(CGAffineTransform(rotationAngle: radians))
            .integral.size
        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
            context.rotate(by: radians)
            image.draw(in: CGRect(x: -image.size.width / 2,
                                  y: -image.size.height / 2,
                                  width: image.size.width,
                                  height: image.size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return rotatedImage
        }

        return nil
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
