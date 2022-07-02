//
//  AppDelegate.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import UIKit
import SVProgressHUD

@main class AppDelegate: UIResponder, UIApplicationDelegate {
    static var `default`: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var window: UIWindow?
    var rootViewController: UIViewController? {
        get {
            return window?.rootViewController
        }
        set {
            window?.rootViewController = newValue
        }
    }
    
    var dataCenter: DataCenter!
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        
        let navi = YENavigationController(rootViewController: CameraViewController())
        rootViewController = navi
        
        // Custom progress hub
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setForegroundColor(.black)
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setBackgroundColor(.clear)
        
        dataCenter = DataCenter()
        
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0
        }
        
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window?.makeKeyAndVisible()
        return true
    }
}

