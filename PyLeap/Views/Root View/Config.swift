//
//  Config.swift
//  PyLeap
//
//  Created by Trevor Beaton on 4/25/22.
//

import Foundation

struct Config {
    // MARK: - Screenshot Mode
    public static var isSimulatingBluetooth: Bool {
        #if SIMULATEBLUETOOTH
        return true
        #else
        return false
        #endif
    }
    
    public static let areFastlaneSnapshotsRunning = UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT")
}
