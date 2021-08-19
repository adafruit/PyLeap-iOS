

//
//  StartupViewModel.swift
//  Glider
//
//  Created by Antonio García on 13/5/21.
//

import UIKit

class StartupViewModel: ObservableObject {
    // Config
    private static let kMaxTimeToWaitForBleSupport: TimeInterval = 1.0
    private static let kServicesToReconnect = [BlePeripheral.kFileTransferServiceUUID]
    private static let kReconnectTimeout = 2.0
    
    // Published
    enum ActiveAlert {
        case none
        case bluetoothUnsupported
        case fileTransferErrorOnReconnect
        //case bluetoothError(description: String)
        
        var isActive: Bool {
            switch self {
            case .none: return false
            default: return true
            }
        }
        
        mutating func setInactive() {
            self = .none
        }
    }
    
    @Published var activeAlert: ActiveAlert = .none
    @Published var isRestoringConnection = false
    @Published var isStartupFinished = false
    
    // Data
    private let bleSupportSemaphore = DispatchSemaphore(value: 0)
    private var startTime: CFAbsoluteTime!
    
    deinit {
        registerAutoReconnectNotifications(enabled: false)
    }
    
    func setupBluetooth() {
        startTime = CFAbsoluteTimeGetCurrent()
        
        // check Bluetooth status
        let bleState = BleManager.shared.state
        DLog("Initial bluetooth state: \(bleState.rawValue)")
        if bleState == .unknown || bleState == .resetting {
            registerBleStateNotifications(enabled: true)

            let semaphoreResult = bleSupportSemaphore.wait(timeout: .now() + Self.kMaxTimeToWaitForBleSupport)
            if semaphoreResult == .timedOut {
                DLog("Bluetooth support check time-out. status: \(BleManager.shared.state.rawValue)")
            }

            registerBleStateNotifications(enabled: false)
        }
        
        DispatchQueue.main.async {
            self.checkBleSupport()
        }

        registerAutoReconnectNotifications(enabled: true)
    }
    
    // MARK: - Check Ble Support
    private func checkBleSupport() {
        if BleManager.shared.state == .unsupported {
            DLog("Bluetooth unsupported")
            self.activeAlert = .bluetoothUnsupported
        }
        else {
            AppState.shared.startAutoReconnect()
            AppState.shared.forceReconnect()
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
        DLog("willReconnectToKnownPeripheral")
        isRestoringConnection = true
    }

    private func didReconnectToKnownPeripheral(_ notification: Notification) {
        DLog("didReconnectToKnownPeripheral")
        self.isStartupFinished = true
    }

    private func didFailToReconnectToKnownPeripheral(_ notification: Notification) {
        DLog("didFailToReconnectToKnownPeripheral")
        self.isStartupFinished = true
    }
}
