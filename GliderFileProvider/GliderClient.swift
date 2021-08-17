//
//  GliderClient.swift
//  GliderFileProvider
//
//  Created by Antonio García on 26/6/21.
//

import Foundation

class GliderClient {
    // Config
    private static let kMaxTimeToWaitForBleSupport: TimeInterval = 1.0
    
    // Singleton
    //static let shared = GliderClient()
    
    enum GliderError: Error {
        case bluetoothNotSupported
        case connectionFailed
        case invalidInternalState
        case undefinedFileProviderItem(identifier: String)
    }
    
    // Data
    private var completion: ((Result<FileTransferClient, Error>)->Void)?

    // Data - Bluetooth support
    private let bleSupportSemaphore = DispatchSemaphore(value: 0)
    private var startTime: CFAbsoluteTime!
    private var autoReconnect: BleAutoReconnect?

    // Data - FileTransfer
    private var fileTransferClient: FileTransferClient?

    // Data - Metadata Cache
    var metadataCache = FileMetadataCache()
    
    // MARK: -
    deinit {
        disconnect()
        registerAutoReconnectNotifications(enabled: false)
    }

    
    func setupFileTransferIfNeeded(completion: @escaping (Result<FileTransferClient, Error>)->Void ) {
        self.completion = completion
                
        guard fileTransferClient == nil || !fileTransferClient!.isFileTransferEnabled else {
            // It is already setup
            completion(.success(fileTransferClient!))
            return
        }
        
        // check Bluetooth status
        startTime = CFAbsoluteTimeGetCurrent()
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
            completion?(.failure(GliderError.bluetoothNotSupported))
        }
        else {
            startAutoReconnect()
            let isTryingToConnect = forceReconnect()
            if (!isTryingToConnect) {
                
            }
        }
    }
    
    // MARK: - Reconnect
    private func startAutoReconnect() {
        autoReconnect = BleAutoReconnect(
            servicesToReconnect: [BlePeripheral.kFileTransferServiceUUID],
            reconnectHandler: { [unowned self] (peripheral: BlePeripheral, completion: @escaping (Result<Void, Error>) -> Void) in

                self.fileTransferClient = FileTransferClient(connectedBlePeripheral: peripheral, services: [.filetransfer]) { result in
                    
                    switch result {
                    case .success(let client):
                        if client.isFileTransferEnabled {
                            completion(.success(()))
                        }
                        else {
                            completion(.failure(FileTransferClient.ClientError.serviceNotEnabled))
                        }
                        
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            })
    }
    
    private func forceReconnect() -> Bool {
        guard let autoReconnect = autoReconnect else { DLog("Error: reconnect called without calling startAutoReconnect"); return false }
        return autoReconnect.reconnect()
    }
    
    func disconnect() {
        if let blePeripheral = fileTransferClient?.blePeripheral {
            BleManager.shared.disconnect(from: blePeripheral)
        }
        
        fileTransferClient = nil
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
        //isRestoringConnection = true
    }

    private func didReconnectToKnownPeripheral(_ notification: Notification) {
        DLog("didReconnectToKnownPeripheral")
        guard let fileTransferClient = fileTransferClient else {
            completion?(.failure(GliderError.invalidInternalState))
            return
        }

        completion?(.success((fileTransferClient)))
    }

    private func didFailToReconnectToKnownPeripheral(_ notification: Notification) {
        DLog("didFailToReconnectToKnownPeripheral")
        completion?(.failure(GliderError.connectionFailed))
    }
}
