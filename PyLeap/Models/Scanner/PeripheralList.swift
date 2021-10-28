//
//  PeripheralList.swift
//  BluefruitPlayground
//
//  Created by Antonio García on 11/10/2019.
//  Copyright © 2019 Adafruit. All rights reserved.
//

import Foundation
import FileTransferClient

class PeripheralList {
    // Data
    private(set) var bleManager: BleManager
    private var peripherals = [BlePeripheral]()
    private var cachedFilteredPeripherals: [BlePeripheral] = []

    // MARK: - Lifecycle
    init(bleManager: BleManager) {
        self.bleManager = bleManager
    }

    // MARK: - Actions
    func filteredPeripherals(forceUpdate: Bool) -> [BlePeripheral] {
        if forceUpdate {
            cachedFilteredPeripherals = calculateFilteredPeripherals()
        }
        return cachedFilteredPeripherals
    }

    func clear() {
        peripherals.removeAll()
    }

    private func calculateFilteredPeripherals() -> [BlePeripheral] {
        let peripherals = bleManager
            .peripheralsSortedByFirstDiscovery()
            .filter({$0.isManufacturerAdafruit() && $0.advertisement.services?.contains(BlePeripheral.kFileTransferServiceUUID) ?? false})
        return peripherals
    }
}
