//
//  SpeechManager.swift
//  orenji
//
//  Created by Muhamad Alif Anwar on 28/06/25.
//

import AVFoundation

class SpeechManager: NSObject, ObservableObject {
    private let speechSynthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false
    private var speechQueue: [String] = []
    
    private var lastSpokenMessage: String = ""
    private var lastSpokenTime: Date = .distantPast
    private let messageCooldown: TimeInterval = 2.0
    
    override init() {
        super.init()
        speechSynthesizer.delegate = self
        setupAudioSession()
    }
    
    func speak(_ message: String) {
        guard !message.isEmpty else { return }
        
        let now = Date()
        if message == lastSpokenMessage && now.timeIntervalSince(lastSpokenTime) < messageCooldown {
            print("⏭️ Skipping duplicate message: \(message)")
            return
        }
        
        lastSpokenMessage = message
        lastSpokenTime = now
        
        print("🗣️ Queueing speech: \(message)")
        
        DispatchQueue.main.async {
            if self.isSpeaking {
                self.speechQueue.append(message)
                print("📥 Added to queue. Current queue: \(self.speechQueue)")
            } else {
                self.startSpeaking(message)
            }
        }
    }
    
    private func startSpeaking(_ message: String) {
        // Don't reconfigure audio session every time - it's already configured in init
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.volume = 1.0
        utterance.pitchMultiplier = 1.0

        isSpeaking = true
        speechSynthesizer.speak(utterance)
        print("🎤 Speaking: \(message)")
    }

    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playback,
                mode: .spokenAudio,
                options: [.duckOthers, .defaultToSpeaker, .mixWithOthers]
            )
            try session.setActive(true, options: [])
            print("✅ SpeechManager audio session configured")
        } catch {
            print("❌ SpeechManager audio session error: \(error)")
        }
    }
    
    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        speechQueue.removeAll()
        isSpeaking = false
    }
    
    private func processQueue() {
        guard !isSpeaking, !speechQueue.isEmpty else { return }
        let nextMessage = speechQueue.removeFirst()
        startSpeaking(nextMessage)
    }
}

extension SpeechManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("✅ Started speaking: \(utterance.speechString)")
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("✅ Finished speaking: \(utterance.speechString)")
        DispatchQueue.main.async {
            self.isSpeaking = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.processQueue()
            }
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("❌ Speech cancelled: \(utterance.speechString)")
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.processQueue()
        }
    }
}
