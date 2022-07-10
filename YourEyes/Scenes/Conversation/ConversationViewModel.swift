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
    var answerResult : ((MessageResponse?) -> ())?
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
        
        getAnAnswer(question: question, imageData: imageData ?? UIImage(named: "camera_ic")) { [weak self] (message, error) in
            
            SVProgressHUD.dismiss()
            
            if var newMessage = message {
                newMessage.type = MessageType.Incoming.rawValue
                self?.messages.append(newMessage)
                self?.createViewModels()
                self?.answerResult?(newMessage)
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
