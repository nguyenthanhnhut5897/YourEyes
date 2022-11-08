//
//  ConversationViewModel.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import SVProgressHUD
import UIKit

class ConversationViewModel: BaseViewModel {
    var bindResult : (() -> ()) = {}
    var answerResult : (([String]?) -> ())?
    var error: Error?
    var imageData: UIImage?
    var messages: [MessageResponse] = []
    
    convenience init(imageData: UIImage?) {
        self.init()
        
        self.imageData = imageData
        self.createViewModels()
    }
    
    func sendAQuestion(question: String) {
        self.error = nil
        
        guard let imageData = imageData else {
            SVProgressHUD.dismiss()
            self.answerResult?(["Please take a picture again!"])
            return
        }
        
        getAnAnswer(question: question, imageData: imageData) { [weak self] (messages, error) in
            
            SVProgressHUD.dismiss()
            
            if let newMessages = messages {
                newMessages.forEach { aMessage in
                    var _aMessage = aMessage
                    _aMessage.type = MessageType.Incoming.rawValue
                    self?.messages.append(_aMessage)
                }
                
                self?.createViewModels()
                self?.answerResult?(newMessages.compactMap({ $0.message }))
            } else {
                self?.error = error
                self?.answerResult?(nil)
            }
        }
    }
    
    private func createViewModels() {
        viewModels.removeAll()
        
        for (index, message) in messages.enumerated() {
            switch message.messageType {
            case .Incoming:
                viewModels.append(InComeMessageModel(message: message, section: lastSectionIndex, row: index))
            case .Outcoming:
                viewModels.append(OutComeMessageModel(message: message, section: lastSectionIndex, row: index))
            default:
                break
            }
        }
        
        bindResult()
    }
    
    func addNewQuestion(text: String) {
        messages.append(MessageResponse(objectId: "", message: text, type: MessageType.Outcoming.rawValue, date: Date()))
        createViewModels()
        
        sendAQuestion(question: text)
    }
}
