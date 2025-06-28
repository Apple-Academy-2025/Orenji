//
//  JointOverlay.swift
//  RecordFeature
//
//  Created by Fariz Ajy Putra on 21/06/25.
//

import Vision
import UIKit

func drawSkeleton(
    image: UIImage,
    handLineColor: UIColor = .orange,
    legLineColor: UIColor = .red
) -> UIImage? {
    guard let cgImage = image.cgImage else { return nil }

    // 1. Deteksi joint
    let request = VNDetectHumanBodyPoseRequest()
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

    var points: [VNHumanBodyPoseObservation.JointName: (CGPoint, Float)] = [:]
    do {
        try handler.perform([request])
        if let obs = request.results?.first as? VNHumanBodyPoseObservation {
            let allJoints: [VNHumanBodyPoseObservation.JointName] = [
                .leftShoulder, .leftElbow, .leftWrist,
                .rightShoulder, .rightElbow, .rightWrist,
                .leftHip, .leftKnee, .leftAnkle,
                .rightHip, .rightKnee, .rightAnkle
            ]
            let size = CGSize(width: cgImage.width, height: cgImage.height)
            for joint in allJoints {
                if let p = try? obs.recognizedPoint(joint), p.confidence > 0.2 {
                    points[joint] = (CGPoint(x: p.x * size.width, y: (1-p.y) * size.height), p.confidence)
                }
            }
        }
    } catch {
        print("VNDetectHumanBodyPoseRequest gagal: \(error)")
        return nil
    }
    if points.isEmpty { return image }

    // 2. Deteksi sisi dominan otomatis
    let leftConf = points[.leftWrist]?.1 ?? 0
    let rightConf = points[.rightWrist]?.1 ?? 0
    let leftY = points[.leftWrist]?.0.y ?? 0
    let rightY = points[.rightWrist]?.0.y ?? 0

    let dominant: String
    if leftConf > rightConf {
        dominant = "left"
    } else if rightConf > leftConf {
        dominant = "right"
    } else {
        dominant = (leftY < rightY) ? "left" : "right"
    }

    // Daftar joint tangan & kaki
    let handJoints: [VNHumanBodyPoseObservation.JointName] = dominant == "right"
        ? [.rightShoulder, .rightElbow, .rightWrist]
        : [.leftShoulder, .leftElbow, .leftWrist]
    let legJoints: [VNHumanBodyPoseObservation.JointName] = dominant == "right"
        ? [.rightHip, .rightKnee, .rightAnkle]
        : [.leftHip, .leftKnee, .leftAnkle]

    let renderer = UIGraphicsImageRenderer(size: image.size)
    let scaleX = image.size.width / CGFloat(cgImage.width)
    let scaleY = image.size.height / CGFloat(cgImage.height)
    let img = renderer.image { ctx in
        image.draw(in: CGRect(origin: .zero, size: image.size))

        func pt(_ joint: VNHumanBodyPoseObservation.JointName) -> CGPoint? {
            guard let (p, _) = points[joint] else { return nil }
            return CGPoint(x: p.x * scaleX, y: p.y * scaleY)
        }

        // --- Gambar tangan ---
        ctx.cgContext.setStrokeColor(handLineColor.cgColor)
        ctx.cgContext.setLineWidth(5.0)
        if let s = pt(handJoints[0]), let e = pt(handJoints[1]), let w = pt(handJoints[2]) {
            ctx.cgContext.move(to: s)
            ctx.cgContext.addLine(to: e)
            ctx.cgContext.addLine(to: w)
            ctx.cgContext.strokePath()
        }
        // Titik tangan
        for joint in handJoints {
            if let p = pt(joint) {
                ctx.cgContext.setFillColor(handLineColor.cgColor)
                ctx.cgContext.fillEllipse(in: CGRect(x: p.x-8, y: p.y-8, width: 16, height: 16))
            }
        }

        // --- Gambar kaki ---
        ctx.cgContext.setStrokeColor(legLineColor.cgColor)
        ctx.cgContext.setLineWidth(5.0)
        if let h = pt(legJoints[0]), let k = pt(legJoints[1]), let a = pt(legJoints[2]) {
            ctx.cgContext.move(to: h)
            ctx.cgContext.addLine(to: k)
            ctx.cgContext.addLine(to: a)
            ctx.cgContext.strokePath()
        }
        // Titik kaki
        for joint in legJoints {
            if let p = pt(joint) {
                ctx.cgContext.setFillColor(legLineColor.cgColor)
                ctx.cgContext.fillEllipse(in: CGRect(x: p.x-8, y: p.y-8, width: 16, height: 16))
            }
        }
    }
    return img
}
