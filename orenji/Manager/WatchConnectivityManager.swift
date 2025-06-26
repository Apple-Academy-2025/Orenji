import WatchConnectivity
import SwiftUI

class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()
    var endSessionChoiceHandler: ((Bool) -> Void)?
    private var lastSentDisplayState: (state: String, value: Int?)?
    private var lastSentCameraPoseStatus: Bool?
    private var lastActiveSessionType: SessionType?
    @Published var isSessionActive = false
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("Aktivasi sesi WatchConnectivity gagal: \(error.localizedDescription)")
            } else {
                print("Sesi WatchConnectivity berhasil diaktifkan.")
                self.sendFullStateToWatch()
            }
            if activationState == .activated {
                print("Sesi WatchConnectivity aktif di iOS.")
                DispatchQueue.main.async {
                    self.isSessionActive = true
                }
            } else {
                DispatchQueue.main.async {
                    self.isSessionActive = false
                }
            }
        }
    }
    
    func sendAppState(state: Bool) {
        guard WCSession.default.isReachable else {
            print("Watch is not reachable")
            return
        }
        let message = ["appState": state]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Error sending appState message: \(error.localizedDescription)")
        }
    }
    
    func sendIdleState(){
        guard WCSession.default.isReachable else { return }
        let message = ["idleState": "idle"]
        print("state idle")
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Error sending appState message: \(error.localizedDescription)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) { }
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let request = message["requestStateUpdate"] as? Bool, request == true {
            print("Menerima permintaan state update dari Watch. Mengirim state terbaru...")
            self.sendFullStateToWatch()
            return
        }
        if let action = message["realtimeAction"] as? [String: Any] {
            if let choice = action["endSessionChoice"] as? Bool {
                DispatchQueue.main.async {
                    self.endSessionChoiceHandler?(choice)
                }
            }
        }
    }
    
    func sendStartSessionCommand(type: SessionType) {
        guard WCSession.default.isReachable else { return }
        self.lastActiveSessionType = type
        let message: [String: Any] = [
            "sessionControl": "start",
            "sessionType": type.rawValue
        ]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Gagal mengirim start session command: \(error.localizedDescription)")
        }
    }
    
    func sendStopSessionCommand(sessionType: SessionType) {
        guard WCSession.default.isReachable else { return }
        self.lastActiveSessionType = nil
        self.lastSentDisplayState = nil
        let message: [String: Any] = ["sessionControl": "stop"]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Gagal mengirim stop session command: \(error.localizedDescription)")
        }
        if sessionType == .recording {
            sendAnalysisResultsToWatch(sessions: MockData.sessions)
        }
    }
    
    private func sendAnalysisResultsToWatch(sessions: [RecordAnalysisModel]) {
        do {
            let encodedData = try JSONEncoder().encode(sessions)
            let userInfo = ["analysisResult": encodedData]
            WCSession.default.transferUserInfo(userInfo)
            print("Mengirim \(sessions.count) hasil sesi ke Watch.")
        } catch {
            print("Gagal meng-encode atau mengirim hasil analisis: \(error.localizedDescription)")
        }
    }
    
    func sendRealtimeResultsToWatch(total: Int) {
        let userInfo: [String: Any] = ["realtimeResultCount": total]
        WCSession.default.transferUserInfo(userInfo)
        print("Mengirim total \(total) hasil sesi ke Watch.")
    }

    
    func sendCameraPoseStatusToWatch(isCorrect: Bool) {
        guard WCSession.default.isReachable else { return }
        self.lastSentCameraPoseStatus = isCorrect
        let message: [String: Any] = ["isCameraPoseCorrect": isCorrect]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Gagal mengirim status camera pose: \(error.localizedDescription)")
        }
    }
    
    func sendDisplayStateToWatch(_ state: String, value: Int? = nil) {
        guard WCSession.default.isReachable else { return }
        self.lastSentDisplayState = (state, value)
        var message: [String: Any] = ["displayState": state]
        if let value = value {
            message["value"] = value
        }
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Gagal mengirim display state '\(state)': \(error.localizedDescription)")
        }
    }
    
    func sendFrameToWatch(_ frameData: Data) {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessageData(frameData, replyHandler: nil) { error in }
    }
    
    func sendHapticSignalToWatch() {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(["haptic": "tap"], replyHandler: nil)
    }
    
    func sendPoseUpdate(data: Data) {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(["poseUpdate": data], replyHandler: nil, errorHandler: nil)
    }
    private func sendFullStateToWatch() {
        guard WCSession.default.isReachable else { return }
        var fullState: [String: Any] = [:]
        if let sessionType = lastActiveSessionType {
            fullState["sessionControl"] = "start"
            fullState["sessionType"] = sessionType.rawValue
        } else {
            fullState["sessionControl"] = "stop"
        }
        
        if let displayState = lastSentDisplayState {
            fullState["displayState"] = displayState.state
            if let value = displayState.value {
                fullState["value"] = value
            }
        }
        if let poseStatus = lastSentCameraPoseStatus {
            fullState["isCameraPoseCorrect"] = poseStatus
        }
        if !fullState.isEmpty {
            let message = ["fullStateUpdate": fullState]
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Gagal mengirim full state update: \(error.localizedDescription)")
            }
        }
    }
}
