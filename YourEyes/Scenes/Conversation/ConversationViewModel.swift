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
    var error: Error?
    var imageData: UIImage?
    var messages: [MessageResponse] = []
    
    convenience init(imageData: UIImage?) {
        self.init()
        
        self.imageData = imageData
        self.createViewModels()
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
    
    func addNewMess(text: String, type: MessageType) {
        messages.append(MessageResponse(objectId: "", message: text, type: type.rawValue, date: Date()))
        createViewModels()
    }
}
