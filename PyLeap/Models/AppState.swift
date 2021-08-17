//
//  AppState.swift
//  Glider
//
//  Created by Antonio García on 15/6/21.
//

import Foundation

class AppState: ObservableObject {
    // Singleton
    static let shared = AppState()
    
    // Published
    @Published var fileTransferClient: FileTransferClient? = nil
    
    // Data
    private var autoReconnect: BleAutoReconnect?
    
    public func startAutoReconnect() {
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
    
    public func stopAutoReconnect() {
        autoReconnect = nil
    }
    
    /// Returns if is trying to reconnect, or false if it is quickly decided that there is not possible
    @discardableResult
    public func forceReconnect() -> Bool {
        guard let autoReconnect = autoReconnect else { DLog("Error: reconnect called without calling startAutoReconnect"); return false }
        return autoReconnect.reconnect()
    }
    
    public func clearAutoconnectPeripheral() {
        Settings.clearAutoconnectPeripheral()
    }
}
