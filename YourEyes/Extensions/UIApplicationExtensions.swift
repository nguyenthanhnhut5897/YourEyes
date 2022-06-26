//
//  UIApplicationExtensions.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import UIKit

extension UIApplication {
    var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }
    }
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    /// Try to dismiss all presented screen until finish
    /// completion: handle something after dismiss finish
    class func dismissSpecialTopViewController(completion: @escaping (() -> Void)) {
        if let presentedVC = AppDelegate.default.rootViewController?.presentedViewController {
            presentedVC.dismiss(animated: true, completion: {
                dismissSpecialTopViewController(completion: completion)
            })
        } else {
            completion()
        }
    }
}
