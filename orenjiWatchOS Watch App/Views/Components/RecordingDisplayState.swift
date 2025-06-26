//
//  RecordingDisplayState.swift
//  orenji
//
//  Created by Muhamad Fannan Najma Falahi on 22/06/25.
//


enum RecordingDisplayState: Hashable {
    case detectingPose
    case showingMessage
    case countingDown(Int)
    case showingStart
    case activelyRecording
    case activelyRealtime
}
