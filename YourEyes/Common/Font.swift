//
//  Font.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import UIKit

//let system = Font(.system(.bold), size: 18).value

struct Font {
    enum FontType {
        case system(UIFont.Weight)
    }
    
    var type: FontType
    var size: CGFloat
    
    init(_ type: FontType, size: CGFloat) {
        self.type = type
        self.size = size
    }
}

extension Font {
    var value: UIFont {
        var instanceFont: UIFont!
        
        switch type {
        case .system(let weight):
            instanceFont = UIFont.systemFont(ofSize: size, weight: weight)
        }
        
        return instanceFont
    }
    
    var valueScale: UIFont {
        return value.scaleForScreenSize()
    }
}

extension UIFont {
    fileprivate struct AssociatedKeys {
        static var OriginalFontPointSize = "original_font_point_size"
    }
    
    /// Returns whether the image is inflated.
    fileprivate var originalFontPointSize: CGFloat {
        get {
            if let pointSize = objc_getAssociatedObject(self, &AssociatedKeys.OriginalFontPointSize) as? CGFloat {
                return pointSize
            } else {
                return -1
            }
        }
        set(inflated) {
            objc_setAssociatedObject(self, &AssociatedKeys.OriginalFontPointSize, inflated, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func scaleForScreenSize(_ screenSize: ScreenSize = .screenSize4p7Inch) -> UIFont {
        if self.originalFontPointSize == -1 {
            self.originalFontPointSize = self.pointSize
        }
        
        var finalFont = self
        let multiplier = self.fontPointSizeMultiplierForScreenSize(screenSize)
        
        if multiplier != 1 {
            let finalSize = self.originalFontPointSize * multiplier
            finalFont = UIFont(descriptor: self.fontDescriptor, size: finalSize)
            finalFont.originalFontPointSize = self.originalFontPointSize
        }
        
        return finalFont
    }
    
    fileprivate func fontPointSizeMultiplierForScreenSize(_ screenSize: ScreenSize) -> CGFloat {
        return UIScreen.main.bounds.width / screenSize.rawValue
    }
}
