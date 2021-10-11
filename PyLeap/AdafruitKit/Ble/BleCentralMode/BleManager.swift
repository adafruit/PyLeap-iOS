//
//  BleManager.swift
//  BleManager
//
//  Created by Antonio García on 13/10/2016.
//  Copyright © 2016 Adafruit. All rights reserved.
//

import Foundation
import CoreBluetooth
import QuartzCore

class BleManager: NSObject {
    // Configuration
    private static let kStopScanningWhenConnectingToPeripheral = false
    private static let kAlwaysAllowDuplicateKeys = true

    // Singleton
    static let shared = BleManager()

    // Ble
    var centralManager: CBCentralManager?
    private var centralManagerPoweredOnSemaphore = DispatchSemaphore(value: 1)

    // Scanning
    var isScanning: Bool {
        return scanningStartTime != nil
    }
    var scanningElapsedTime: TimeInterval? {
        guard let scanningStartTime = scanningStartTime else { return nil }
        return CACurrentMediaTime() - scanningStartTime
    }
    private var isScanningWaitingToStart = false
    internal var scanningStartTime: TimeInterval?        // Time when the scanning started. nil if stopped
    private var scanningServicesFilter: [CBUUID]?
    internal var peripheralsFound = [UUID: BlePeripheral]()
    private var peripheralsFoundFirstTime = [UUID: Date]()       // Date that the perihperal was discovered for the first time. Useful for sorting
    internal var peripheralsFoundLock = NSLock()

    // Connecting
    private var connectionTimeoutTimers = [UUID: Timer]()

    // Notifications
    enum NotificationUserInfoKey: String {
        case uuid = "uuid"
        case error = "error"
    }

    override init() {
        super.init()

        centralManagerPoweredOnSemaphore.wait()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global(qos: .background), options: [:])
//        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main, options: [:])
    }

    deinit {
        scanningServicesFilter?.removeAll()
        peripheralsFound.removeAll()
        peripheralsFoundFirstTime.removeAll()
    }

    public var state: CBManagerState {
        return centralManager?.state ?? .unknown
    }

    func restoreCentralManager() {
        DLog("Restoring central manager")
        /*
        guard centralManager?.delegate !== self else {
            DLog("No need to restore it. It it still ours")
            return
        }*/

        // Restore peripherals status
        peripheralsFoundLock.lock()

        for (_, blePeripheral) in peripheralsFound {
            blePeripheral.peripheral.delegate = nil
        }

        let knownIdentifiers = Array(peripheralsFound.keys)
        let knownPeripherals = centralManager?.retrievePeripherals(withIdentifiers: knownIdentifiers)

        peripheralsFound.removeAll()

        if let knownPeripherals = knownPeripherals {
            for peripheral in knownPeripherals {
                DLog("Adding prediscovered peripheral: \(peripheral.name ?? peripheral.identifier.uuidString)")
                discovered(peripheral: peripheral)
            }
        }

        peripheralsFoundLock.unlock()

        // Restore central manager delegate if was changed
        centralManager?.delegate = self

        if isScanning {
            startScan()
        }
    }

    // MARK: - Scan
    func startScan(withServices services: [CBUUID]? = nil) {
        centralManagerPoweredOnSemaphore.wait()
        centralManagerPoweredOnSemaphore.signal()

        isScanningWaitingToStart = true
        guard let centralManager = centralManager, centralManager.state != .poweredOff && centralManager.state != .unauthorized && centralManager.state != .unsupported else {
            DLog("startScan failed because central manager is not ready")
            return
        }

        scanningServicesFilter = services

        guard centralManager.state == .poweredOn else {
            DLog("startScan failed because central manager is not powered on")
            return
        }

        // DLog("start scan")
        scanningStartTime = CACurrentMediaTime()
        NotificationCenter.default.post(name: .didStartScanning, object: nil)

        let options = BleManager.kAlwaysAllowDuplicateKeys ? [CBCentralManagerScanOptionAllowDuplicatesKey: true] : nil
        centralManager.scanForPeripherals(withServices: services, options: options)
        isScanningWaitingToStart = false
    }

    func stopScan() {
        // DLog("stop scan")
        centralManager?.stopScan()
        scanningStartTime = nil
        isScanningWaitingToStart = false
        NotificationCenter.default.post(name: .didStopScanning, object: nil)
    }
    
    func numPeripherals() -> Int {
        return peripheralsFound.count
    }
    
    func peripherals() -> [BlePeripheral] {
        peripheralsFoundLock.lock(); defer { peripheralsFoundLock.unlock() }
        return Array(peripheralsFound.values)
    }

    func peripheralsSortedByFirstDiscovery() -> [BlePeripheral] {
        let now = Date()
        var peripheralsList = peripherals()
        peripheralsList.sort { (p0, p1) -> Bool in
            peripheralsFoundFirstTime[p0.identifier] ?? now < peripheralsFoundFirstTime[p1.identifier] ?? now
        }
        
        return peripheralsList
    }

    func peripheralsSortedByRSSI() -> [BlePeripheral] {
        var peripheralsList = peripherals()
        peripheralsList.sort { (p0, p1) -> Bool in
            return (p0.rssi ?? -127) > (p1.rssi ?? -127)
        }
        
        return peripheralsList
    }
    
    func connectedPeripherals() -> [BlePeripheral] {
        return peripherals().filter {$0.state == .connected}
    }

    func connectingPeripherals() -> [BlePeripheral] {
        return peripherals().filter {$0.state == .connecting}
    }

    func connectedOrConnectingPeripherals() -> [BlePeripheral] {
        return peripherals().filter {$0.state == .connected || $0.state == .connecting}
    }

    func refreshPeripherals() {
        stopScan()

        peripheralsFoundLock.lock()
        // Don't remove connnected or connecting peripherals
        for (identifier, peripheral) in peripheralsFound {
            if peripheral.state != .connected && peripheral.state != .connecting {
                peripheralsFound.removeValue(forKey: identifier)
                peripheralsFoundFirstTime.removeValue(forKey: identifier)
            }
        }
        peripheralsFoundLock.unlock()

        //
        NotificationCenter.default.post(name: .didUnDiscoverPeripheral, object: nil)
        startScan(withServices: scanningServicesFilter)
    }

    // MARK: - Connection Management
    func connect(to peripheral: BlePeripheral, timeout: TimeInterval? = nil, shouldNotifyOnConnection: Bool = false, shouldNotifyOnDisconnection: Bool = false, shouldNotifyOnNotification: Bool = false) {

        centralManagerPoweredOnSemaphore.wait()
        centralManagerPoweredOnSemaphore.signal()

        // Stop scanning when connecting to a peripheral 
        if BleManager.kStopScanningWhenConnectingToPeripheral {
            stopScan()
        }

        // Connect
        NotificationCenter.default.post(name: .willConnectToPeripheral, object: nil, userInfo: [NotificationUserInfoKey.uuid.rawValue: peripheral.identifier])

        //DLog("connect")
        var options: [String: Bool]?

        #if os(OSX)
        #else
            if shouldNotifyOnConnection || shouldNotifyOnDisconnection || shouldNotifyOnNotification {
                options = [CBConnectPeripheralOptionNotifyOnConnectionKey: shouldNotifyOnConnection, CBConnectPeripheralOptionNotifyOnDisconnectionKey: shouldNotifyOnDisconnection, CBConnectPeripheralOptionNotifyOnNotificationKey: shouldNotifyOnNotification]
            }
        #endif

        if let timeout = timeout {
            self.connectionTimeoutTimers[peripheral.identifier] = Timer.scheduledTimer(timeInterval: timeout, target: self, selector: #selector(self.connectionTimeoutFired), userInfo: peripheral.identifier, repeats: false)
        }
        centralManager?.connect(peripheral.peripheral, options: options)
    }

    @objc private func connectionTimeoutFired(timer: Timer) {
        let peripheralIdentifier = timer.userInfo as! UUID
        DLog("connection timeout fired: \(peripheralIdentifier)")
        connectionTimeoutTimers[peripheralIdentifier] = nil

        NotificationCenter.default.post(name: .willDisconnectFromPeripheral, object: nil, userInfo: [NotificationUserInfoKey.uuid.rawValue: peripheralIdentifier])

        if let blePeripheral = peripheralsFound[peripheralIdentifier] {
            centralManager?.cancelPeripheralConnection(blePeripheral.peripheral)
        } else {
            DLog("simulate disconnection")
            // The blePeripheral is available on peripheralsFound, so simulate the disconnection
            NotificationCenter.default.post(name: .didDisconnectFromPeripheral, object: nil, userInfo: [NotificationUserInfoKey.uuid.rawValue: peripheralIdentifier])
        }
    }

    func disconnect(from peripheral: BlePeripheral, waitForQueuedCommands: Bool = false) {
        guard let centralManager = centralManager else { return}

        DLog("disconnect")
        NotificationCenter.default.post(name: .willDisconnectFromPeripheral, object: nil, userInfo: [NotificationUserInfoKey.uuid.rawValue: peripheral.identifier])

        if waitForQueuedCommands {
            // Send the disconnection to the command queue, so all the previous command are executed before disconnecting
            peripheral.disconnect(centralManager: centralManager)
        } else {
            centralManager.cancelPeripheralConnection(peripheral.peripheral)
        }
    }
    
    func reconnecToPeripherals(peripheralUUIDs identifiers: [UUID]?, withServices services: [CBUUID], timeout: Double? = nil) -> Bool {
        var reconnecting = false
        
        // Reconnect to a known identifier
        if let identifiers = identifiers {
            let knownPeripherals = centralManager?.retrievePeripherals(withIdentifiers: identifiers)
            if let peripherals = knownPeripherals?.filter({identifiers.contains($0.identifier)}), !peripherals.isEmpty {
                for peripheral in peripherals {
                    discovered(peripheral: peripheral, advertisementData: nil)
                    if let blePeripheral = peripheralsFound[peripheral.identifier] {
                        connect(to: blePeripheral, timeout: timeout)
                        reconnecting = true
                    }
                }
            } else {
                let connectedPeripherals = centralManager?.retrieveConnectedPeripherals(withServices: services)
                if let peripherals = connectedPeripherals?.filter({identifiers.contains($0.identifier)}), !peripherals.isEmpty {
                    for peripheral in peripherals {
                        discovered(peripheral: peripheral, advertisementData: nil )
                        if let blePeripheral = peripheralsFound[peripheral.identifier] {
                            connect(to: blePeripheral, timeout: timeout)
                            reconnecting = true
                        }
                    }
                }
            }
        }

        // Reconnect even if no identifier was saved if we are already connected to a device with the expected services
        /*
        if !reconnecting {
            if let peripherals = centralManager?.retrieveConnectedPeripherals(withServices: services) {
                for peripheral in peripherals {
                    discovered(peripheral: peripheral, advertisementData: nil )
                    if let blePeripheral = peripheralsFound[peripheral.identifier] {
                        connect(to: blePeripheral, timeout: timeout)
                        reconnecting = true
                    }
                }
            }
        }*/
        
        return reconnecting
    }

    private func discovered(peripheral: CBPeripheral, advertisementData: [String: Any]? = nil, rssi: Int? = nil) {
        peripheralsFoundLock.lock(); defer { peripheralsFoundLock.unlock() }

        if let existingPeripheral = peripheralsFound[peripheral.identifier] {
            existingPeripheral.lastSeenTime = CFAbsoluteTimeGetCurrent()

            if let rssi = rssi, rssi != BlePeripheral.kUndefinedRssiValue {     // only update rssi value if is defined ( 127 means undefined )
                existingPeripheral.rssi = rssi
            }

            if let advertisementData = advertisementData {
                for (key, value) in advertisementData {
                    existingPeripheral.advertisement.advertisementData.updateValue(value, forKey: key)
                }
            }
            peripheralsFound[peripheral.identifier] = existingPeripheral
        } else {      // New peripheral found
            let blePeripheral = BlePeripheral(peripheral: peripheral, advertisementData: advertisementData, rssi: rssi)
            peripheralsFound[peripheral.identifier] = blePeripheral
            peripheralsFoundFirstTime[peripheral.identifier] = Date()
        }
    }

    
    // MARK: - Notifications
    func peripheral(from notification: Notification) -> BlePeripheral? {
        guard let uuid = notification.userInfo?[NotificationUserInfoKey.uuid.rawValue] as? UUID else { return nil }

        return peripheral(with: uuid)
    }

    func error(from notification: Notification) -> Error? {
        return notification.userInfo?[NotificationUserInfoKey.error.rawValue] as? Error
    }
    
    func peripheral(with uuid: UUID) -> BlePeripheral? {
        return peripheralsFound[uuid]
    }
}

// MARK: - CBCentralManagerDelegate
extension BleManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        DLog("centralManagerDidUpdateState: \(central.state.rawValue)")
        // Unlock state lock if we have a known state
        if central.state == .poweredOn || central.state == .poweredOff || central.state == .unsupported || central.state == .unauthorized {
            centralManagerPoweredOnSemaphore.signal()
        }

        // Scanning
        if central.state == .poweredOn {
            if isScanningWaitingToStart {
                startScan(withServices: scanningServicesFilter)        // Continue scanning now that bluetooth is back
            }
        } else {
            if isScanning {
                isScanningWaitingToStart = true
            }
            scanningStartTime = nil

            // Remove all peripherals found (Important because the BlePeripheral queues could contain old commands that were processing when the bluetooth state changed)
            peripheralsFound.removeAll()
        }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .didUpdateBleState, object: nil)
        }
    }
    
    /*
     func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
     
     }*/
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        // DLog("didDiscover: \(peripheral.name ?? peripheral.identifier.uuidString)")
        let rssi = RSSI.intValue
        DispatchQueue.main.async {      // This Fixes iOS12 race condition on cached filtered peripherals. TODO: investigate
            self.discovered(peripheral: peripheral, advertisementData: advertisementData, rssi: rssi)
            NotificationCenter.default.post(name: .didDiscoverPeripheral, object: nil, userInfo: [NotificationUserInfoKey.uuid.rawValue: peripheral.identifier])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DLog("didConnect: \(peripheral.identifier)")
        
        // Remove connection timeout if exists
        if let timer = connectionTimeoutTimers[peripheral.identifier] {
            timer.invalidate()
            connectionTimeoutTimers[peripheral.identifier] = nil
        }
        
        // Send notification
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .didConnectToPeripheral, object: nil, userInfo: [NotificationUserInfoKey.uuid.rawValue: peripheral.identifier])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        DLog("didFailToConnect: \(String(describing: error))")
        
        // Clean
        peripheralsFound[peripheral.identifier]?.reset()
        
        // Notify
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .didDisconnectFromPeripheral, object: nil, userInfo: [
                NotificationUserInfoKey.uuid.rawValue: peripheral.identifier,
                NotificationUserInfoKey.error.rawValue: error as Any
            ])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        DLog("didDisconnectPeripheral")
        
        // Clean
        peripheralsFound[peripheral.identifier]?.reset()
        
        // Notify
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .didDisconnectFromPeripheral, object: nil, userInfo: [NotificationUserInfoKey.uuid.rawValue: peripheral.identifier])
        }

        // Remove from peripheral list (after sending notification so the receiving objects can query about the peripheral before being removed)
        peripheralsFoundLock.lock()
        peripheralsFound.removeValue(forKey: peripheral.identifier)
        peripheralsFoundLock.unlock()
    }
}

// MARK: - Custom Notifications
extension Notification.Name {
    private static let kPrefix = Bundle.main.bundleIdentifier!
    static let didUpdateBleState = Notification.Name(kPrefix+".didUpdateBleState")
    static let didStartScanning = Notification.Name(kPrefix+".didStartScanning")
    static let didStopScanning = Notification.Name(kPrefix+".didStopScanning")
    static let didDiscoverPeripheral = Notification.Name(kPrefix+".didDiscoverPeripheral")
    static let didUnDiscoverPeripheral = Notification.Name(kPrefix+".didUnDiscoverPeripheral")
    static let willConnectToPeripheral = Notification.Name(kPrefix+".willConnectToPeripheral")
    static let didConnectToPeripheral = Notification.Name(kPrefix+".didConnectToPeripheral")
    static let willDisconnectFromPeripheral = Notification.Name(kPrefix+".willDisconnectFromPeripheral")
    static let didDisconnectFromPeripheral = Notification.Name(kPrefix+".didDisconnectFromPeripheral")
}
