//
//  VoiceOver.swift
//  SpeakyNews
//
//  Created by Vedat Ozlu on 23.08.2022.
//

import Foundation
import AVFoundation

class VoiceOver {
    private var textForVoiceOver = ""
    var utterance : AVSpeechUtterance?
    let syntesizer = AVSpeechSynthesizer()
    
    init(textForVoiceOver : String) {
        self.textForVoiceOver = textForVoiceOver
        utterance = AVSpeechUtterance(string: self.textForVoiceOver)
    }
    func setTextForVoiceOver(textForVoiceOver : String) {
        self.textForVoiceOver = textForVoiceOver
    }
    func play(){
        if syntesizer.isPaused {
            syntesizer.continueSpeaking()
        } else {
            if textForVoiceOver.count>3 {
                if let utterance = utterance {
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                    utterance.rate = 0.1
                    syntesizer.speak(utterance)
                } else {
                    utterance = AVSpeechUtterance(string: self.textForVoiceOver)
                    utterance!.voice = AVSpeechSynthesisVoice(language: "en-GB")
                    utterance!.rate = 0.1
                    syntesizer.speak(utterance!)
                }
            }
        }
    }
    func pause(){
        syntesizer.pauseSpeaking(at: AVSpeechBoundary.immediate)
    }
}
