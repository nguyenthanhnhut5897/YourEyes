//
//  Speaker.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/07/02.
//

import UIKit
import AVFoundation

class TextToSpeech: NSObject, AVSpeechSynthesizerDelegate {
    var synth: AVSpeechSynthesizer?
    var sentences: [String] = []
    var intervals: [Double] = []
    
    func start(_ sentences: [String], _ intervals: [Double]) {
        self.sentences = sentences
        self.intervals = intervals
        self.synth?.stopSpeaking(at: .immediate)
        self.synth = AVSpeechSynthesizer()
        synth?.delegate = self
        sayOne()
    }
    
    func sayOne() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }

        if let sentence = sentences.first {
            sentences.removeFirst()
            let utter = AVSpeechUtterance(string: sentence)
            self.synth?.speak(utter)
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if let interval = intervals.first {
            intervals.removeFirst()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval, execute: { [weak self] in
                self?.sayOne()
            })
        }
    }
    
    func pauseSpeaking() {
        synth?.pauseSpeaking(at: .word)
    }
    
    func continueSpeaking() {
        synth?.continueSpeaking()
    }
    
    func stop() {
        synth?.stopSpeaking(at: .word)
    }
}
