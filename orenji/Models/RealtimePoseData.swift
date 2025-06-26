//
//  RealtimePoseData.swift
//  orenji
//
//  Created by Muhamad Fannan Najma Falahi on 25/06/25.
//


struct RealtimePoseData: Hashable, Codable {
    var phase: String
    var isPoseCorrect: Bool
    var correctionMessage: String?
    var holdCountdown: Int?
}
