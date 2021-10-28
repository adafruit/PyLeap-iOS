//
//  LogHelper.swift
//  BluefruitPlayground
//
//  Created by Antonio García on 10/10/2019.
//  Copyright © 2019 Adafruit. All rights reserved.
//

import Foundation

// Note: check that Build Settings -> Project -> Active Compilation Conditions -> Debug, has DEBUG

public func DLog(_ message: String, function: String = #function) {
    if _isDebugAssertConfiguration() {
        NSLog("%@, %@", function, message)
    }
    
    // Send notification in case we are using LogManager
    NotificationCenter.default.post(name: .didLogDebugMessage, object: nil, userInfo: ["message" : message])
}



// MARK: - Custom Notifications
extension Notification.Name {
    private static let kPrefix = Bundle.main.bundleIdentifier!
    public static let didLogDebugMessage = Notification.Name(kPrefix+".didLogDebugMessage")

}
