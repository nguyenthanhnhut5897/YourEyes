//
//  MessageResponse.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import Foundation

enum MessageType: String {
    case Incoming = "INCOMING"
    case Outcoming = "OUTCOMING"
    case unowned
}

struct MessageResponse: Codable {
    var objectId: String?
    var message: String?
    var type: String?
    var date: Date?
}

extension MessageResponse {
    var messageType: MessageType {
        guard let type = type, let _type = MessageType(rawValue: type) else { return .unowned }
        
        return _type
    }
}
