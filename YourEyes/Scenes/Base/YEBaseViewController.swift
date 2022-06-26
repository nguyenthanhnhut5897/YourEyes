//
//  YEBaseViewController.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import UIKit

class YEBaseViewController: BaseViewController, UIScrollViewDelegate {
    var page: Int = 1
    var loadMore: Bool = true
    var isLoading: Bool = false
    var isFirstLayout: Bool = true
    var isFirstBlur: Bool = true
    
    lazy fileprivate var timer = Timer()
    lazy fileprivate var countTimer = 0
    
    lazy var scrollView = UIScrollView(frame: .zero)
    
    lazy var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight)).then {
        $0.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        self.setupHandler()
    }
    
    func setupHandler() {
        if self is HideKeyboardable {
            (self as? HideKeyboardable)?.addHideKeyboardWhenTappedAround()
        }
    }
    
    func addLeftNavigationBarButtonItem(image: UIImage? = UIImage(named: "back_ic")) {
        guard let image = image else { return }
        let barButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(close(_:)))
        barButton.tintColor = UIColor.YourEyes.textColor
        navigationItem.leftBarButtonItem = barButton
    }
    
    func addLeftNavigationBarButtonItem(with title: String, style: UIBarButtonItem.Style = .plain) {
        let barButton = UIBarButtonItem(title: title, style: style, target: self, action: #selector(close(_:)))

        barButton.tintColor = UIColor.YourEyes.linkColor
        navigationItem.leftBarButtonItem = barButton
    }
    
    func addRightNavigationBarButtonItem(with title: String, tintColor: UIColor = UIColor.YourEyes.linkColor, style: UIBarButtonItem.Style = .plain) {
        let barButton = UIBarButtonItem(title: title, style: style, target: self, action: #selector(rightBarButtonDidTap(_:)))

        barButton.tintColor = tintColor
        navigationItem.rightBarButtonItem = barButton
    }
    
    func addRightNavigationBarButtonItem(with image: UIImage?, style: UIBarButtonItem.Style = .plain) {
        guard let image = image else { return }
        
        let barButton = UIBarButtonItem(image: image.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(rightBarButtonDidTap(_:)))
        navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func close(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func rightBarButtonDidTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func showCommonAlertError(_ error: Error, okAction: (() -> Void)? = nil) {
        
        switch error.code {
        case dataCenter().lastErrorCodePopup:
            // Do not show pop up if the top pop up same error code
            return
        default:
            break
        }
        
        self.showAlertWith(errCode: error.code,
                           title: error.title,
                           message: error.message,
                           okTitle: error.comfirmTitle,
                           okAction: okAction)
    }
    
    func showAlertWith(errCode: Int? = nil, title: String? = nil, message: String? = nil, okTitle: String = Strings.OKTitle, okAction: (() -> Void)? = nil) {
        let showAlert = { [weak self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: okTitle, style: .cancel, handler: { (action) in
                okAction?()
                
                // Remove last error code
                dataCenter().lastErrorCodePopup = -1
            }))
            
            if let errCode = errCode {
                alert.view.tag = errCode
            }
            
            // Save last error code when show new error pop up
            dataCenter().lastErrorCodePopup = errCode ?? -1
            self?.present(alert, animated: true, completion: nil)
        }
        
        if let topvc = UIApplication.topViewController() as? UIAlertController {
            if let errCode = errCode {
                if topvc.view.tag != errCode {
                    topvc.dismiss(animated: false, completion: {
                        showAlert()
                    })
                }
            } else {
                topvc.dismiss(animated: false, completion: {
                    showAlert()
                })
            }
        } else {
            showAlert()
        }
    }
    
    func showAlertWithTwoOption(title: String?,
                                message: String? = nil,
                                okTitle: String = Strings.YesTitle,
                                cancelTitle: String = Strings.CancelTitle,
                                okColor: UIColor = .clear,
                                cancelColor: UIColor = .clear,
                                preferredOkAction: Bool = false,
                                lineBreakMode: NSLineBreakMode = .byTruncatingTail,
                                okAction: (() -> Void)? = nil,
                                cancelAction: (() -> Void)? = nil) {
        let showAlert = { [weak self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAlertAction = UIAlertAction(title: okTitle, style: .default, handler: { (action) in
                okAction?()
            })
            let canceAlertAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: { (action) in
                cancelAction?()
            })
            alert.addAction(okAlertAction)
            alert.addAction(canceAlertAction)
            
            if okColor != .clear {
                okAlertAction.setValue(okColor, forKey: "titleTextColor")
            }
            
            if cancelColor != .clear {
                canceAlertAction.setValue(cancelColor, forKey: "titleTextColor")
            }
            
            if let aLabel = alert.view.getALabel() {
                aLabel.lineBreakMode = lineBreakMode
            }
            
            alert.preferredAction = preferredOkAction ? okAlertAction : canceAlertAction
            self?.present(alert, animated: true, completion: nil)
        }
        
        if let topvc = UIApplication.topViewController() as? UIAlertController {
            topvc.dismiss(animated: false, completion: {
                showAlert()
            })
        } else {
            showAlert()
        }
    }
    
    // MARK: - Keyboard
    
    func addKeyboardObserve() {
        NotificationCenter.default.do({ nc in
            nc.addObserver(self, selector: #selector(handleKeyboardDidShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            nc.addObserver(self, selector: #selector(handleKeyboardDidHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        })
    }
    
    func removeKeyboardObserve() {
        NotificationCenter.default.do { nc in
            nc.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            nc.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    func openKeyboardHandle(_ rect: CGRect) {}
    func closeKeyboardHandle() {}
    
    @objc fileprivate func handleKeyboardDidShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let rect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.3
        let rawOptions = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue ?? 0
        
        guard let animationOptions = UIView.AnimationCurve(rawValue: rawOptions) else {
            openKeyboardHandle(rect)
            return
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: UInt(animationOptions.rawValue << 16))) { [weak self] in
            self?.openKeyboardHandle(rect)
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc fileprivate func handleKeyboardDidHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.3
        let rawOptions = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue ?? 0
        guard let animationOptions = UIView.AnimationCurve(rawValue: rawOptions) else {
            closeKeyboardHandle()
            return
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: UInt(animationOptions.rawValue << 16))) { [weak self] in
            self?.closeKeyboardHandle()
            self?.view.layoutIfNeeded()
        }
    }
}

// MARK: Blur Top View
extension YEBaseViewController {
    func addBlurTopView() {
        blurView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: ViewUI.StatusBarHeight)
        view.addSubview(blurView)
    }
    
    func updateTopBlurEffect(_ isOn: Bool) {
        if (isOn && !blurView.isHidden)
            || (!isOn && blurView.isHidden) {
            return
        }
        
        var duration: TimeInterval = 0.16
        
        if isFirstBlur {
            duration = 0
            isFirstBlur = false
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn) {
            self.blurView.isHidden = !isOn
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: Add ScrollView
extension YEBaseViewController {
    // Add ScrollView as container view and return content view for add subviews
    func makeBackgroundAsScrollView(isFullScreen: Bool = false, contentSize: CGRect? = nil) -> UIView {
        // Calculate height for content in scrollview
        let naviHeight = self.navigationController?.navigationBar.frame.height ?? 0
        let contentHeight: CGFloat = view.frame.height - naviHeight - ViewUI.StatusBarHeight - ViewUI.MainBottomInset
        
        var contentRect = CGRect(x: 0, y: isFullScreen ? -naviHeight : 0, width: view.frame.width, height: isFullScreen ? (contentHeight + naviHeight) : contentHeight)
        
        if let contentSize = contentSize {
            contentRect = contentSize
        }
        
        let contentView = UIView(frame: contentRect)
        
        scrollView.contentSize = contentView.frame.size
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        scrollView.delegate = self
        
        return contentView
    }
}

// MARK: Count Timer
extension YEBaseViewController {
    func startCountTimer() {
        timer.invalidate()
        countTimer = 0
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(handleInput), userInfo: nil, repeats: true)
    }
    
    @objc func handleFinishCountTimer() {}
    
    @objc fileprivate func handleInput() {
        countTimer += 1
        
        if countTimer == 3 {
            timer.invalidate()
            countTimer = 0
            handleFinishCountTimer()
        }
    }
}
