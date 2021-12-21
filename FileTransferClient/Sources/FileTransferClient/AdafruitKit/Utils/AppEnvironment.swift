//
//  AppEnvironment.swift
//  Glider
//
//  Created by Antonio García on 14/5/21.
//

import Foundation

public struct AppEnvironment {
    
    // MARK: - Run mode
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
    
    // MARK: - App info
    public static var appVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    public static var buildNumber: String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }

}
