//
//  InComeMessageModel.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import UIKit

class InComeMessageModel: BaseCellPresentable {
    var row: Int
    
    var identifier: String = InComeMessageCell.className
    
    var height: CGFloat = UITableView.automaticDimension
    
    var estimateHeight: CGFloat = 20
    
    var section: Int
    
    var messageInfo: MessageResponse
    
    var isPreSimilar: Bool
    
    var isPostSimilar: Bool
    
    init(message: MessageResponse, section: Int, row: Int, isPreSimilar: Bool, isPostSimilar: Bool) {
        self.row = row
        self.section = section
        self.messageInfo = message
        self.isPreSimilar = isPreSimilar
        self.isPostSimilar = isPostSimilar
    }
}
