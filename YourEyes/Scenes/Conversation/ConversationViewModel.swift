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
        
        for i in 1...20 {
            messages.append(MessageResponse(objectId: "abc", message: "InComeMessageModel(message: message, section: lastSectionIndex, \(i)", type: Bool.random() ? MessageType.Incoming.rawValue : MessageType.Outcoming.rawValue, date: Date()))
        }
        
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
    
    func addNewMess(text: String) {
        messages.append(MessageResponse(objectId: "", message: text, type: Bool.random() ? MessageType.Incoming.rawValue : MessageType.Outcoming.rawValue, date: Date()))
        
        createViewModels()
    }
}
