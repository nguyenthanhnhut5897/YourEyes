//
//  UITableViewExtensions.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import UIKit

extension UITableView {
    func regisCells(_ cellIdentifiers: String...) {
        for identifier in cellIdentifiers {
            self.register(UINib(nibName: identifier, bundle: Bundle.main), forCellReuseIdentifier: identifier)
        }
    }
    
    func registerCells(_ cellIdentifiers: AnyClass...) {
        for classIdentifier in cellIdentifiers {
            self.register(classIdentifier, forCellReuseIdentifier: String(describing: classIdentifier))
        }
    }
    
    func registerHeaderFooter(_ viewIdentifiers: AnyClass...) {
        for classIdentifier in viewIdentifiers {
            self.register(classIdentifier, forHeaderFooterViewReuseIdentifier: String(describing: classIdentifier))
        }
    }
    
    func setBottomInset(to value: CGFloat) {
        let edgeInset = UIEdgeInsets(top: self.contentInset.top, left: self.contentInset.left, bottom: value, right: self.contentInset.right)

        self.contentInset = edgeInset
        self.scrollIndicatorInsets = edgeInset
    }
    
    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
    
    func scrollToTop(animated: Bool) {
        let indexPath = IndexPath(row: 0, section: 0)
        
        if self.hasRowAtIndexPath(indexPath: indexPath) {
            self.scrollToRow(at: indexPath, at: .top, animated: animated)
        }
    }
}
