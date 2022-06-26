//
//  CameraViewController.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import UIKit
import SnapKit
import AVFoundation

class CameraViewController: YEBaseViewController {
    
    let previewView = UIView().then {
        $0.backgroundColor = .gray
    }
    let captureImageView = UIImageView().then {
        $0.backgroundColor = .brown
    }
    let pressButton = UIButton().then {
        $0.setImage(UIImage(named: "camera_ic"), for: .normal)
        $0.backgroundColor = UIColor.YourEyes.buttonColor
        $0.layer.cornerRadius = 32
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    var captureSession = AVCaptureSession().then {
        $0.sessionPreset = .photo
    }
    var stillImageOutput = AVCapturePhotoOutput()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubviews(previewView, captureImageView, pressButton)
        pressButton.addTarget(self, action: #selector(didTakePhoto), for: .touchUpInside)
        
        previewView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        pressButton.snp.makeConstraints {
            $0.bottom.equalTo(-ViewUI.MainBottomInset)
            $0.size.equalTo(64)
            $0.centerX.equalToSuperview()
        }
        captureImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width / 5)
            $0.height.equalTo(UIScreen.main.bounds.height / 5)
            $0.bottom.equalTo(-ViewUI.MainBottomInset)
        }
        
        showCameraIfAuthorized()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.captureSession.stopRunning()
    }
    
    private func showCameraIfAuthorized() {
        pressButton.isUserInteractionEnabled = false
        
        let cameraAuthorization = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorization {
        case .authorized:
            self.showCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] (authorized) in
                DispatchQueue.main.async { [weak self] in
                    if authorized {
                        self?.showCamera()
                    } else {
                        self?.handleDeniedCameraAuthorization()
                    }
                }
            })
        case .restricted, .denied:
            self.handleDeniedCameraAuthorization()
        @unknown default:
            break
        }
    }
    
    private func showCamera() {
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("Unable to access back camera!")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }
    
    private func handleDeniedCameraAuthorization() {
        self.showAlertWith(message: "Unable to access back camera")
    }
    
    func setupLivePreview() {
        pressButton.isUserInteractionEnabled = true
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.connection?.videoOrientation = .portrait
        
        guard let videoPreviewLayer = videoPreviewLayer else { return }
        previewView.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.captureSession.startRunning()
            
            DispatchQueue.main.async {  [weak self] in
                guard let self = self else { return }
                
                self.videoPreviewLayer?.frame = self.previewView.bounds
                print(self.previewView.bounds)
            }
        }
    }
    
    @objc func didTakePhoto() {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
            
        let image = UIImage(data: imageData)
        captureImageView.image = image
    }
}
