//
//  InComeMessageCell.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import UIKit

class InComeMessageCell: BaseTableViewCell, BaseCellConfigurable {
    let containerView = UIView().then {
        $0.backgroundColor = UIColor.fromRGB(26, 200, 56)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 16
    }
    let contentLabel = UILabel().then {
        $0.textColor = .white
        $0.font = Font(.system(.regular), size: 14).value
        $0.numberOfLines = 0
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupViews()
    }
    
    func setupViews() {
        backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.addSubviews(contentLabel)
        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.leading.equalToSuperview().offset(ViewUI.Padding * 2)
            $0.trailing.lessThanOrEqualTo(contentView).offset(-ViewUI.Padding * 10)
        }
        
        contentLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(ViewUI.Padding * 2)
        }
    }
    
    func setup(viewModel: BaseCellPresentable) {
        guard let viewModel = viewModel as? InComeMessageModel else { return }
        
        contentLabel.text = viewModel.messageInfo.message
    }
}
