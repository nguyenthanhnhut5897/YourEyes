//
//  RecordVoiceViewController.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import UIKit
import AVFoundation
import Speech
import SVProgressHUD

class RecordVoiceViewController: YEBaseViewController {
    var recordingSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    var isRequestRecording: Bool = false
    var isAllowRecording: Bool = false
    let textToSpeech = TextToSpeech()
    
    // MARK: Voice record Permission
    func requestRecording() {
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
            
            recordingSession?.requestRecordPermission() { [weak self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self?.isAllowRecording = true
                        self?.loadRecording()
                        self?.requestTranscribePermissions()
                    } else {
                        self?.handleDeniedAudioAuthorization()
                    }
                    
                    self?.isRequestRecording = true
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    private func handleDeniedAudioAuthorization() {
        guard isRequestRecording else { return }
        
        self.showAlertWithTwoOption(title: "", message: "Go to setting", okAction: {
            if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        })
    }
    
    // MARK: SFSpeechRecognizer Authorization
    func requestTranscribePermissions() {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .notDetermined:
            SFSpeechRecognizer.requestAuthorization { authStatus in
                DispatchQueue.main.async {
                    if authStatus == .authorized {
                        print("Good to go!")
                    } else {
                        print("Transcription permission was declined.")
                    }
                }
            }
        case .restricted, .denied:
            self.handleDeniedAudioAuthorization()
        default:
            break
        }
    }
    
    // MARK: Recording
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            startCountTimer(timeInterval: 0.01)
            
//            recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil
        
        transcribeSound()
    }
    
    func loadRecording() {}
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // MARK: Speech to text
    
    func transcribeSound() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        DispatchQueue.global().asyncAfter(deadline: .now()) { [weak self] in
            self?.transcribeAudio(url: audioFilename)
        }
    }
    
    func transcribeAudio(url: URL) {
        // create a new recognizer and point it at our audio
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: url)

        SVProgressHUD.show()
        
        // start recognition!
        recognizer?.recognitionTask(with: request) { [unowned self] (result, error) in
            
            SVProgressHUD.dismiss()
            
            // abort if we didn't get any transcription back
            guard let result = result else {
                print("There was an error: \(error!)")
                self.showAlertWith(message: "There was an error")
                self.textToSpeech.start(["There was an error"], [1])
                return
            }

            // if we got the final transcription back, print it
            if result.isFinal {
                // pull out the best transcription...
                print(result.bestTranscription.formattedString)
                speechTo(text: result.bestTranscription.formattedString)
            }
        }
    }
    
    func speechTo(text: String) {
        self.textToSpeech.start([text], [1])
    }
    
    // MARK:
    override func handleInput(_ timer: Timer) {
        super.handleInput(timer)
        
        self.audioRecorder?.updateMeters()
        self.updateVoiceLevel(level: self.normalizeSoundLevel(level: self.audioRecorder?.averagePower(forChannel: 0) ?? 0))
    }
    
    override func handleFinishCountTimer() {
        self.finishRecording(success: true)
    }
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        guard level < 0 else { return 0.1 } // Check if level start
        
        return max(0.2, CGFloat(level) + 50) / 2 // between 0.1 and 25
    }
    
    func updateVoiceLevel(level: CGFloat) {}
}

extension RecordVoiceViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}
