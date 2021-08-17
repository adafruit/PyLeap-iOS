//
//  AppEnvironment.swift
//  PyLeap
//
//  Created by Trevor Beaton on 6/30/21.
//
import Foundation

public struct AppEnvironment {
    
    static var isDebug: Bool {
        return _isDebugAssertConfiguration()
    }
    
    static var isRunningTests: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
    
    static var inSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    static var inXcodePreviewMode: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    static var appVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
