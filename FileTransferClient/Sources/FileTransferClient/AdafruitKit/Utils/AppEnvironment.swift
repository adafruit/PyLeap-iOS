//
//  AppEnvironment.swift
//  Glider
//
//  Created by Antonio García on 14/5/21.
//

import Foundation

public struct AppEnvironment {
    
    public static var isDebug: Bool {
        return _isDebugAssertConfiguration()
    }
    
    public static var isRunningTests: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
    
    public static var inSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    public static var inXcodePreviewMode: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    public static var appVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
