//
//  RecordFeatureViewModel.swift
//  RecordFeature
//
//  Created by Fariz Ajy Putra on 22/06/25.
//


import CoreML
import SwiftUI
import UIKit
import AVFoundation
import Vision
import SwiftData
import CoreGraphics


class RecordFeatureViewModel: ObservableObject {
    @Published var lastVideoURL: URL? = nil
    @Published var frames: [UIImage] = []
    @Published var frameTimes : [Double] = []
    @Published var predictions: [FramePrediction] = []
    @Published var isProcessingML = false
    @Published var isExtracting = false
    @Published var bestFrame : [FramePrediction] = []
    @Published var bestFrameData : [FrameData] = []
    
    
    let inputSize = CGSize(width: 360, height: 360)
    let mlModel: FreethrowModel

    init() {
        do {
            mlModel = try FreethrowModel()
        } catch {
            fatalError("Gagal load FreethrowModel: \(error)")
        }
    }
    ////===================================================
    func simpanPhaseData(
        context: ModelContext,
        frames: [FrameData],
        date: Date? = nil
    ) {
        let phase = PhaseData(frames: frames, date: date)
        context.insert(phase)
    }
    func konversiPrediksiKeFrameData(_ predictions: [FramePrediction]) -> [FrameData] {
        var result: [FrameData] = []
        for prediction in predictions {
            let frame = FrameData(
                imageForDisplay: prediction.imageForDisplay,
                label: prediction.label,
                detectedDominant: prediction.detectedDominant,
                elbowAngle: prediction.elbowAngle != nil ? Double(prediction.elbowAngle!) : nil,
                kneeAngle: prediction.kneeAngle != nil ? Double(prediction.kneeAngle!) : nil
            )
            result.append(frame)
        }
        return result
    }
    func processML(
        from url: URL,
        completion: @escaping () -> Void
    ) {
        print("Proses ML dimulai")
        isProcessingML = true
        predictions = []
        processFramesWithModel(
            frames: frames,
            model: mlModel,
            inputSize: inputSize
        ) { results in
            print("Hasil ML: \(results.count)")
            let framePreds: [FramePrediction] = results.enumerated().compactMap { idx, tuple in
                let imageTime = (idx < self.frameTimes.count) ? self.frameTimes[idx] : 0.0
                let result = self.extractPoseJoints(from: self.frames[idx])
                let joints = result.joints
                let dominant = result.detectedDominant

                // Filter hanya sisi dominan
                let filteredJoints: [VNHumanBodyPoseObservation.JointName: CGPoint]? = {
                    guard let dominant = dominant, let joints = joints else { return nil }
                    let rightJoints: [VNHumanBodyPoseObservation.JointName] = [.rightShoulder, .rightElbow, .rightWrist, .rightHip, .rightKnee, .rightAnkle]
                    let leftJoints: [VNHumanBodyPoseObservation.JointName]  = [.leftShoulder, .leftElbow, .leftWrist, .leftHip, .leftKnee, .leftAnkle]
                    return joints.filter { (dominant == "right" ? rightJoints : leftJoints).contains($0.key) }
                }()

                // Hitung sudut
                var elbowAngle: CGFloat? = nil
                var kneeAngle: CGFloat? = nil

                if let joints = filteredJoints, let dominant = dominant {
                    if dominant == "right" {
                        if let s = joints[.rightShoulder], let e = joints[.rightElbow], let w = joints[.rightWrist] {
                            elbowAngle = self.angleBetweenPoints(a: s, b: e, c: w)
                        }
                        if let h = joints[.rightHip], let k = joints[.rightKnee], let a = joints[.rightAnkle] {
                            kneeAngle = self.angleBetweenPoints(a: h, b: k, c: a)
                        }
                    } else {
                        if let s = joints[.leftShoulder], let e = joints[.leftElbow], let w = joints[.leftWrist] {
                            elbowAngle = self.angleBetweenPoints(a: s, b: e, c: w)
                        }
                        if let h = joints[.leftHip], let k = joints[.leftKnee], let a = joints[.leftAnkle] {
                            kneeAngle = self.angleBetweenPoints(a: h, b: k, c: a)
                        }
                    }
                }
                return FramePrediction(
                    imageForDisplay: nil,  // Akan diisi setelah ini
                    imageForMLProcess: tuple.0,
                    imageTime: imageTime,
                    label: tuple.1,
                    joints: filteredJoints,
                    detectedDominant: dominant,
                    elbowAngle: elbowAngle,
                    kneeAngle: kneeAngle,
                    date: Date.now
                )
            }

            // Cari frame terbaik sesuai target
            var bestFrames: [ShotPhase: FramePrediction] = [:]
            for target in phaseTargets {
                var minScore: CGFloat = .greatestFiniteMagnitude
                var best: FramePrediction? = nil
                for fp in framePreds {
                    guard fp.label.lowercased() == target.name.rawValue else { continue }
                    guard let elbow = fp.elbowAngle, let knee = fp.kneeAngle else { continue }

                    let elbowPenalty: CGFloat
                    if target.elbowRange.contains(elbow) {
                        elbowPenalty = 0
                    } else {
                        let mid = (target.elbowRange.lowerBound + target.elbowRange.upperBound) / 2
                        elbowPenalty = abs(elbow - mid)
                    }
                    let score = abs(knee - target.kneeValue) + elbowPenalty

                    if score < minScore {
                        minScore = score
                        best = fp
                    }
                }
                if let best = best {
                    bestFrames[target.name] = best
                }
            }

            // Ambil frame terpilih saja
            let selectedFrames = ShotPhase.allCases.compactMap { bestFrames[$0] }
            
            // --- PROSES AMBIL FRAME IMAGE DARI VIDEO (asinkron, grup dispatch) ---
            let group = DispatchGroup()
            var updatedPredictions: [FramePrediction] = selectedFrames

            for (i, prediction) in selectedFrames.enumerated() {
                group.enter()
                self.extractFrameForDisplay(from: url, at: prediction.imageTime) { image in
                    if let image = image {
                        var updatedPrediction = prediction
                        updatedPrediction.imageForDisplay = image
                        updatedPredictions[i] = updatedPrediction
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.predictions = updatedPredictions
                self.predictions = self.orderedBestFramesWithPlaceholder(from: self.predictions)
                self.isProcessingML = false
                print(self.predictions)
                completion()
            }
        }
    }
    

    // -- Fungsi untuk ambil image di waktu tertentu pada video --
    func extractFrameForDisplay(
        from videoURL: URL,
        at timeInSeconds: Double,
        completion: @escaping (UIImage?) -> Void
    ) {
        let asset = AVURLAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        let time = CMTime(seconds: timeInSeconds, preferredTimescale: 600)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    completion(uiImage)
                }
            } catch {
                print("Gagal ekstrak frame di detik \(timeInSeconds): \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    ////===================================================
    func extractAllFramesProcess(from url: URL, completion: @escaping () -> Void) {
        frames = []
        frameTimes = []
        predictions = []
        isExtracting = true
        extractAllFramesForMLProcess(from: url) { frame in
            let targetSize = CGSize(width: 203, height: 360)
            let processedFrames: [UIImage] = frame.map { (image, _) in
                self.padToSquare(image: self.resizeImage(image, targetSize: targetSize))
            }
            let times: [Double] = frame.map { $0.1 }
            DispatchQueue.main.async {
                self.frames = processedFrames
                self.frameTimes = times
                self.isExtracting = false
                self.processML(from: url,completion: {completion()})
                
                
                
            }

        }
    }
    ////===================================================
    func extractAllFramesForMLProcess(from videoURL: URL, completion: @escaping ([(UIImage, Double)]) -> Void) {
        print("extractAllFrames dipanggil, url: \(videoURL)")
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [(UIImage, Double)] = []
            let asset = AVURLAsset(url: videoURL)
            guard let track = asset.tracks(withMediaType: .video).first else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            let fps = Double(track.nominalFrameRate)
            let durationSeconds = CMTimeGetSeconds(asset.duration)
            let totalFrames = Int(durationSeconds * fps)
            let increment = 1.0 / fps
            
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            imageGenerator.requestedTimeToleranceAfter = .zero
            imageGenerator.requestedTimeToleranceBefore = .zero
            
            var times: [NSValue] = []
            for i in 0..<totalFrames {
                let seconds = Double(i) * increment
                let time = CMTime(seconds: seconds, preferredTimescale: asset.duration.timescale)
                times.append(NSValue(time: time))
            }
            
            var count = 0
            var frameDict: [Int: (UIImage, Double)] = [:]
            
            imageGenerator.generateCGImagesAsynchronously(forTimes: times) { requestedTime, cgImage, actualTime, result, error in
                if let cgImage = cgImage {
                    let seconds = CMTimeGetSeconds(actualTime)
                    let index = times.firstIndex(of: NSValue(time: requestedTime)) ?? count
                    frameDict[index] = (UIImage(cgImage: cgImage), seconds)
                }
                count += 1
                if count == times.count {
                    let sorted = frameDict.keys.sorted().compactMap { frameDict[$0] }
                    DispatchQueue.main.async {
                        completion(sorted)
                    }
                }
            }
        }
    }

    ////===================================================
    func selectBestFramesPerPhase() {
        var bestFrames: [ShotPhase: FramePrediction] = [:]
        for target in phaseTargets {
            var minScore: CGFloat = .greatestFiniteMagnitude
            var best: FramePrediction? = nil
            for fp in predictions {
                guard let elbow = fp.elbowAngle, let knee = fp.kneeAngle else { continue }
                if target.elbowRange.contains(elbow) {
                    let kneeScore = abs(knee - target.kneeValue)
                    if kneeScore < minScore {
                        minScore = kneeScore
                        best = fp
                    }
                }
            }
            if let best = best {
                bestFrames[target.name] = best
            }
        }
        DispatchQueue.main.async {
            self.predictions = ShotPhase.allCases.compactMap { bestFrames[$0] }
        }
    }
    ////===================================================
    func angleBetweenPoints(a: CGPoint, b: CGPoint, c: CGPoint) -> CGFloat {
        let ab = CGVector(dx: a.x - b.x, dy: a.y - b.y)
        let cb = CGVector(dx: c.x - b.x, dy: c.y - b.y)
        let dot = ab.dx * cb.dx + ab.dy * cb.dy
        let magAb = sqrt(ab.dx * ab.dx + ab.dy * ab.dy)
        let magCb = sqrt(cb.dx * cb.dx + cb.dy * cb.dy)
        let cosAngle = dot / (magAb * magCb + .ulpOfOne)
        let angleRad = acos(min(1, max(-1, cosAngle)))
        return angleRad * 180 / .pi
    }
    ////===================================================
    func extractPoseJoints(from image: UIImage) -> (
        joints: [VNHumanBodyPoseObservation.JointName: CGPoint]?,
        detectedDominant: String?
    ) {
        var cgImage: CGImage?
        if Thread.isMainThread {
            cgImage = image.cgImage
        } else {
            DispatchQueue.main.sync {
                cgImage = image.cgImage
            }
        }
        guard let cgImage = cgImage else { return (nil, nil) }
        print("DEBUG: Ukuran gambar saat ekstrak joint: \(cgImage.width)x\(cgImage.height)")
        print("DEBUG: Ukuran image.size: \(image.size.width)x\(image.size.height) (scale: \(image.scale))")
        var points: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        var leftConf: Float = 0
        var rightConf: Float = 0
        var leftY: CGFloat = 0
        var rightY: CGFloat = 0
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global(qos: .userInitiated).async {
            let request = VNDetectHumanBodyPoseRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
                if let observation = request.results?.first as? VNHumanBodyPoseObservation {
                    let targetJoints: [VNHumanBodyPoseObservation.JointName] = [
                        .leftShoulder, .leftElbow, .leftWrist,
                        .rightShoulder, .rightElbow, .rightWrist,
                        .leftHip, .leftKnee, .leftAnkle,
                        .rightHip, .rightKnee, .rightAnkle
                    ]
                    let size = CGSize(width: cgImage.width, height: cgImage.height)
                    for joint in targetJoints {
                        if let p = try? observation.recognizedPoint(joint), p.confidence > 0.2 {
                            points[joint] = CGPoint(x: p.x * size.width, y: (1-p.y) * size.height)
                            if joint == .leftWrist { leftConf = p.confidence; leftY = (1-p.y) * size.height }
                            if joint == .rightWrist { rightConf = p.confidence; rightY = (1-p.y) * size.height }
                        }
                    }
                }
            } catch { }
            semaphore.signal()
        }
        semaphore.wait()
        var detectedDominant: String? = nil
        if leftConf > 0.2 || rightConf > 0.2 {
            if leftConf > rightConf { detectedDominant = "left" }
            else if rightConf > leftConf { detectedDominant = "right" }
            else { detectedDominant = (leftY < rightY) ? "left" : "right" }
        }
        return (points.isEmpty ? nil : points, detectedDominant)
    }
    ////===================================================
    func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    ////===================================================
    func padToSquare(image: UIImage) -> UIImage {
        let originalWidth = image.size.width
        let originalHeight = image.size.height
        let squareLength = max(originalWidth, originalHeight)
        
        let size = CGSize(width: squareLength, height: squareLength)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let paddedImage = renderer.image { ctx in
            UIColor.black.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            
            let x = (squareLength - originalWidth) / 2.0
            let y = (squareLength - originalHeight) / 2.0
            image.draw(in: CGRect(x: x, y: y, width: originalWidth, height: originalHeight))
        }
        
        return paddedImage
    }
    ////===================================================
    func pixelBuffer(from image: UIImage, size: CGSize) -> CVPixelBuffer? {
        UIGraphicsBeginImageContextWithOptions(size, true, 2.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = newImage?.cgImage else { return nil }
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ] as CFDictionary

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(size.width),
            Int(size.height),
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBuffer
        )
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        CVPixelBufferUnlockBaseAddress(buffer, [])
        return buffer
    }
    ////===================================================
       func feedbackMethod(angle: Int, lowAngle: Int, highAngle: Int, whatAngle: String) -> String {
        if angle < lowAngle {
            return "Your \(whatAngle) was too low. Try to open more your elbow"
        } else if angle > highAngle {
            return "Your \(whatAngle) was too high. Try to close more your elbow"
        } else {
            return "Your \(whatAngle) fit perfectly on your posture"
        }
    }
    ////===================================================
    func processFramesWithModel(
        frames: [UIImage],
        model: FreethrowModel,
        inputSize: CGSize,
        completion: @escaping ([(UIImage, String)]) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [(UIImage, String)] = []

            for frame in frames {
                guard let buffer = self.pixelBuffer(from: frame, size: inputSize) else {
                    results.append((frame, "Failed to create buffer"))
                    continue
                }
                guard let prediction = try? model.prediction(image: buffer) else {
                    results.append((frame, "Failed to predict"))
                    continue
                }
                let label = prediction.target
                results.append((frame, label))
            }
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
    func fetchAllPhaseData(context: ModelContext) -> [PhaseData] {
        let fetchDescriptor = FetchDescriptor<PhaseData>()
        do {
            let phases = try context.fetch(fetchDescriptor)
            return phases
        } catch {
            print("Error fetching PhaseData: \(error)")
            return []
        }
    }
    func printAllPhaseData(_ phases: [PhaseData]) {
        print("Jalan")
        for (i, phase) in phases.enumerated() {
            print("----- Phase #\(i+1) -----")
            print("UUID: \(phase.uuid)")
            print("Tanggal: \(phase.date?.description ?? "-")")
            print("Jumlah Frame: \(phase.frames.count)")
            for (j, frame) in phase.frames.enumerated() {
                print("  Frame #\(j+1):")
                print("    Label: \(frame.label)")
                print("    Dominant: \(frame.detectedDominant ?? "-")")
                print("    Elbow Angle: \(frame.elbowAngle?.description ?? "-")")
                print("    Knee Angle: \(frame.kneeAngle?.description ?? "-")")
            }
        }
    }
    func simpanKeDataset(
        context: ModelContext,
        frames: [FrameData],
        date: Date? = nil
    ) {
        let phase = PhaseData(frames: frames, date: date)
        context.insert(phase)
    }
    func konversiSemuaPredictionKeFrameData() {
        bestFrameData = predictions.map { prediction in
            FrameData(
                imageForDisplay: prediction.imageForDisplay,
                label: prediction.label,
                detectedDominant: prediction.detectedDominant,
                elbowAngle: prediction.elbowAngle != nil ? Double(prediction.elbowAngle!) : nil,
                kneeAngle: prediction.kneeAngle != nil ? Double(prediction.kneeAngle!) : nil
            )
        }
    }
    func orderedBestFramesWithPlaceholder(from frames: [FramePrediction]) -> [FramePrediction] {
        let phases = ShotPhase.allCases
        return phases.map { phase in
            if let found = frames.first(where: { $0.label.lowercased() == phase.rawValue }) {
                return found
            } else {
                // Placeholder (pakai property kosong/null)
                return FramePrediction(
                    imageForDisplay: nil,
                    imageForMLProcess: UIImage(),
                    imageTime: 0,
                    label: phase.rawValue,
                    joints: nil,
                    detectedDominant: nil,
                    elbowAngle: nil,
                    kneeAngle: nil,
                    date: nil
                )
            }
        }
    }


    ////===================================================
}
