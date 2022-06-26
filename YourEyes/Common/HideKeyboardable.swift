//
//  HideKeyboardable.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import UIKit

protocol HideKeyboardable: AnyObject {
    func addHideKeyboardWhenTappedAround()
}

extension HideKeyboardable where Self: YEBaseViewController {
    func addHideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}
