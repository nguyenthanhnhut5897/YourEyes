//
//  UIViewExtensions.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import UIKit

extension UIView {
    /// Find a last label in view
    func getALabel() -> UILabel? {
        var aLabel: UILabel?
        
        self.subviews.forEach { subView in
            if let label = subView as? UILabel {
                aLabel = label
            }else if let label = subView.getALabel() {
                aLabel = label
            }
        }
        
        return aLabel
    }
}
