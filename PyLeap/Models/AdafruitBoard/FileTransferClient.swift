//
//  FileTransferClient.swift
//  Glider
//
//  Created by Antonio García on 26/10/2019.
//  Copyright © 2019 Adafruit. All rights reserved.
//

import UIKit
import CoreBluetooth


class FileTransferClient {
    // Data structs
    typealias ProgressHandler = ((_ transmittedBytes: Int, _ totalBytes: Int) -> Void)
    
    enum ClientError: Error {
        //case connectionFailed
        case errorDiscoveringServices
        case serviceNotEnabled
    }
    
    enum Service: CaseIterable {
        case filetransfer
        
        var debugName: String {
            switch self {
            case .filetransfer: return "File Transfer"
            }
        }
    }
    
    // Notifications
    enum NotificationUserInfoKey: String {
        case uuid = "uuid"
        case value = "value"
    }
 
    // Data
    private(set) weak var blePeripheral: BlePeripheral?

    // MARK: - Init
    /**
     Init from CBPeripheral
     
     - parameters:
     - connectedCBPeripehral: a *connected* CBPeripheral
     - services: list of BoardServices that will be started. Use nil to select all the supported services
     - completion: completion handler
     */
    convenience init(connectedCBPeripheral peripheral: CBPeripheral, services: [Service]? = nil, completion: @escaping (Result<FileTransferClient, Error>) -> Void) {
        print("Test")
        let blePeripheral = BlePeripheral(peripheral: peripheral, advertisementData: nil, rssi: nil)
        self.init(connectedBlePeripheral: blePeripheral, services: services, completion: completion)
    }
        
    /**
     Init from BlePeripheral
     
     - parameters:
     - connectedBlePeripheral: a *connected* BlePeripheral
     - services: list of BoardServices that will be started. Use nil to select all the supported services
     - completion: completion handler
     */
    init(connectedBlePeripheral blePeripheral: BlePeripheral, services: [Service]? = nil, completion: @escaping (Result<FileTransferClient, Error>) -> Void) {
        
        DLog("Discovering services")
        let peripheralIdentifier = blePeripheral.identifier
        NotificationCenter.default.post(name: .willDiscoverServices, object: nil, userInfo: [NotificationUserInfoKey.uuid.rawValue: peripheralIdentifier])
        blePeripheral.discover(serviceUuids: nil) { error in
            // Check errors
            guard error == nil else {
                DLog("Error discovering services")
                DispatchQueue.main.async {
                    completion(.failure(ClientError.errorDiscoveringServices))
                }
                return
            }
            
            // Setup services
            let selectedServices = services != nil ? services! : Service.allCases   // If services is nil, select all services
            
            self.setupServices(blePeripheral: blePeripheral, services: selectedServices, completion: completion)
        }
    }
    
    private func setupServices(blePeripheral: BlePeripheral, services: [Service], completion: @escaping (Result<FileTransferClient, Error>) -> Void) {
        
        // Set current peripheral
        self.blePeripheral = blePeripheral
        
        // Setup services
        let servicesGroup = DispatchGroup()
        
        // File Transfer
        if services.contains(.filetransfer) {
            servicesGroup.enter()
            blePeripheral.adafruitFileTransferEnable() { _ in
                servicesGroup.leave()
            }
        }
        
        // Wait for all finished
        servicesGroup.notify(queue: .main) { /*[weak self] in*/
            DLog("setupServices finished")
            
            if AppEnvironment.isDebug {
                /*
                guard let self = self else {
                    DLog("Warning: FileTransferClient deallocated before finishing");
                    return                    
                }*/
                for service in services {
                    DLog(self.isEnabled(service: service) ? "\(service.debugName) reading enabled":"\(service.debugName) service not available")
                }
            }
            
            completion(.success((self)))
        }
    }

    // MARK: - Sensor availability
    var isFileTransferEnabled: Bool {
        return blePeripheral?.adafruitFileTransferIsEnabled() ?? false
    }
    
    func isEnabled(service: Service) -> Bool {
        switch service {
        case .filetransfer: return isFileTransferEnabled
        }
    }
    
    // MARK: - File Transfer Commands
    
    /// Given a full path, returns the full contents of the file
    func readFile(path: String, progress: ProgressHandler? = nil, completion: ((Result<Data, Error>) -> Void)?) {
        blePeripheral?.readFile(path: path, progress: progress, completion: completion)
    }

    ///  Writes the content to the given full path. If the file exists, it will be overwritten
    func writeFile(path: String, data: Data, progress: ProgressHandler? = nil, completion: ((Result<Void, Error>) -> Void)?) {
        blePeripheral?.writeFile(path: path, data: data, progress: progress, completion: completion)
    }
    
    /// Deletes the file or directory at the given full path. Directories must be empty to be deleted
    func deleteFile(path: String, completion: ((Result<Bool, Error>) -> Void)?) {
        blePeripheral?.deleteFile(path: path, completion: completion)
    }

    /**
     Creates a new directory at the given full path. If a parent directory does not exist, then it will also be created. If any name conflicts with an existing file, an error will be returned
        - Parameter path: Full path. It should use a trailing slash.
    */
    func makeDirectory(path: String, completion: ((Result<Bool, Error>) -> Void)?) {
        blePeripheral?.makeDirectory(path: path, completion: completion)
    }

    /// Lists all of the contents in a directory given a full path. Returned paths are relative to the given path to reduce duplication
    func listDirectory(path: String, completion: ((Result<[BlePeripheral.DirectoryEntry]?, Error>) -> Void)?) {
        blePeripheral?.listDirectory(path: path, completion: completion)
    }
}

// MARK: - Custom Notifications
extension Notification.Name {
    private static let kNotificationsPrefix = Bundle.main.bundleIdentifier!
    static let willDiscoverServices = Notification.Name(kNotificationsPrefix+".willDiscoverServices")
 }

// MARK: - Equatable
extension FileTransferClient: Equatable {
    static func ==(lhs: FileTransferClient, rhs: FileTransferClient) -> Bool {
        return lhs.blePeripheral == rhs.blePeripheral
    }
}
