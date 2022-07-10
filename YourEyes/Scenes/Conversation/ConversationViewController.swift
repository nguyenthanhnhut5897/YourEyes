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
        $0.clipsToBounds = true
    }
    let tableView = UITableView()
    let voiceButton = UIButton().then {
        $0.setImage(UIImage(named: "voice_ic"), for: .normal)
        $0.backgroundColor = UIColor.YourEyes.buttonColor
        $0.layer.cornerRadius = ConversationViewControllerUX.ButtonSize / 2
        $0.imageView?.contentMode = .scaleAspectFit
    }
    let voiceLevel = UIView().then {
        $0.backgroundColor = UIColor.YourEyes.linkColor
        $0.layer.cornerRadius = 1
    }
    let pulsatingButton = PulsatingButton(frame: CGRect(x: 0, y: 0, width: ConversationViewControllerUX.ButtonSize, height: ConversationViewControllerUX.ButtonSize)).then {
        $0.isHidden = true
    }
    
    var viewModel = ConversationViewModel()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubviews(backgroundImageview, tableView, pulsatingButton, voiceButton, voiceLevel)
        voiceButton.addTarget(self, action: #selector(didTapVoiceButton), for: .touchUpInside)
        navigationItem.title = "Q&A"
        
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = 0
        tableView.registerCells(InComeMessageCell.self,
                                OutComeMessageCell.self)
        tableView.contentInset.bottom = ConversationViewControllerUX.ContentBottomInset
        tableView.verticalScrollIndicatorInsets.bottom = ConversationViewControllerUX.ContentBottomInset
        
        backgroundImageview.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        voiceButton.snp.makeConstraints {
            $0.bottom.equalTo(-ViewUI.MainBottomInset - ViewUI.Padding * 3)
            $0.size.equalTo(ConversationViewControllerUX.ButtonSize)
            $0.centerX.equalToSuperview()
        }
        voiceLevel.snp.makeConstraints {
            $0.centerX.equalTo(voiceButton)
            $0.top.equalTo(voiceButton.snp.bottom).offset(8)
            $0.height.equalTo(2)
            $0.width.equalTo(0)
        }
        
        backgroundImageview.image = viewModel.imageData
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isFirstLayout else { return }
        
        pulsatingButton.center = voiceButton.center
        pulsatingButton.pulse()
        isFirstLayout = false
        textToSpeech.start(["Please press the center bottom button to record your questions."], [1])
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
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.scrollToLastItem(at: .top, animated: false)
                }
            }
        }
        
        viewModel.answerResult = { [weak self] message in
            guard let self = self else { return }
            
            if let error = self.viewModel.error {
                self.showCommonAlertError(error)
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.textToSpeech.start([message ?? ""], [1])
                }
            }
        }
    }
    
    @objc func didTapVoiceButton() {
        guard isAllowRecording, isAllowSpeech else {
            requestRecording()
            return
        }

        loadRecording()
    }
    
    override func loadRecording() {
        if audioRecorder == nil {
            animateWhenRecording(true)
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    override func finishRecording(success: Bool) {
        super.finishRecording(success: success)
        
        animateWhenRecording(false)
    }
    
    override func speechTo(text: String) {
        super.speechTo(text: text)
        
        viewModel.addNewQuestion(text: text)
    }
    
    override func updateVoiceLevel(level: CGFloat) {
        voiceLevel.snp.updateConstraints {
            $0.width.equalTo(level * 300 / 25) // scaled to max at 300 (our height of our bar)
        }
    }
    
    func animateWhenRecording(_ isRecording: Bool) {
        pulsatingButton.isHidden = !isRecording
        voiceLevel.isHidden = !isRecording
        voiceLevel.snp.updateConstraints {
            $0.width.equalTo(0)
        }
    }
    
    /// Scroll to last item in tableview
    /// - Parameters:
    ///   - pos: Scroll Position
    func scrollToLastItem(at pos: UITableView.ScrollPosition = .bottom, animated: Bool = true) {
        guard tableView.numberOfSections > 0 else { return }
        
        let lastSection = tableView.numberOfSections - 1
        let lastItemIndex = tableView.numberOfRows(inSection: lastSection) - 1
        
        guard lastItemIndex >= 0 else { return }
        
        let indexPath = IndexPath(row: lastItemIndex, section: lastSection)
        tableView.scrollToRow(at: indexPath, at: pos, animated: animated)
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
