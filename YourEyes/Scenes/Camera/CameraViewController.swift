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
    
    let previewView = UIView()
    let captureImageView = UIImageView().then {
        $0.backgroundColor = .brown
        $0.isHidden = true
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
    let textToSpeech = TextToSpeech()
    var isAllowCamera: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubviews(previewView, captureImageView, pressButton)
        pressButton.addTarget(self, action: #selector(didTakePhoto), for: .touchUpInside)
        
        previewView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        pressButton.snp.makeConstraints {
            $0.bottom.equalTo(-ViewUI.MainBottomInset - ViewUI.Padding * 2)
            $0.size.equalTo(64)
            $0.centerX.equalToSuperview()
        }
        captureImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width / 5)
            $0.height.equalTo(UIScreen.main.bounds.height / 5)
            $0.bottom.equalTo(-ViewUI.MainBottomInset)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstLayout {
            textToSpeech.start(["Please press the center bottom button to take a picture."], [1])
        }
        
        isFirstLayout = false
        
        guard isAllowCamera else {
            showCameraIfAuthorized()
            return
        }
        
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.captureSession.stopRunning()
    }
    
    private func showCameraIfAuthorized() {
        let cameraAuthorization = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorization {
        case .authorized:
            self.showCamera()
            self.isAllowCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] (authorized) in
                DispatchQueue.main.async { [weak self] in
                    if authorized {
                        self?.isAllowCamera = true
                        self?.showCamera()
                    } else {
                        print("handle Denied Camera Authorization")
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
        self.showAlertWithTwoOption(title: "", message: "Go to setting", okAction: {
            if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        })
    }
    
    func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.connection?.videoOrientation = .portrait
        
        guard let videoPreviewLayer = videoPreviewLayer else { return }
        previewView.layer.addSublayer(videoPreviewLayer)
        
        self.videoPreviewLayer?.frame = self.previewView.bounds
        self.captureSession.startRunning()
    }
    
    @objc func didTakePhoto() {
#if targetEnvironment(simulator)
        let model = ConversationViewModel(imageData: nil)
        let vc = ConversationViewController()
        vc.viewModel = model
        
        navigationController?.pushViewController(vc, animated: true)
#else
        guard isAllowCamera else {
            showCameraIfAuthorized()
            return
        }
        
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
        
#endif
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
            
        let image = UIImage(data: imageData)
        captureImageView.image = image
        
        let model = ConversationViewModel(imageData: image)
        let vc = ConversationViewController()
        vc.viewModel = model
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
