//
//  FileViewModel.swift
//  SwiftUI File Manager
//
//  Created by Trevor Beaton on 7/11/21.
//

import SwiftUI
import Zip


class SelectionViewModel: ObservableObject {
    
    @Published var fileArray: [ContentFile] = []
    @Published var projects: [Project] = []
    
    
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    let cachesPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    
    func startup(){
        print("Directory Path: \(directoryPath.path)")
        print("Caches Directory Path: \(cachesPath.path)")

        
        do {
            
            let contents = try FileManager.default.contentsOfDirectory(at: directoryPath, includingPropertiesForKeys: nil,options: [.skipsHiddenFiles])
            
            for file in contents {
                print("File Content: \(file.lastPathComponent)")
              //  print("File Size: \(fileSize)")
                
               let addedFile = ContentFile(title: file.lastPathComponent)
                self.fileArray.append(addedFile)
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    // Data
    private let bleManager = BleManager.shared
    @Published var fileTransferClient: FileTransferClient?
    // MARK: - Setup
    func onAppear(fileTransferClient: FileTransferClient?) {
        registerNotifications(enabled: true)
        setup(fileTransferClient: fileTransferClient)
    }
    
    func onDissapear() {
        registerNotifications(enabled: false)
    }
    
    private func setup(fileTransferClient: FileTransferClient?) {
        guard let fileTransferClient = fileTransferClient else {
            DLog("Error: undefined fileTransferClient")
            return
        }
        
        self.fileTransferClient = fileTransferClient
    }
    
    // MARK: - Actions
    func disconnectAndForgetPairing() {
        Settings.clearAutoconnectPeripheral()
        if let blePeripheral = fileTransferClient?.blePeripheral {
            bleManager.disconnect(from: blePeripheral)
        }
    }
    
    
    // MARK: - BLE Notifications
    private weak var didDisconnectFromPeripheralObserver: NSObjectProtocol?

    private func registerNotifications(enabled: Bool) {
        let notificationCenter = NotificationCenter.default
        if enabled {
          didDisconnectFromPeripheralObserver = notificationCenter.addObserver(forName: .didDisconnectFromPeripheral, object: nil, queue: .main, using: {[weak self] notification in self?.didDisconnectFromPeripheral(notification: notification)})
 
        } else {
            if let didDisconnectFromPeripheralObserver = didDisconnectFromPeripheralObserver {notificationCenter.removeObserver(didDisconnectFromPeripheralObserver)}
        }
    }
    
    private func didDisconnectFromPeripheral(notification: Notification) {
        let peripheral = bleManager.peripheral(from: notification)

        let currentlyConnectedPeripheralsCount = bleManager.connectedPeripherals().count
        guard let selectedPeripheral = fileTransferClient?.blePeripheral, selectedPeripheral.identifier == peripheral?.identifier || currentlyConnectedPeripheralsCount == 0 else {        // If selected peripheral is disconnected or if there are no peripherals connected (after a failed dfu update)
            return
        }

        // Disconnect
        fileTransferClient = nil
    }
   
    
}
