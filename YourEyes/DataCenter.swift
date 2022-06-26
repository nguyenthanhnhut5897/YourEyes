//
//  DataCenter.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/06/26.
//

import Foundation

func dataCenter() -> DataCenter {
    return AppDelegate.default.dataCenter
}

class DataCenter {
    // Save the last error code when show pop up (top alert view of pop up)
    var lastErrorCodePopup: Int = -1
    
    // Mark singleton
    init() {}
    
}
