//
//  BTConnectionViewModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 7/15/21.
//


import Foundation
import FileTransferClient

class BTConnectionViewModel: ObservableObject {
    // Config
    private static let kRssiRunningAverageFactor = 0.2
    private static let kRepeatTimeForForcedAutoreconnect: TimeInterval = 10       // Should be bigger than the time assigned to FileClientPeripheralConnectionManager reconnectTimeout (defalts to 2 seconds)

    // Published
    enum Destination {
        case fileTransfer
        case selectionView
        case projectView
    }
    
    @Published var destination: Destination? = nil
    
    enum ConnectionStatus {
        case scanning
        case restoringConnection
        case connecting
        case connected
        case discovering
        case fileTransferError
        case fileTransferReady
        case disconnected(error: Error?)
    }
    @Published var connectionStatus: ConnectionStatus = .scanning
    
    @Published var selectedPeripheral: BlePeripheral? = nil
    @Published var numPeripheralsScanned = 0
    @Published var numAdafruitPeripheralsScanned = 0
    @Published var numAdafruitPeripheralsWithFileTranferServiceScanned = 0
    @Published var numAdafruitPeripheralsWithFileTranferServiceNearby = 0
    @Published var isRestoringConnection = false
    
    // Data
    private let bleManager = BleManager.shared
    private var peripheralList = PeripheralList(bleManager: BleManager.shared)
    private var peripheralAutoConnect = PeripheralAutoConnect()
    private var autoreconnectTimer: Timer?
   
    
    func onAppear() {
        registerNotifications(enabled: true)
        startScanning()
    }
    
    func onDissapear() {
        stopScanning()
        registerNotifications(enabled: false)
    }
    
    // MARK: - Scanning Actions
    private func startScanning() {
        updateScannedPeripherals()
        
        // Start scannning
        BlePeripheral.rssiRunningAverageFactor = Self.kRssiRunningAverageFactor     // Use running average for rssi
        if !bleManager.isScanning {
            bleManager.startScan()
            connectionStatus = .scanning
        }
        
        // Start autoreconnect timer
        autoreconnectTimer = Timer.scheduledTimer(withTimeInterval: Self.kRepeatTimeForForcedAutoreconnect, repeats: true, block: { timer in
            DLog("Scan periodic autoreconnect check...")
            FileTransferConnectionManager.shared.reconnect()
        })
    }
    
    private func stopScanning() {
        autoreconnectTimer?.invalidate()
        autoreconnectTimer = nil
        
        if bleManager.isScanning {
            bleManager.stopScan()
        }
    }
    
    // MARK: - Destinations
    private func gotoFileTransfer() {
        destination = .fileTransfer
    }

    /*
    private func gotoSelectionView(){
        destination = .selectionView
    }
    
    private func gotoProjectView(){
        destination = .projectView
    }*/
    
    // MARK: - Scanning Status
    private func updateScannedPeripherals() {
        // Update peripheralAutoconnect
        if let peripheral = peripheralAutoConnect.update(peripheralList: peripheralList) {
            // Connect to closest peripheral
            connect(peripheral: peripheral)
        }
        
        // Update stats
        numPeripheralsScanned = bleManager.numPeripherals()
        numAdafruitPeripheralsScanned = bleManager.peripherals().filter{$0.isManufacturerAdafruit()}.count
        numAdafruitPeripheralsWithFileTranferServiceScanned = peripheralList.filteredPeripherals(forceUpdate: false).count
        numAdafruitPeripheralsWithFileTranferServiceNearby = peripheralAutoConnect.matchingPeripherals.count
    }

    // MARK: - Connections
    private func connect(peripheral: BlePeripheral) {
        // Connect to selected peripheral
        selectedPeripheral = peripheral
        bleManager.connect(to: peripheral)
    }

    private func disconnect(peripheral: BlePeripheral) {
        selectedPeripheral = nil
        bleManager.disconnect(from: peripheral)
    }
    
    // MARK: - BLE Notifications
    private weak var didDiscoverPeripheralObserver: NSObjectProtocol?
    private weak var didUnDiscoverPeripheralObserver: NSObjectProtocol?
    private weak var willConnectToPeripheralObserver: NSObjectProtocol?
    private weak var didConnectToPeripheralObserver: NSObjectProtocol?
    private weak var didDisconnectFromPeripheralObserver: NSObjectProtocol?
    private weak var peripheralDidUpdateNameObserver: NSObjectProtocol?
    private weak var willDiscoverServicesObserver: NSObjectProtocol?
    private weak var willReconnectToKnownPeripheralObserver: NSObjectProtocol?
    private weak var didReconnectToKnownPeripheralObserver: NSObjectProtocol?
    private weak var didFailToReconnectToKnownPeripheralObserver: NSObjectProtocol?

    private func registerNotifications(enabled: Bool) {
        let notificationCenter = NotificationCenter.default
        if enabled {
            didDiscoverPeripheralObserver = notificationCenter.addObserver(forName: .didDiscoverPeripheral, object: nil, queue: .main, using: {[weak self] _ in self?.updateScannedPeripherals()})
               didUnDiscoverPeripheralObserver = notificationCenter.addObserver(forName: .didUnDiscoverPeripheral, object: nil, queue: .main, using: {[weak self] _ in self?.updateScannedPeripherals()})
            willConnectToPeripheralObserver = notificationCenter.addObserver(forName: .willConnectToPeripheral, object: nil, queue: .main, using: {[weak self] notification in self?.willConnectToPeripheral(notification: notification)})
            didConnectToPeripheralObserver = notificationCenter.addObserver(forName: .didConnectToPeripheral, object: nil, queue: .main, using: {[weak self] notification in self?.didConnectToPeripheral(notification: notification)})
            didDisconnectFromPeripheralObserver = notificationCenter.addObserver(forName: .didDisconnectFromPeripheral, object: nil, queue: .main, using: {[weak self] notification in self?.didDisconnectFromPeripheral(notification: notification)})
            peripheralDidUpdateNameObserver = notificationCenter.addObserver(forName: .peripheralDidUpdateName, object: nil, queue: .main, using: {[weak self] notification in self?.peripheralDidUpdateName(notification: notification)})
            willDiscoverServicesObserver = notificationCenter.addObserver(forName: .willDiscoverServices, object: nil, queue: .main, using: {[weak self] notification in self?.willDiscoverServices(notification: notification)})
            willReconnectToKnownPeripheralObserver = NotificationCenter.default.addObserver(forName: .willReconnectToKnownPeripheral, object: nil, queue: .main, using: { [weak self] notification in self?.willReconnectToKnownPeripheral(notification)})
            didReconnectToKnownPeripheralObserver = NotificationCenter.default.addObserver(forName: .didReconnectToKnownPeripheral, object: nil, queue: .main, using: { [weak self] notification in self?.didReconnectToKnownPeripheral(notification)})
            didFailToReconnectToKnownPeripheralObserver = NotificationCenter.default.addObserver(forName: .didFailToReconnectToKnownPeripheral, object: nil, queue: .main, using: { [weak self] notification in self?.didFailToReconnectToKnownPeripheral(notification)})


        } else {
            if let didDiscoverPeripheralObserver = didDiscoverPeripheralObserver {notificationCenter.removeObserver(didDiscoverPeripheralObserver)}
            if let didUnDiscoverPeripheralObserver = didUnDiscoverPeripheralObserver {notificationCenter.removeObserver(didUnDiscoverPeripheralObserver)}
            if let willConnectToPeripheralObserver = willConnectToPeripheralObserver {notificationCenter.removeObserver(willConnectToPeripheralObserver)}
            if let didConnectToPeripheralObserver = didConnectToPeripheralObserver {notificationCenter.removeObserver(didConnectToPeripheralObserver)}
            if let didDisconnectFromPeripheralObserver = didDisconnectFromPeripheralObserver {notificationCenter.removeObserver(didDisconnectFromPeripheralObserver)}
            if let peripheralDidUpdateNameObserver = peripheralDidUpdateNameObserver {notificationCenter.removeObserver(peripheralDidUpdateNameObserver)}
            if let willDiscoverServicesObserver = willDiscoverServicesObserver {notificationCenter.removeObserver(willDiscoverServicesObserver)}
            if let willReconnectToKnownPeripheralObserver = willReconnectToKnownPeripheralObserver {NotificationCenter.default.removeObserver(willReconnectToKnownPeripheralObserver)}
            if let didReconnectToKnownPeripheralObserver = didReconnectToKnownPeripheralObserver {NotificationCenter.default.removeObserver(didReconnectToKnownPeripheralObserver)}
            if let didFailToReconnectToKnownPeripheralObserver = didFailToReconnectToKnownPeripheralObserver {NotificationCenter.default.removeObserver(didFailToReconnectToKnownPeripheralObserver)}
        }
    }

    private func willReconnectToKnownPeripheral(_ notification: Notification) {
        DLog("willReconnectToKnownPeripheral")
        guard let peripheral = bleManager.peripheral(from: notification) else {
            //DLog("willReconnectToKnownPeripheral detected with unknown peripheral")
            return
        }

        DLog("Reconnect selected peripheral")
        selectedPeripheral = peripheral
    }
    
    
    private func didReconnectToKnownPeripheral(_ notification: Notification) {
        DLog("FileTransfer peripheral connected and ready")
        
        // Finished setup
        self.connectionStatus = .fileTransferReady
        self.gotoFileTransfer()
    }
    
    private func didFailToReconnectToKnownPeripheral(_ notification: Notification) {
        if !bleManager.isScanning {
            DLog("Reconnect Failed. Start Scanning")
            startScanning()
        }
    }
    
    private func willConnectToPeripheral(notification: Notification) {
        guard let selectedPeripheral = selectedPeripheral, let identifier = notification.userInfo?[BleManager.NotificationUserInfoKey.uuid.rawValue] as? UUID, selectedPeripheral.identifier == identifier else {
                 DLog("willConnect to an unexpected peripheral")
                 return
             }

        connectionStatus = .connecting
    }

    private func didConnectToPeripheral(notification: Notification) {
        guard let selectedPeripheral = selectedPeripheral, let identifier = notification.userInfo?[BleManager.NotificationUserInfoKey.uuid.rawValue] as? UUID, selectedPeripheral.identifier == identifier else {
            DLog("didConnect to an unexpected peripheral: \(String(describing: notification.userInfo?[BleManager.NotificationUserInfoKey.uuid.rawValue] as? UUID))")
            return
        }
        connectionStatus = .connected
    }

    private func willDiscoverServices(notification: Notification) {
        connectionStatus = .discovering
    }

    private func didDisconnectFromPeripheral(notification: Notification) {
        let peripheral = bleManager.peripheral(from: notification)
        
        let currentlyConnectedPeripheralsCount = bleManager.connectedPeripherals().count
        guard let selectedPeripheral = selectedPeripheral, selectedPeripheral.identifier == peripheral?.identifier || currentlyConnectedPeripheralsCount == 0 else {        // If selected peripheral is disconnected or if there are no peripherals connected (after a failed dfu update)
            return
        }

        // Clear selected peripheral
        self.selectedPeripheral = nil

        // Show error if needed
        connectionStatus = .disconnected(error: bleManager.error(from: notification))
    }

    private func peripheralDidUpdateName(notification: Notification) {
        let name = notification.userInfo?[BlePeripheral.NotificationUserInfoKey.name.rawValue] as? String
        DLog("centralManager peripheralDidUpdateName: \(name ?? "<unknown>")")
    }
}
