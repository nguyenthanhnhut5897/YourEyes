//
//  YENavigationController.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import UIKit

class YENavigationController: UINavigationController {
    var shouldShowStatusBarLightContent = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return shouldShowStatusBarLightContent ? .lightContent : .default
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    override var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: UIColor(rgb: 0x2C2C2E)]
        navigationBar.titleTextAttributes = textAttributes
        
        var largeTextAttributes = textAttributes
        largeTextAttributes[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: 30, weight: .semibold)
        
        navigationBar.largeTitleTextAttributes = largeTextAttributes
        
        modalPresentationStyle = .fullScreen
        navigationBar.prefersLargeTitles = false
        
        navigationBar.tintColor = UIColor.black.withAlphaComponent(0.5)
        navigationBar.barTintColor = UIColor.YourEyes.backgroundColor
        navigationBar.backIndicatorImage = UIImage(named: "back_ic")?.withRenderingMode(.alwaysTemplate)
        navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back_ic")?.withRenderingMode(.alwaysTemplate)
    }
}
