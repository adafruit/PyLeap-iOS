//
//  FileViewModel.swift
//  SwiftUI File Manager
//
//  Created by Trevor Beaton on 7/11/21.
//

import SwiftUI
import Zip
import FileTransferClient

class SelectionViewModel: ObservableObject {
    private weak var fileTransferClient: FileTransferClient?
    @Published var entries = [BlePeripheral.DirectoryEntry]()
    @Published var isTransmiting = false
    @Published var bootUpInfo = ""
    enum ProjectViewError: LocalizedError {
        case fileTransferUndefined
    }


    func readMyStatus() {
     //   model.readFile(filename: "boot_out.txt")
        print(#function)

        switch bootUpInfo.description {
            
        case let str where str.contains("Circuit Playground Bluefruit with nRF52840"):
            print("Bluefruit device")
        case let str where str.contains("CLUE nRF52840"):
            print("Clue device")
            
            DispatchQueue.main.async { [self] in
             
                
            }
        default:
            print("Unknown Device")
        }
        
    }
    
    // MARK: System
    
    struct TransmissionProgress {
        var description: String
        var transmittedBytes: Int
        var totalBytes: Int?
        
        init (description: String) {
            self.description = description
            transmittedBytes = 0
        }
    }
    
    @Published var transmissionProgress: TransmissionProgress?
    
    struct TransmissionLog: Equatable {
        enum TransmissionType: Equatable {
            case read(data: Data)
            case write(size: Int)
            case delete
            case listDirectory(numItems: Int?)
            case makeDirectory
            case error(message: String)
        }
        let type: TransmissionType
        
        var description: String {
            let modeText: String
            switch self.type {
            case .read(let data): modeText = "Received \(data.count) bytes"
            case .write(let size): modeText = "Sent \(size) bytes"
            case .delete: modeText = "Deleted file"
            case .listDirectory(numItems: let numItems): modeText = numItems != nil ? "Listed directory: \(numItems!) items" : "Listed nonexistent directory"
            case .makeDirectory: modeText = "Created directory"
            case .error(let message): modeText = message
            }
            
            return modeText
        }
    }
    @Published var lastTransmit: TransmissionLog? =  TransmissionLog(type: .write(size: 334))
    
    enum ActiveAlert: Identifiable {
        case error(error: Error)
        
        var id: Int {
            switch self {
            case .error: return 1
            }
        }
    }
    @Published var activeAlert: ActiveAlert?
    
    // Data
    private let bleManager = BleManager.shared
    
    
    init() {
        
    }
    
    // MARK: - Setup
    func onAppear() {
        //registerNotifications(enabled: true)
        //setup(fileTransferClient: fileTransferClient)
    }
    
    func onDissapear() {
        //registerNotifications(enabled: false)
    }
    
    func setup(fileTransferClient: FileTransferClient?) {
        guard let fileTransferClient = fileTransferClient else {
            DLog("Error: undefined fileTransferClient")
            return
        }
        
        self.fileTransferClient = fileTransferClient
        
    }
    
    // MARK: - Actions
    
    func readFile(filename: String) {
        startCommand(description: "Reading \(filename)")
        readFileCommand(path: filename) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.lastTransmit = TransmissionLog(type: .read(data: data))
                    let str = String(decoding: data, as: UTF8.self)
                    print("Read: \(str)")
                    self.bootUpInfo = str
                    
                    switch str.description {

                    case let str where str.contains("Circuit Playground Bluefruit with nRF52840"):
                        print("Bluefruit device")
                    case let str where str.contains("CLUE nRF52840"):
                        print("Clue device")
                    default:
                        print("Unknown Device")
                    }
                    
                case .failure(let error):
                    self.lastTransmit = TransmissionLog(type: .error(message: error.localizedDescription))
                }
                
                self.endCommand()
            }
        }
    }
   
    
    // MARK: - Command Status
    private func startCommand(description: String) {
        transmissionProgress = TransmissionProgress(description: description)    // Start description with no progress 0 and undefined Total
        lastTransmit = nil
    }
    
    private func endCommand() {
        transmissionProgress = nil
    }
    
    private func readFileCommand(path: String, completion: ((Result<Data, Error>) -> Void)?) {
        guard let fileTransferClient = fileTransferClient else { return }
        
        DLog("start readFile \(path)")
        fileTransferClient.readFile(path: path, progress: { [weak self] read, total in
            DLog("reading progress: \( String(format: "%.1f%%", Float(read) * 100 / Float(total)) )")
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.transmissionProgress?.transmittedBytes = read
                self.transmissionProgress?.totalBytes = total
            }
        }) { result in
            if AppEnvironment.isDebug {
                switch result {
                case .success(let data):
                    DLog("readFile \(path) success. Size: \(data.count)")
                    
                case .failure(let error):
                    DLog("readFile  \(path) error: \(error)")
                }
            }
            
            completion?(result)
        }
    }
    
       // Data
    //private let bleManager = BleManager.shared
    //@Published var fileTransferClient: FileTransferClient?
    // MARK: - Setup
    func onAppear(fileTransferClient: FileTransferClient?) {
        //registerNotifications(enabled: true)
        //setup(fileTransferClient: fileTransferClient)
    }
    
//    func onDissapear() {
//        //registerNotifications(enabled: false)
//    }
    
    /*
    private func setup(fileTransferClient: FileTransferClient?) {
        guard let fileTransferClient = fileTransferClient else {
            DLog("Error: undefined fileTransferClient")
            return
        }
        
        self.fileTransferClient = fileTransferClient
    }*/
      
    
    /*
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
   */
    
}
