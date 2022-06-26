//
//  ViewUI.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import UIKit

enum ScreenSize: CGFloat {
    case screenSize4Inch = 320
    case screenSize4p7Inch = 375
}

struct ViewUI {
    static let Padding: CGFloat = 8
    static let ButtonHeight: CGFloat = 48
    static let ButtonHeightLarge: CGFloat = 52
    static let TextFieldHeight: CGFloat = 48
    static let TextViewHeight: CGFloat = 80
    static let KeyboardHeightDefault: CGFloat = 260
    
    static var isSEScreen: Bool {
        return UIScreen.main.bounds.width <= ScreenSize.screenSize4Inch.rawValue
    }
    
    static var VerticalPadding: CGFloat {
        var topPaddingUnit = Padding
            
        if UIScreen.main.bounds.width < ScreenSize.screenSize4p7Inch.rawValue {
            topPaddingUnit /= 2
        }
        
        return topPaddingUnit
    }
    
    static var StatusBarHeight: CGFloat {
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            return window.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        }
        
        return 0
    }
    
    static var MainBottomInset: CGFloat {
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            return window.safeAreaInsets.bottom
        }
        
        return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    }
}
