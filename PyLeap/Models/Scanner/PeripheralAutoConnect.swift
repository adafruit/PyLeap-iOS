//
//  PeripheralAutoConnect.swift
//  BluefruitPlayground
//
//  Created by Antonio García on 18/02/2020.
//  Copyright © 2020 Adafruit. All rights reserved.
//

import Foundation

/**
 Manages the logic for autoconnecting to a peripheral
 Usage:
    call isAutoconnectAvailable whenever a peripheral is discovered or updated.
 
 How it works:
 It waits at least kMinScanningTimeToAutoconnect since scanning started, and needs that the peripheral RSSI is bigger than kMaxRssiToAutoConnect during kMinTimeDetectingPeripheralForAutoconnect seconds.
 If more than one peripheral matches the conditions, it will connect to the one with bigger RSSI (meaning that is closer)
 */
class PeripheralAutoConnect {
    // Config
    private static let kMinScanningTimeToAutoconnect: TimeInterval = 1.5 // 5
    private static let kMinRssiToAutoConnect = -80      // in dBM
    private static let kMinTimeDetectingPeripheralForAutoconnect: TimeInterval = 1

    // Data
    private(set) var matchingPeripherals: [(blePeripheral: BlePeripheral, discoverTime: TimeInterval)] = []      // List of peripherals that could be selected, and time since they have been matching the requirements

    // MARK: - Utils
    func reset() {
        matchingPeripherals.removeAll()
    }

    /**
     Should be called everytime the peripheralList is updated
    - Returns: blePeripheral to autoconnect to, or nil if the decision has not been taken
    */
    func update(peripheralList: PeripheralList) -> BlePeripheral? {
        let bleManager = peripheralList.bleManager

        // Only update autoconnect if we are not already connecting to a peripheral
        guard bleManager.connectedOrConnectingPeripherals().isEmpty else { return nil }

        // Get peripherals
        let filteredPeripherals = peripheralList.filteredPeripherals(forceUpdate: true)     // Refresh the peripherals

        // Filter by RSSI
        let nearbyPeripherals = filteredPeripherals.filter({$0.rssi ?? -127 > PeripheralAutoConnect.kMinRssiToAutoConnect})

        // Update matching peripherals
        let nearbyIdentifiers = nearbyPeripherals.map({$0.identifier})      // List of nearby identifiers
        matchingPeripherals = matchingPeripherals.filter {nearbyIdentifiers.contains($0.blePeripheral.identifier)}     // Remove peripherals that are no longer near
        for nearbyPeripheral in nearbyPeripherals {
            if matchingPeripherals.first(where: {$0.blePeripheral.identifier == nearbyPeripheral.identifier}) == nil {
                // New peripheral found. Add to possible matches
                matchingPeripherals.append((blePeripheral: nearbyPeripheral, discoverTime: CFAbsoluteTimeGetCurrent()))
            }
        }

        if AppEnvironment.isDebug && false {
            //DLog("peripherals: \(matchingPeripherals.count)")
            let currentTime = CFAbsoluteTimeGetCurrent()
            _ = matchingPeripherals.map { DLog("\($0.blePeripheral.identifier) rssi: \($0.blePeripheral.rssi == nil ? -127:$0.blePeripheral.rssi!) - elapsed: \(Int((currentTime - $0.discoverTime)*1000))") }
            //DLog("--")
        }

        // Wait for the minimum time since scanning started
        guard bleManager.scanningElapsedTime ?? 0 > PeripheralAutoConnect.kMinScanningTimeToAutoconnect else {
            //DLog("remaining mandatory scan time: \(AutoConnectViewController.kMinScanningTimeToAutoconnect - (bleManager.scanningElapsedTime ?? 0))")
            return nil
        }

        // Take peripherals that have been matching more than kMinTimeDetectingPeripheralForAutoconnect seconds
        let currentTime = CFAbsoluteTimeGetCurrent()
        let preselectedPeripherals = matchingPeripherals.filter({currentTime - $0.discoverTime >= PeripheralAutoConnect.kMinTimeDetectingPeripheralForAutoconnect}).map({$0.blePeripheral})

        // Sort by RSSI
        let sortedPeripherals = preselectedPeripherals.sorted { (blePeripheral0, blePeripheral1) -> Bool in
            return blePeripheral0.rssi ?? -127 > blePeripheral1.rssi ?? -127
        }

        // Connect to closest CPB
        guard let peripheral = sortedPeripherals.first else { return nil }
        return peripheral
    }
}
