//
//  BleAutoReconnect.swift
//  Glider
//
//  Created by Antonio García on 21/6/21.
//

import Foundation
import CoreBluetooth

class BleAutoReconnect {
    // Params
    private var servicesToReconnect: [CBUUID]
    private var reconnectHandler: ((_ peripheral: BlePeripheral, _ completion: @escaping (Result<Void, Error>) -> Void) -> ())?
    private let reconnectTimeout: TimeInterval

    private var isReconnecting = false
    var isDisconnectionMonitoringForAutoReconnectEnabled = false
    
    init(servicesToReconnect: [CBUUID], reconnectTimeout: TimeInterval = 2, reconnectHandler: @escaping ( BlePeripheral, @escaping (Result<Void, Error>) -> Void) -> ()) {
        DLog("Init autoReconnect to known peripherals")
        self.servicesToReconnect = servicesToReconnect
        self.reconnectTimeout = reconnectTimeout
        self.reconnectHandler = reconnectHandler
        
        registerConnectionNotifications(enabled: true)
    }
    
    deinit {
        // Unregister notifications
        registerConnectionNotifications(enabled: false)
    }
    
    /// Returns if is trying to reconnect, or false if it is quickly decided that there is not possible
    @discardableResult
    func reconnect() -> Bool {
        if let identifier = Settings.autoconnectPeripheralUUID {
            return self.reconnecToPeripheral(withIdentifier: identifier)
        } else {
            DLog("Reconnect finished")
            NotificationCenter.default.post(name: .didFailToReconnectToKnownPeripheral, object: nil)
            return false
        }
    }
    
    // MARK: - Reconnect previously connnected Ble Peripheral
    private func reconnecToPeripheral(withIdentifier identifier: UUID) -> Bool {
        DLog("Reconnecting...")
        isReconnecting = true
        
        // Reconnect
        let isTryingToReconnect = BleManager.shared.reconnecToPeripherals(peripheralUUIDs: [identifier], withServices: servicesToReconnect, timeout: reconnectTimeout)

        if !isTryingToReconnect {
            DLog("isTryingToReconnect false. Go to next")
            connected(peripheral: nil)
        }
        
        return isTryingToReconnect
    }

    private func didConnectToPeripheral(_ notification: Notification) {
        guard isReconnecting else {
            if let identifier = notification.userInfo?[BleManager.NotificationUserInfoKey.uuid.rawValue] as? UUID {
                DLog("AutoReconnect detected connection. Save identifier.");
                Settings.autoconnectPeripheralUUID = identifier
            }
            return }
        
        guard let peripheral = BleManager.shared.peripheral(from: notification) else {
            DLog("Connected to an unknown peripheral")
            connected(peripheral: nil)
            return
        }

        connected(peripheral: peripheral)
    }

    private func didDisconnectFromPeripheral() {
        if isReconnecting {
            // Autoconnect failed
            connected(peripheral: nil)
        }
        else if isDisconnectionMonitoringForAutoReconnectEnabled {
            DLog("AutoReconnect: Disconnection detected. Trying to auto reconnect")
            reconnect()
        }
    }

    private func connected(peripheral: BlePeripheral?) {
        isReconnecting = false      // Finished reconnection process

        //
        if let peripheral = peripheral {
            // Show restoring connection label
            NotificationCenter.default.post(name: .willReconnectToKnownPeripheral, object: nil, userInfo: [BleManager.NotificationUserInfoKey.uuid.rawValue: peripheral.identifier])

            reconnectHandler?(peripheral) { result in
                switch result {
                case .success:
                    DLog("Reconnected to peripheral successfully")                            
                    NotificationCenter.default.post(name: .didReconnectToKnownPeripheral, object: nil, userInfo: [BleManager.NotificationUserInfoKey.uuid.rawValue: peripheral.identifier])

                case .failure(let error):
                    DLog("Failed to setup peripheral: \(error.localizedDescription)")
                    BleManager.shared.disconnect(from: peripheral)

                    Settings.clearAutoconnectPeripheral()
                    NotificationCenter.default.post(name: .didFailToReconnectToKnownPeripheral, object: nil, userInfo: [BleManager.NotificationUserInfoKey.uuid.rawValue: peripheral.identifier])
                }
            }

        } else {
            Settings.clearAutoconnectPeripheral()
            NotificationCenter.default.post(name: .didFailToReconnectToKnownPeripheral, object: nil)
        }
    }
    
    // MARK: - Notifications
    private var didConnectToPeripheralObserver: NSObjectProtocol?
    private var didDisconnectFromPeripheralObserver: NSObjectProtocol?

    private func registerConnectionNotifications(enabled: Bool) {
        if enabled {
            didConnectToPeripheralObserver = NotificationCenter.default.addObserver(forName: .didConnectToPeripheral, object: nil, queue: .main, using: { [weak self] notification in self?.didConnectToPeripheral(notification)})
            didDisconnectFromPeripheralObserver = NotificationCenter.default.addObserver(forName: .didDisconnectFromPeripheral, object: nil, queue: .main, using: { [weak self] _ in self?.didDisconnectFromPeripheral()})
        } else {
            if let didConnectToPeripheralObserver = didConnectToPeripheralObserver {NotificationCenter.default.removeObserver(didConnectToPeripheralObserver)}
            if let didDisconnectFromPeripheralObserver = didDisconnectFromPeripheralObserver {NotificationCenter.default.removeObserver(didDisconnectFromPeripheralObserver)}
        }
    }
}

// MARK: - Custom Notifications
extension Notification.Name {
    private static let kPrefix = Bundle.main.bundleIdentifier!
    static let willReconnectToKnownPeripheral = Notification.Name(kPrefix+".willReconnectToKnownPeripheral")
    static let didReconnectToKnownPeripheral = Notification.Name(kPrefix+".didReconnectToKnownPeripheral")
    static let didFailToReconnectToKnownPeripheral = Notification.Name(kPrefix+".didFailToReconnectToKnownPeripheral")
}
