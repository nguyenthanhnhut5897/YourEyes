//
//  OutComeMessageCell.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import UIKit

class OutComeMessageCell: BaseTableViewCell, BaseCellConfigurable {
    let containerView = UIView().then {
        $0.backgroundColor = .gray.withAlphaComponent(0.4)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
    }
    let contentLabel = UILabel().then {
        $0.textColor = .white
        $0.font = Font(.system(.regular), size: 14).value
        $0.numberOfLines = 0
        $0.textAlignment = .right
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
            $0.leading.greaterThanOrEqualToSuperview().offset(ViewUI.Padding * 5)
            $0.trailing.equalToSuperview().offset(-ViewUI.Padding * 2)
        }
        
        contentLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(ViewUI.Padding * 2)
        }
    }
    
    func setup(viewModel: BaseCellPresentable) {
        guard let viewModel = viewModel as? OutComeMessageModel else { return }
        
        contentLabel.text = viewModel.messageInfo.message
    }
}
