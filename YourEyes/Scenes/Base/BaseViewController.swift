//
//  BaseViewController.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import UIKit
import SafariServices

open class BaseTableViewController: UITableViewController {
    class func viewController() -> UIViewController? { return nil }
}

extension UIViewController: SFSafariViewControllerDelegate {
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

open class BaseViewController: UIViewController {
    var orientationMask: UIInterfaceOrientationMask {
        return .portrait
    }
    var shouldUnlockOrientationMask: Bool {
        return false
    }
    
    override open var interfaceOrientation: UIInterfaceOrientation {
        return .portrait
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupViews()?.forEach { [weak self] in
            guard let self = self else { return }
            if let subLayer = $0 as? CALayer {
                self.view.layer.addSublayer(subLayer)
            } else {
                self.view.addSubview($0 as! UIView)
            }
        }
        setupConstraints()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupOrientationMask()
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayout()
    }
    
    open func setupOrientationMask() {}
    open func setupViews() -> [CanBeSubview]? { return nil }
    open func setupConstraints() {}
    open func updateLayout() {}
    class func viewController() -> UIViewController? { return nil }
}

open class BaseCollectionViewFlowLayout: UICollectionViewFlowLayout {
    public override init() {
        super.init()
        configureLayout()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureLayout()
    }
    
    open func configureLayout() { }
}

open class BaseView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    private func commonInit() {
        setupViews()?.forEach { [weak self] in
            guard let self = self else { return }
            if let subLayer = $0 as? CALayer {
                self.layer.addSublayer(subLayer)
            } else {
                self.addSubview($0 as! UIView)
            }
        }
        setupConstraints()
    }
    
    open func setupViews() -> [CanBeSubview]? { return nil }
    open func setupConstraints() {}
    open func updateLayout() {}
}

public protocol CanBeSubview {}
extension UIView: CanBeSubview {}
extension CALayer: CanBeSubview {}

extension UIView {
    @discardableResult
    public func addSubviews(_ subviews: UIView...) -> UIView {
        subviews.forEach { addSubview($0) }
        return self
    }
}

extension CALayer {
    public func addSublayers(_ sublayers: CALayer...) -> CALayer {
        sublayers.forEach { addSublayer($0) }
        return self
    }
}
