//
//  GliderClient.swift
//  GliderFileProvider
//
//  Created by Antonio García on 26/6/21.
//

import Foundation

class GliderClient {
    // Config
    private static let maxTimeToWaitForBleSupport: TimeInterval = 1.0
    private static let willDeviceDisconnectAfterWrite = true    // If the device automatically disconnects after a write, dont signal on write. Wait for the disconnection to happen
    //private let clientSemaphore = DispatchSemaphore(value: 0)
    
    enum GliderError: LocalizedError {
        case bluetoothNotSupported
        case connectionFailed
        case invalidInternalState
        case undefinedFileProviderItem(identifier: String)
    }
    
    // Singleton (used to manage concurrency)
    static let shared = GliderClient()
    
    // Data
    private var setupFileTransferCompletion: ((Result<FileTransferClient, Error>)->Void)?       // Saved completion handler when setupFileTransferIfNeeded is in progress

    // Data - Bluetooth support
    private let bleSupportSemaphore = DispatchSemaphore(value: 0)
    private var startTime: CFAbsoluteTime!
    private var autoReconnect: BleAutoReconnect?
    private let fileTransferSemaphore = DispatchSemaphore(value: 1)
    
    // Data - FileTransfer
    private var fileTransferClient: FileTransferClient?

    // Data - Metadata Cache
    var metadataCache = FileMetadataCache()
    
    
    // MARK: -
    private init() {
        registerDisconnectionNotifications(enabled: true)
    }
    
    deinit {
        registerDisconnectionNotifications(enabled: false)
        disconnect()
        registerAutoReconnectNotifications(enabled: false)
    }
    
    
    // MARK: - Commands (with semaphore to avoid concurrent requests)
    func readFile(path: String, progress: FileTransferClient.ProgressHandler? = nil, completion: ((Result<Data, Error>) -> Void)?) {
        fileTransferSemaphore.wait()
        setupFileTransferIfNeeded { result in
            switch result {
            case .success(let client):
                client.readFile(path: path, progress: progress) {
                    self.fileTransferSemaphore.signal()
                    completion?($0)
                }
            case .failure(let error):
                self.fileTransferSemaphore.signal()
                completion?(.failure(error))
            }
        }
    }
    
    func writeFile(path: String, data: Data, progress: FileTransferClient.ProgressHandler? = nil, completion: ((Result<Void, Error>) -> Void)?) {
        DLog("writeFile requested: \(path)")
        fileTransferSemaphore.wait()
        DLog("writeFile setup: \(path)")
        setupFileTransferIfNeeded { result in
            switch result {
            case .success(let client):
                client.writeFile(path: path, data: data, progress: progress) { result in
                    switch result {
                    case .success:
                        DLog("writeFile finished successfully. Waiting for disconnect")
                        if !Self.willDeviceDisconnectAfterWrite {
                            self.fileTransferSemaphore.signal()
                        }
                        completion?(.success(()))
                        
                    case .failure(let error):
                        DLog("writeFile finished with error")
                        self.fileTransferSemaphore.signal()
                        completion?(.failure(error))
                    }
                }
            case .failure(let error):
                DLog("writeFile setup finished with error")
                self.fileTransferSemaphore.signal()
                completion?(.failure(error))
            }
        }
    }
    
    func deleteFile(path: String, completion: ((Result<Void, Error>) -> Void)?) {
        fileTransferSemaphore.wait()
        setupFileTransferIfNeeded { result in
            switch result {
            case .success(let client):
                client.deleteFile(path: path) { result in
                    self.fileTransferSemaphore.signal()
                    completion?(result)
                }
            case .failure(let error):
                self.fileTransferSemaphore.signal()
                completion?(.failure(error))
            }
        }
    }

    func makeDirectory(path: String, completion: ((Result<Date?, Error>) -> Void)?) {
        fileTransferSemaphore.wait()
        setupFileTransferIfNeeded { result in
            switch result {
            case .success(let client):
                client.makeDirectory(path: path) {
                    self.fileTransferSemaphore.signal()
                    completion?($0)
                }
            case .failure(let error):
                self.fileTransferSemaphore.signal()
                completion?(.failure(error))
            }
        }
    }

    func listDirectory(path: String, completion: ((Result<[BlePeripheral.DirectoryEntry]?, Error>) -> Void)?) {
        fileTransferSemaphore.wait()
        setupFileTransferIfNeeded { result in
            switch result {
            case .success(let client):
                client.listDirectory(path: path) {
                    self.fileTransferSemaphore.signal()
                    completion?($0)
                }
            case .failure(let error):
                self.fileTransferSemaphore.signal()
                completion?(.failure(error))
            }
        }
    }
    
    private func setupFileTransferIfNeeded(completion: @escaping (Result<FileTransferClient, Error>)->Void) {
        guard fileTransferClient == nil || !fileTransferClient!.isFileTransferEnabled else {
            // It is already setup
            self.bleSupportSemaphore.signal()
            completion(.success(fileTransferClient!))
            return
        }

        self.setupFileTransferCompletion = completion
        
        // check Bluetooth status
        startTime = CFAbsoluteTimeGetCurrent()
        let bleState = BleManager.shared.state
        DLog("Initial bluetooth state: \(bleState.rawValue)")
        if bleState == .unknown || bleState == .resetting {
            registerBleStateNotifications(enabled: true)

            let semaphoreResult = bleSupportSemaphore.wait(timeout: .now() + Self.maxTimeToWaitForBleSupport)
            if semaphoreResult == .timedOut {
                DLog("Bluetooth support check time-out. status: \(BleManager.shared.state.rawValue)")
            }

            registerBleStateNotifications(enabled: false)
        }
        
        DispatchQueue.main.async {
            self.checkBleSupport()
        }

        if willReconnectToKnownPeripheralObserver == nil  { // Check that observer is null to avoid multiple observers
            registerAutoReconnectNotifications(enabled: true)
        }
    }
    
    // MARK: - Check Ble Support
    private func checkBleSupport() {
        if BleManager.shared.state == .unsupported {
            DLog("Bluetooth unsupported")
            setupFileTransferCompletion?(.failure(GliderError.bluetoothNotSupported))
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
    
    // MARK: - Autoreconect Notifications
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
        if enabled  {
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
        DLog("GliderClient willReconnectToKnownPeripheral")
        //isRestoringConnection = true
    }

    private func didReconnectToKnownPeripheral(_ notification: Notification) {
        DLog("GliderClient didReconnectToKnownPeripheral")
        guard let fileTransferClient = fileTransferClient else {
            setupFileTransferCompletion?(.failure(GliderError.invalidInternalState))
            return
        }

        setupFileTransferCompletion?(.success((fileTransferClient)))
    }

    private func didFailToReconnectToKnownPeripheral(_ notification: Notification) {
        DLog("GliderClient didFailToReconnectToKnownPeripheral")
        setupFileTransferCompletion?(.failure(GliderError.connectionFailed))
    }
    
    // MARK: - Disconnection Notifications
    private weak var didDisconnectFromPeripheralObserver: NSObjectProtocol?

    private func registerDisconnectionNotifications(enabled: Bool) {
        let notificationCenter = NotificationCenter.default
        
        DLog("Register disconnection notification enabled: \(enabled)")
        if enabled {
          didDisconnectFromPeripheralObserver = notificationCenter.addObserver(forName: .didDisconnectFromPeripheral, object: nil, queue: .main, using: {[weak self] notification in self?.didDisconnectFromPeripheral(notification: notification)})
 
        } else {
            if let didDisconnectFromPeripheralObserver = didDisconnectFromPeripheralObserver {notificationCenter.removeObserver(didDisconnectFromPeripheralObserver)}
        }
    }
    
    private func didDisconnectFromPeripheral(notification: Notification) {
        DLog("Warning: peripheral has disconnected!!")
        fileTransferClient = nil
        if Self.willDeviceDisconnectAfterWrite {
            fileTransferSemaphore.signal()
        }
    }
}


/*
extension GliderClient.GliderError {
    var errorDescription: String? {
        switch self {
        case .bluetoothNotSupported: return "Bluetooth not supported"
        case .connectionFailed: return "Connection Failed"
        case .invalidInternalState: return "Invalid internal state"
        case .undefinedFileProviderItem(let path): return "Undefined item: \(path)"
        }
    }
    
    var failureReason: String? {
        return errorDescription
    }
    
    var helpAnchor: String? {
        return errorDescription
    }
    
    var recoverySuggestion: String? {
        return errorDescription
    }
}
*/
