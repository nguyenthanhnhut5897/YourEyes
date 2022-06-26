//
//  ErrorExtensions.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import Foundation

public extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
    var userInfo: [String : Any] { return (self as NSError).userInfo }
    var title: String? { return getErrorTitle() }
    var message: String { return getErrorMessage() }
    var codeValue: Int {
        if let data = (userInfo["NSLocalizedDescription"] as? String)?.convertToDict(), let code = data["code"] as? Int {
            return code
        }
        
        return 0
    }
    
    var comfirmTitle: String {
        switch code {
        default:
            return Strings.OKTitle
        }
    }
    
    func getErrorTitle() -> String {
        switch code {
        default:
            return Strings.ErrorTitle
        }
    }
    
    func getErrorMessage() -> String {
        switch code {
        default:
            return self.localizedDescription
        }
    }
}
