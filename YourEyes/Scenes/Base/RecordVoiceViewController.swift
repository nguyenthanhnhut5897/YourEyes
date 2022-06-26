//
//  RecordVoiceViewController.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import UIKit
import AVFoundation
import Speech

class RecordVoiceViewController: YEBaseViewController {
    var recordingSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    var isRequestRecording: Bool = false
    var isAllowRecording: Bool = false
    
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
            audioRecorder?.record()

//            recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil
        
        playSound()
    }
    
    func loadRecording() {}
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func handleDeniedAudioAuthorization() {
        guard isRequestRecording else { return }
        
        self.showAlertWithTwoOption(title: "", message: "Go to setting", okAction: {
            if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        })
    }
    
    func playSound() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: audioFilename.absoluteURL, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }

            player.play()

            transcribeAudio(url: audioFilename)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // MARK: SFSpeechRecognizer
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
    
    func transcribeAudio(url: URL) {
        // create a new recognizer and point it at our audio
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: url)

        // start recognition!
        recognizer?.recognitionTask(with: request) { [unowned self] (result, error) in
            // abort if we didn't get any transcription back
            guard let result = result else {
                print("There was an error: \(error!)")
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
    
    func speechTo(text: String) {}
}

extension RecordVoiceViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}
