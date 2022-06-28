//
//  ConversationViewController.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import UIKit
import SnapKit

struct ConversationViewControllerUX {
    static let ButtonSize: CGFloat = 64
    static var ContentBottomInset: CGFloat {
        return ButtonSize + ViewUI.MainBottomInset + ViewUI.Padding * 2 + 8
    }
}

class ConversationViewController: RecordVoiceViewController {
    let backgroundImageview = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    let tableView = UITableView()
    let voiceButton = UIButton().then {
        $0.setImage(UIImage(named: "voice_ic"), for: .normal)
        $0.backgroundColor = UIColor.YourEyes.buttonColor
        $0.layer.cornerRadius = ConversationViewControllerUX.ButtonSize / 2
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    var viewModel = ConversationViewModel()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubviews(backgroundImageview, tableView, voiceButton)
        voiceButton.addTarget(self, action: #selector(didTapVoiceButton), for: .touchUpInside)
        navigationItem.title = "Q&A"
        
//        addBlurTopView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = 0
        tableView.registerCells(InComeMessageCell.self)
        tableView.contentInset.bottom = ConversationViewControllerUX.ContentBottomInset
        tableView.verticalScrollIndicatorInsets.bottom = ConversationViewControllerUX.ContentBottomInset
        
        backgroundImageview.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        voiceButton.snp.makeConstraints {
            $0.bottom.equalTo(-ViewUI.MainBottomInset - ViewUI.Padding * 2)
            $0.size.equalTo(ConversationViewControllerUX.ButtonSize)
            $0.centerX.equalToSuperview()
        }
        
        backgroundImageview.image = viewModel.imageData
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateTopBlurEffect(scrollView.contentOffset.y > -ViewUI.StatusBarHeight)
    }

    override func setupHandler() {
        super.setupHandler()
        
        viewModel.bindResult = { [weak self] in
            guard let self = self else { return }
            
            if let error = self.viewModel.error {
                self.showCommonAlertError(error)
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func didTapVoiceButton() {
        guard isAllowRecording else {
            requestRecording()
            return
        }
        
        loadRecording()
    }
    
    override func loadRecording() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    override func finishRecording(success: Bool) {
        super.finishRecording(success: success)
        
        
        //        if success {
        //            recordButton.setTitle("Tap to Re-record", for: .normal)
        //        } else {
        //            recordButton.setTitle("Tap to Record", for: .normal)
        //            // recording failed :(
        //        }
    }
    
    override func speechTo(text: String) {
        viewModel.addNewMess(text: text)
    }
}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberSections
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.sectionHeight(at: section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberRowOfSections(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel.cellModel(at: indexPath) else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.identifier, for: indexPath)
        
        // Render cells
        if let cell = cell as? BaseCellConfigurable {
            cell.setup(viewModel: viewModel)
        }
        
        return cell
    }
}
