//
//  WatchConnectivityManager.swift
//  orenji
//
//  Created by Muhamad Fannan Najma Falahi on 25/06/25.
//

import WatchKit
import WatchConnectivity
import SwiftUI

class WatchConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    
    static let shared = WatchConnectivityManager()
    
    @Published var receivedImage: UIImage?
    @Published var isCompanionAppReachable: Bool = false
    @Published var isCameraPoseCorrect: Bool = false
    @Published var appState: AppState = .idle
    @Published var recordingDisplay: RecordingDisplayState = .detectingPose
    @Published var activeSessionType: SessionType?
    
    @Published var trainingSessions: [RecordAnalysisModel] = []
    @Published var realtimePoseData: RealtimePoseData?
    @Published var realtimeResult: Int?
    
    // MARK: - Initializer
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    // MARK: - Session Message Handlers
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            
            if let fullState = message["fullStateUpdate"] as? [String: Any] {
                self.isCompanionAppReachable = true
                print("Menerima full state update dari iPhone.")
                
                if let sessionControl = fullState["sessionControl"] as? String {
                    self.handleSessionControl(action: sessionControl, message: fullState)
                }
                if let displayStateString = fullState["displayState"] as? String {
                    self.handleDisplayStateChange(displayStateString, message: fullState)
                }
                if let cameraPoseStatus = fullState["isCameraPoseCorrect"] as? Bool {
                    self.isCameraPoseCorrect = cameraPoseStatus
                }
                return
            }
            
            if let sessionControl = message["idleState"] as? String {
                self.resetToIdle()
            }
            
            if let haptic = message["haptic"] as? String, haptic == "tap" {
                WKInterfaceDevice.current().play(.success)
            }
            
            if let cameraPoseStatus = message["isCameraPoseCorrect"] as? Bool {
                self.isCameraPoseCorrect = cameraPoseStatus
            }
            
            if let poseDataDict = message["poseUpdate"] as? Data {
                if let decoded = self.decodePoseData(from: poseDataDict) {
                    self.realtimePoseData = decoded
                }
            }
            
            if let realtimeResultData = message["realtimeResultCount"] as? Int {
                print(realtimeResultData)
                self.realtimeResult = realtimeResultData
                self.appState = .resultRealtime
            }
            
            if let displayStateString = message["displayState"] as? String {
                self.handleDisplayStateChange(displayStateString, message: message)
            }
            
            if let sessionControl = message["sessionControl"] as? String {
                self.handleSessionControl(action: sessionControl, message: message)
            }
            
            if let appState = message["appState"] as? Bool {
                self.isCompanionAppReachable = appState
            }
        }
    }

    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        let receivedURL = file.fileURL
        print("Menerima file (didReceiveFile) di: \(receivedURL.path)")
        do {
            let resultData = try Data(contentsOf: receivedURL)
            let decodedSessions = try JSONDecoder().decode([RecordAnalysisModel].self, from: resultData)
            DispatchQueue.main.async {
                self.trainingSessions = decodedSessions
                self.appState = .resultRecord
                print("\(decodedSessions.count) sesi dari file berhasil di-decode dan di-publish.")
            }
            
        } catch {
            print("Gagal membaca atau men-decode data dari file yang diterima: \(error.localizedDescription)")
        }
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        guard self.appState == .record else { return }
        
        DispatchQueue.main.async {
            if let image = UIImage(data: messageData) {
                self.receivedImage = image
            }
        }
    }

    // MARK: - Session Events
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isCompanionAppReachable = session.isReachable
            if session.isReachable {
                print("Companion App menjadi terjangkau, meminta state terbaru.")
                self.requestStateUpdateFromPhone()
            }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("Aktivasi sesi di Watch gagal: \(error.localizedDescription)")
            }
            self.isCompanionAppReachable = session.isReachable
            if session.isReachable {
                print("Companion App menjadi terjangkau, meminta state terbaru.")
                self.requestStateUpdateFromPhone()
            }
        }
    }

    // MARK: - Helpers
    private func requestStateUpdateFromPhone() {
        guard WCSession.default.isReachable else { return }
        
        let message: [String: Any] = ["requestStateUpdate": true]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Gagal mengirim permintaan state: \(error.localizedDescription)")
        }
    }

    private func handleSessionControl(action: String, message: [String: Any]) {
        switch action {
        case "start":
            print("Menerima: start session")
            if let typeString = message["sessionType"] as? String,
               let type = SessionType(rawValue: typeString) {
                self.activeSessionType = type
                self.trainingSessions = []
                self.appState = .record
            }
        case "stop":
            print("Menerima: stop session")
            self.activeSessionType = nil
        default:
            break
        }
    }

    private func decodePoseData(from data: Data) -> RealtimePoseData? {
        do {
            return try JSONDecoder().decode(RealtimePoseData.self, from: data)
        } catch {
            print("❌ Failed to decode pose data:", error)
            return nil
        }
    }

    private func handleDisplayStateChange(_ stateString: String, message: [String: Any]) {
        switch stateString {
        case "detectingPose":
            recordingDisplay = .detectingPose
        case "showMessage":
            recordingDisplay = .showingMessage
        case "showNumber":
            let number = message["value"] as? Int ?? 0
            recordingDisplay = .countingDown(number)
        case "showStart":
            recordingDisplay = .showingStart
        case "activelyRecording":
            recordingDisplay = .activelyRecording
        case "activelyRealtime":
            recordingDisplay = .activelyRealtime
        default:
            break
        }
    }

    func resetToIdle() {
        self.appState = .idle
        self.activeSessionType = nil
        self.trainingSessions = []
        self.receivedImage = nil
        self.isCameraPoseCorrect = false
        self.recordingDisplay = .detectingPose
    }

    func sendRealtimeAction(_ action: [String: Any]) {
        guard WCSession.default.isReachable else { return }
        let message = ["realtimeAction": action]
        WCSession.default.sendMessage(message, replyHandler: nil)
    }
}
