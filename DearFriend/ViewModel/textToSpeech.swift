//
//  textToSpeech.swift
//  DearFriend
//
//  Created by Tony Nguyen on 2024-08-12.
//

import Foundation
import AVFoundation
import AudioToolbox

class TextToSpeech {
    static let synthesizer = AVSpeechSynthesizer()

    static func speak(text: String) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5  // Adjust speech rate
        synthesizer.speak(utterance)
    }

    static func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
