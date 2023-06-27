

//
//  StartupViewModel.swift
//  Glider
//
//  Created by Antonio García on 13/5/21.
//

import UIKit
import FileTransferClient

class StartupViewModel: ObservableObject {
    // Config
    private static let kMaxTimeToWaitForBleSupport: TimeInterval = 1.0
    private static let kServicesToReconnect = [BlePeripheral.kFileTransferServiceUUID]
    private static let kReconnectTimeout = 2.0
    
    // Published
    enum ActiveAlert: Identifiable {
        case bluetoothUnsupported
        case fileTransferErrorOnReconnect
        //case bluetoothError(description: String)
        
        var id: Int { hashValue }
    }
    
    @Published var activeAlert: ActiveAlert?
    @Published var isRestoringConnection = false
    @Published var isStartupFinished = false
    
    // Data
    private let bleSupportSemaphore = DispatchSemaphore(value: 0)
    
    deinit {
        registerAutoReconnectNotifications(enabled: false)
    }
    
    func setupBluetooth() {
        DispatchQueue.global().async {   // Important: Launch in background queue
            // check Bluetooth status
            let bleState = BleManager.shared.state
            //DLog("Initial bluetooth state: \(bleState.rawValue)")
            if bleState == .unknown || bleState == .resetting {
                
                self.registerBleStateNotifications(enabled: true)
                
                let semaphoreResult = self.bleSupportSemaphore.wait(timeout: .now() + Self.kMaxTimeToWaitForBleSupport)
                if semaphoreResult == .timedOut {
                    DLog("Bluetooth support check time-out. status: \(BleManager.shared.state.rawValue)")
                }
                
                self.registerBleStateNotifications(enabled: false)
            }
            
            DispatchQueue.main.async {
                print("Checking Bluetooth Support")
                self.checkBleSupport()
            }
            
            self.registerAutoReconnectNotifications(enabled: true)
        }
    }
    
    // MARK: - Check Ble Support
    private func checkBleSupport() {
        if BleManager.shared.state == .unsupported {
            DLog("Bluetooth unsupported")
            self.activeAlert = .bluetoothUnsupported
        }
        else {
            FileTransferConnectionManager.shared.reconnect()
        }
    }
    
    // MARK: - Notifications
    private var didUpdateBleStateObserver: NSObjectProtocol?
   
    
    private func registerBleStateNotifications(enabled: Bool) {
        let notificationCenter = NotificationCenter.default
        if enabled {
 
            didUpdateBleStateObserver = notificationCenter.addObserver(forName: .didUpdateBleState, object: nil, queue: nil) { [weak self] _ in
                // Status received. Continue executing...
                DLog("Bluetooth status received: \(BleManager.shared.state.rawValue)")
                self?.bleSupportSemaphore.signal()
             }
        } else {
            if let didUpdateBleStateObserver = didUpdateBleStateObserver {notificationCenter.removeObserver(didUpdateBleStateObserver)}
        }
    }
    
    private weak var willReconnectToKnownPeripheralObserver: NSObjectProtocol?
    private weak var didReconnectToKnownPeripheralObserver: NSObjectProtocol?
    private weak var didFailToReconnectToKnownPeripheralObserver: NSObjectProtocol?
    
    private func registerAutoReconnectNotifications(enabled: Bool) {
        if enabled {
            willReconnectToKnownPeripheralObserver = NotificationCenter.default.addObserver(forName: .willReconnectToKnownPeripheral, object: nil, queue: .main, using: { [weak self] notification in self?.willReconnectToKnownPeripheral(notification)})
            didReconnectToKnownPeripheralObserver = NotificationCenter.default.addObserver(forName: .didReconnectToKnownPeripheral, object: nil, queue: .main, using: { [weak self] notification in self?.didReconnectToKnownPeripheral(notification)})
            didFailToReconnectToKnownPeripheralObserver = NotificationCenter.default.addObserver(forName: .didFailToReconnectToKnownPeripheral, object: nil, queue: .main, using: { [weak self] notification in self?.didFailToReconnectToKnownPeripheral(notification)})
        } else {
            if let willReconnectToKnownPeripheralObserver = willReconnectToKnownPeripheralObserver {NotificationCenter.default.removeObserver(willReconnectToKnownPeripheralObserver)}
            if let didReconnectToKnownPeripheralObserver = didReconnectToKnownPeripheralObserver {NotificationCenter.default.removeObserver(didReconnectToKnownPeripheralObserver)}
            if let didFailToReconnectToKnownPeripheralObserver = didFailToReconnectToKnownPeripheralObserver {NotificationCenter.default.removeObserver(didFailToReconnectToKnownPeripheralObserver)}
        }
    }
    
    private func willReconnectToKnownPeripheral(_ notification: Notification) {
        //DLog("startup willReconnectToKnownPeripheral")
        isRestoringConnection = true
    }

    private func didReconnectToKnownPeripheral(_ notification: Notification) {
        //DLog("startup didReconnectToKnownPeripheral")
        self.isStartupFinished = true
    }

    private func didFailToReconnectToKnownPeripheral(_ notification: Notification) {
        //DLog("startup didFailToReconnectToKnownPeripheral")
        self.isStartupFinished = true
    }
}
