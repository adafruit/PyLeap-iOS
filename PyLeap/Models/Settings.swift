//
//  Settings.swift
//  BluefruitPlayground
//
//  Created by Antonio García on 10/10/2019.
//  Copyright © 2019 Adafruit. All rights reserved.
//

import Foundation

class Settings {
    private static let userDefaults = UserDefaults(suiteName: "group.com.adafruit.PyLeap")!        // Shared between the app and extensions
    
    // Constants
    private static let autoconnectPeripheralIdentifierKey = "autoconnectPeripheralIdentifier"
    //private static let autoconnectPeripheralAdvertisementDataKey = "autoconnectPeripheralAdvertisementData"

    // MARK: - AutoConnect
    static var autoconnectPeripheralUUID: UUID? {
        get {
            guard let uuidString = userDefaults.string(forKey: Self.autoconnectPeripheralIdentifierKey), let uuid = UUID(uuidString: uuidString) else { return nil}
            return uuid
        }
        
        set {
            #if canImport(FileProviderUtils)
                  if newValue == nil && autoconnectPeripheralUUID != nil {
                    FileProviderUtils.signalFileProviderChanges()
                  }
                  #endif
            
            let uuidString = newValue?.uuidString
            DLog("Set autoconnect peripheral: \(uuidString ?? "<nil>")")
            userDefaults.set(uuidString, forKey: Self.autoconnectPeripheralIdentifierKey)
        }
        
    }
    /*
    static var autoconnectPeripheral: (identifier: UUID, advertisementData: [String: Any])? {
        get {
            guard let uuidString = userDefaults?.string(forKey: Self.autoconnectPeripheralIdentifierKey), let uuid = UUID(uuidString: uuidString), let advertisementData = userDefaults?.dictionary(forKey: Self.autoconnectPeripheralAdvertisementDataKey) else { return nil}
                        
            return (uuid, advertisementData)
        }
        
        set {
            let uuidString = newValue?.identifier.uuidString
            DLog("Set autoconnect peripheral: \(uuidString ?? "<nil>")")

            userDefaults?.set(uuidString, forKey: Self.autoconnectPeripheralIdentifierKey)
            userDefaults?.set(newValue?.advertisementData, forKey: Self.autoconnectPeripheralAdvertisementDataKey)
        }
    }*/
    
    static func clearAutoconnectPeripheral() {
        autoconnectPeripheralUUID = nil
    }

    // Common load and save
    static func getBoolPreference(key: String) -> Bool {
        return userDefaults.bool(forKey: key)
    }

    static func setBoolPreference(key: String, newValue: Bool) {
        userDefaults.set(newValue, forKey: key)
    }

    // MARK: - Defaults
    static func registerDefaults() {
        let path = Bundle.main.path(forResource: "DefaultPreferences", ofType: "plist")!
        let defaultPrefs = NSDictionary(contentsOfFile: path) as! [String: AnyObject]

        userDefaults.register(defaults: defaultPrefs)
    }

    static func resetDefaults() {
        let appDomain = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: appDomain)
    }
}
