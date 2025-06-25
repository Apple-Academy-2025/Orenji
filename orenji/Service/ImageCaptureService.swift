//
//  ImageCaptureService.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 20/06/25.
//

import Foundation
import UIKit

//ini untuk menyimpan jepretan 4 frame foto itu lalu nilai string nya diparse ke json recordstorage
protocol ImageCaptureService {
    func saveImage(_ image: UIImage, for phase: String) throws -> String
    func loadImage(named filename: String) -> UIImage?
}
