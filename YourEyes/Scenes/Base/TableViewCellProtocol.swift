//
//  TableViewCellProtocol.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import UIKit

protocol BasePresentable {
    var identifier: String { get set }
    var height: CGFloat { get set }
    var estimateHeight: CGFloat { get set }
    var section: Int { get set }
}

protocol BaseCellPresentable: BasePresentable {
    var row: Int { get set }
}

protocol BaseCellConfigurable {
    func setup(viewModel: BaseCellPresentable)
}

protocol BaseSectionPresentable: BasePresentable {}

protocol BaseSectionConfigurable {
    func setup(viewModel: BaseSectionPresentable)
}
