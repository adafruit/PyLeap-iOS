//
//  FileTransferConnectionManager.swift
//  Glider
//
//  Created by Antonio García on 21/6/21.
//

import Foundation
import CoreBluetooth
import Combine

public class FileTransferConnectionManager: ObservableObject {
    // Config
    private static let kMaxTimeToWaitForBleSupport: TimeInterval = 5.0
    private static let kMaxTimeToWaitForPeripheralConnection: TimeInterval = 5.0

    // Singleton
    public static let shared = FileTransferConnectionManager()
    
    // Constants
    private static let knownPeripheralsKey = "knownPeripherals"
 
    // Published
    @Published public var peripherals = [BlePeripheral]()           // Peripherals connected or connecting
    @Published public var selectedPeripheral: BlePeripheral?        // Selected peripheral from all the connected peripherals. User can select it using setSelectedClient. The system picks one automatically if it gets disconnected or the user didnt select one
    @Published public var isSelectedPeripheralReconnecting = false  // Is the selected peripheral reconnecting
    @Published public var isConnectedOrReconnecting = false         // Is any peripheral connected or trying to connect
    @Published public var isAnyPeripheralConnecting = false
    
    // Parameters
    public var userDefaults = UserDefaults.standard        // Can be replaced if data saved needs to be shared

    // Data
    private let reconnectTimeout: TimeInterval = 2
    
    private var isReconnectingPeripheral = [UUID: Bool]()           // Is reconnecting the peripheral with identifier
    private var fileTransferClients = [UUID: FileTransferClient]()  // FileTransferClient for each peripheral
    private var userSelectedTransferClient: FileTransferClient? {   // User selected client (or picked automatically by the system if user didn't pick or got disconnected)
        didSet {
            updateSelectedPeripheral()
        }
    }
    private var recoveryPeripheralIdentifier: UUID? // (UUID, Timer)?      // Data for a peripheral that was disconnected. There is a timer

    // Data - Ble status
    private let bleSupportSemaphore = DispatchSemaphore(value: 0)
    private let connectionSemaphore = DispatchSemaphore(value: 0)
    private var cancellables = Set<AnyCancellable>()

    
    //  MARK: - Lifecycle
    private init() {//(reconnectTimeout: TimeInterval = 2) {
        //DLog("Init FileClientPeripheralConnectionManager")
        //self.reconnectTimeout = reconnectTimeout
        
        // Init peripherals
        self.peripherals = BleManager.shared.connectedOrConnectingPeripherals()

        // Register notifications
        registerConnectionNotifications(enabled: true)
    }

    deinit {
        // Unregister notifications
        registerConnectionNotifications(enabled: false)
    }
 

    //  MARK: - Actions
    public var selectedClient: FileTransferClient? {
        return userSelectedTransferClient ?? fileTransferClients.values.first
    }

    public func setSelectedClient(blePeripheral: BlePeripheral) {
        if let client = fileTransferClients[blePeripheral.identifier] {
            setSelectedClient(client)
        }
    }
    
    public func setSelectedClient(_ client: FileTransferClient) {
        userSelectedTransferClient = client
    }
    
    public func peripheral(fromIdentifier identifier: UUID) -> BlePeripheral? {
        return self.peripherals.first(where: {$0.identifier == identifier})
    }
    
    public func fileTransferClient(fromIdentifier identifier: UUID) -> FileTransferClient? {
        return self.fileTransferClients[identifier]
    }
    
    public func isReconnectingPeripheral(withIdentifier identifier: UUID) -> Bool {
        return isReconnectingPeripheral[identifier] ?? false
    }
    
    public func waitForKnownBleStatusSynchronously() {
        let bleState = BleManager.shared.state
        if bleState == .unknown || bleState == .resetting {
            NotificationCenter.default.publisher(for: .didUpdateBleState)
                .sink { [weak self] notification in
                    guard let self = self else { return }
                    DLog("Bluetooth status received: \(BleManager.shared.state.rawValue)")
                    self.bleSupportSemaphore.signal()
                    self.cancellables.removeAll()       // Notification observer no longer needed
                }
                .store(in: &cancellables)

            let semaphoreResult = self.bleSupportSemaphore.wait(timeout: .now() + Self.kMaxTimeToWaitForBleSupport)
            if semaphoreResult == .timedOut {
                DLog("Bluetooth support check time-out. status: \(BleManager.shared.state.rawValue)")
            }
        }
    }
    
    public func waitForStableConnectionsSynchronously() {
        guard isAnyPeripheralConnecting else  { return }
        DLog("Wait for connection started")
        $isAnyPeripheralConnecting.sink { isAnyPeripheralConnecting in
            if !isAnyPeripheralConnecting {
                DLog("Wait for connection finished")
                self.connectionSemaphore.signal()
                self.cancellables.removeAll()       // Notification observer no longer needed
            }
        }
        .store(in: &cancellables)
        
        let semaphoreResult = self.connectionSemaphore.wait(timeout: .now() + Self.kMaxTimeToWaitForPeripheralConnection)
        if semaphoreResult == .timedOut {
            DLog("Wait for connection check time-out")
        }
    }
    
    /// Returns if is trying to reconnect, or false if it is quickly decided that there is not possible
    @discardableResult
    public func reconnect() -> Bool {
        // Filter-out from knownPeripherals those that are not connected or connecting at the moment
        let alreadyConnectedOrConnectingUUIDs = peripherals.map{$0.identifier}
        let reconnectUUIDs = knownPeripheralsUUIDs.filter{ !alreadyConnectedOrConnectingUUIDs.contains($0) }
        
        // Reconnect
        let isTryingToReconnect = BleManager.shared.reconnecToPeripherals(peripheralUUIDs: reconnectUUIDs, withServices: [BlePeripheral.kFileTransferServiceUUID], timeout: reconnectTimeout)
        if !isTryingToReconnect {
            NotificationCenter.default.post(name: .didFailToReconnectToKnownPeripheral, object: nil)
            DLog("No previous connected peripherals detected")
        }
        
        return isTryingToReconnect
    }
    
    // MARK: - Reconnect previously connnected Ble Peripheral
    private func willConnectToPeripheral(_ notification: Notification) {
        guard let peripheralUUID = BleManager.shared.peripheralUUID(from: notification) else {
            DLog("Will connect to a not scanned peripheral")
            return
        }
        
        isReconnectingPeripheral[peripheralUUID] = true
        updateConnectionStatus()
    }
    
    private func didConnectToPeripheral(_ notification: Notification) {
        guard let peripheralUUID = BleManager.shared.peripheralUUID(from: notification) else { return }

        guard let peripheral = BleManager.shared.peripheral(from: notification) else {
            // Don't assume that it failed. It could have restored the connection but the internal database in BleManager does not have the BlePeripheral
            DLog("Connected to a not scanned peripheral: \(peripheralUUID)")
            NotificationCenter.default.post(name: .didReconnectToKnownPeripheral, object: nil, userInfo: nil)
            
            isReconnectingPeripheral[peripheralUUID] = false
            updateConnectionStatus()
            return
        }
        
        connected(peripheral: peripheral)
    }

    private func didDisconnectFromPeripheral(_ notification: Notification) {
        
        // Update peripherals
        self.peripherals = BleManager.shared.connectedOrConnectingPeripherals()
        
        // Get identifier for the disconnected peripheral
        guard let peripheralUUID = BleManager.shared.peripheralUUID(from: notification) else {
            DLog("warning: unknown peripheral disconnected")
            updateConnectionStatus()
            return
        }
        
        if isReconnectingPeripheral[peripheralUUID] == true {
            DLog("recover failed for \(peripheralUUID.uuidString)")
            setReconnectionFailed(peripheralUUID: peripheralUUID)
            if self.recoveryPeripheralIdentifier == peripheralUUID {        // If it was recovering then remove it because it failed
                self.recoveryPeripheralIdentifier = nil
            }
            self.updateSelectedPeripheral()
        }
        // If it was the selected peripheral try to recover the connection because a peripheral can be disconnected momentarily when writing to the filesystem.
        else if selectedClient?.blePeripheral?.identifier == peripheralUUID {
            userSelectedTransferClient = nil
            
            // Wait for recovery before connecting to a different one
            DLog("Try to recover disconnected peripheral: \(selectedPeripheral?.name ?? selectedPeripheral?.identifier.uuidString ?? "nil")")
            self.recoveryPeripheralIdentifier = peripheralUUID
            self.isSelectedPeripheralReconnecting = true
            
            DispatchQueue.main.async {      // Important: add delay because the disconnection process will remove the peripheral from the discovered list and the reconnectToPeripherals will add it back, so wait before adding or it will be removed
                // Reconnect
                let isTryingToReconnect = BleManager.shared.reconnecToPeripherals(peripheralUUIDs: [peripheralUUID], withServices: [BlePeripheral.kFileTransferServiceUUID], timeout: self.reconnectTimeout)
                if !isTryingToReconnect {
                    DLog("recover failed. Autoselect another peripheral")
                    self.fileTransferClients[peripheralUUID] = nil      // Remove info from disconnnected peripheral (it will change selectedClient)
                    self.updateSelectedPeripheral()
                    self.isSelectedPeripheralReconnecting = false
                }
            }
        }
        else {      // Any other peripheral -> Also try to reconnect but status will not affect the selected client
            DispatchQueue.main.async {
                let isTryingToReconnect = BleManager.shared.reconnecToPeripherals(peripheralUUIDs: [peripheralUUID], withServices: [BlePeripheral.kFileTransferServiceUUID], timeout: self.reconnectTimeout)
                if !isTryingToReconnect {
                    self.fileTransferClients[peripheralUUID] = nil      // Remove info
                }
            }
        }
                
        updateConnectionStatus()
    }
    
    private func setReconnectionFailed(peripheralUUID: UUID) {
        isReconnectingPeripheral[peripheralUUID] = false
        
        if peripheralUUID == selectedPeripheral?.identifier {       // If it the selectedPeripheral, then the reconnection failed
            self.isSelectedPeripheralReconnecting = false
        }
        fileTransferClients[peripheralUUID] = nil  // Remove info from disconnnected peripheral
        NotificationCenter.default.post(name: .didFailToReconnectToKnownPeripheral, object: nil)
    }
    
    // MARK: - Utils
    private func updateConnectionStatus() {
        // Update @Published isAnyPeripheralConnecting
        let isAnyPeripheralConnecting = isReconnectingPeripheral.values.contains(true)
        if isAnyPeripheralConnecting != self.isAnyPeripheralConnecting {
            self.isAnyPeripheralConnecting = isAnyPeripheralConnecting
        }
        
        // Update @Published isConnectedOrReconnecting
        let isConnectedOrReconnecting = !peripherals.isEmpty || isAnyPeripheralConnecting || recoveryPeripheralIdentifier != nil
        guard isConnectedOrReconnecting != self.isConnectedOrReconnecting else { return }       // Only update if changed

        // Update @Published value
        self.isConnectedOrReconnecting = isConnectedOrReconnecting
        //DLog("updateConnectionStatus: \(isConnectedOrReconnecting)")
    }
    
    private func updateSelectedPeripheral() {
        guard selectedClient?.blePeripheral != selectedPeripheral else { return }
        
        // Update @Published value
        selectedPeripheral = selectedClient?.blePeripheral
        
        DLog("selectedPeripheral: \(selectedPeripheral?.name ?? selectedPeripheral?.identifier.uuidString ?? "nil")")
        NotificationCenter.default.post(name: .didSelectPeripheralForFileTransfer, object: nil, userInfo: [BleManager.NotificationUserInfoKey.uuid.rawValue: selectedPeripheral?.identifier as Any])
        
        // Check that the selected client corresponds to the selected peripheral
        if let selectedPeripheralIdentifier = selectedPeripheral?.identifier, let selectedPeripheralClient = fileTransferClients[selectedPeripheralIdentifier], userSelectedTransferClient != selectedPeripheralClient {
            setSelectedClient(selectedPeripheralClient)
        }
    }
    
    private func connected(peripheral: BlePeripheral) {
        // Show restoring connection label
        NotificationCenter.default.post(name: .willReconnectToKnownPeripheral, object: nil, userInfo: [BleManager.NotificationUserInfoKey.uuid.rawValue: peripheral.identifier])
        
        // Update peripherals
        self.peripherals = BleManager.shared.connectedOrConnectingPeripherals()
        
        // Finish FileTransfer setup on connection
        let _ = FileTransferClient(connectedBlePeripheral: peripheral, services: [.filetransfer]) { [unowned self] result in
            self.isReconnectingPeripheral[peripheral.identifier] = false // Finished reconnection process
            self.updateConnectionStatus()

            switch result {
            case .success(let client):
                if client.isFileTransferEnabled {
                    //DLog("Reconnected to peripheral successfully")
                    self.fileTransferClients[peripheral.identifier] = client

                    if peripheral.identifier == self.selectedPeripheral?.identifier {       // If it is the selectedPeripheral, then the reconnection finished successfuly
                        self.isSelectedPeripheralReconnecting = false
                    }

                    self.updateSelectedPeripheral()
                    self.addKnownPeripheralsUUIDs(peripheral.identifier)

                    NotificationCenter.default.post(name: .didReconnectToKnownPeripheral, object: nil, userInfo: [BleManager.NotificationUserInfoKey.uuid.rawValue: peripheral.identifier])
                }
                else {
                    DLog("Failed setup file transfer")
                    self.setReconnectionFailed(peripheralUUID: peripheral.identifier)
                }
                
            case .failure(let error):
                DLog("Failed to setup peripheral: \(error.localizedDescription)")
                self.setReconnectionFailed(peripheralUUID: peripheral.identifier)
            }
        }
    }
    
    // MARK: - Known periperhals
    private var knownPeripheralsUUIDs: [UUID] {
        guard let uuidStrings = userDefaults.array(forKey: Self.knownPeripheralsKey) as? [String] else { return [] }
        
        let uuids = uuidStrings.compactMap{ UUID(uuidString: $0) }
        return uuids
    }
    
    private func addKnownPeripheralsUUIDs(_ uuid: UUID) {
        var peripheralsUUIDs = knownPeripheralsUUIDs
        if !peripheralsUUIDs.contains(uuid) {
            DLog("Add autoconnect peripheral: \(uuid.uuidString)")
            peripheralsUUIDs.append(uuid)
        }
        userDefaults.set(peripheralsUUIDs.map{$0.uuidString}, forKey: Self.knownPeripheralsKey)
    }
    
    private func clearKnownPeripheralUUIDs() {
        userDefaults.set(nil, forKey: Self.knownPeripheralsKey )
    }

    // MARK: - Notifications
    private var willConnectToPeripheralObserver: NSObjectProtocol?
    private var didConnectToPeripheralObserver: NSObjectProtocol?
    private var didDisconnectFromPeripheralObserver: NSObjectProtocol?

    private func registerConnectionNotifications(enabled: Bool) {
        if enabled {
            willConnectToPeripheralObserver = NotificationCenter.default.addObserver(forName: .willConnectToPeripheral, object: nil, queue: .main, using: { [weak self] notification in self?.willConnectToPeripheral(notification)})
            didConnectToPeripheralObserver = NotificationCenter.default.addObserver(forName: .didConnectToPeripheral, object: nil, queue: .main, using: { [weak self] notification in self?.didConnectToPeripheral(notification)})
            didDisconnectFromPeripheralObserver = NotificationCenter.default.addObserver(forName: .didDisconnectFromPeripheral, object: nil, queue: .main, using: { [weak self] notification in self?.didDisconnectFromPeripheral(notification)})
        } else {
            if let willConnectToPeripheralObserver = willConnectToPeripheralObserver {NotificationCenter.default.removeObserver(willConnectToPeripheralObserver)}
            if let didConnectToPeripheralObserver = didConnectToPeripheralObserver {NotificationCenter.default.removeObserver(didConnectToPeripheralObserver)}
            if let didDisconnectFromPeripheralObserver = didDisconnectFromPeripheralObserver {NotificationCenter.default.removeObserver(didDisconnectFromPeripheralObserver)}
        }
    }
}

// MARK: - Custom Notifications
extension Notification.Name {
    private static let kPrefix = Bundle.main.bundleIdentifier!
    public static let willReconnectToKnownPeripheral = Notification.Name(kPrefix+".willReconnectToKnownPeripheral")
    public static let didReconnectToKnownPeripheral = Notification.Name(kPrefix+".didReconnectToKnownPeripheral")
    public static let didFailToReconnectToKnownPeripheral = Notification.Name(kPrefix+".didFailToReconnectToKnownPeripheral")
    public static let didSelectPeripheralForFileTransfer = Notification.Name(kPrefix+".didSelectPeripheralForFileTransfer")
}


