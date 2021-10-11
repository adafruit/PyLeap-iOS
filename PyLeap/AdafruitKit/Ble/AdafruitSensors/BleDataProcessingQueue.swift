//
//  BleDataProcessingQueue.swift
//  Glider
//
//  Created by Antonio García on 4/6/21.
//

import Foundation

class DataProcessingQueue {
    private var data = Data()
    private var dataSemaphore = DispatchSemaphore(value: 1)
    
    private var uuid: UUID
    
    init(uuid: UUID) {
        self.uuid = uuid
    }
    
    // MARK: - BLE Notifications
    private weak var didConnectToPeripheralObserver: NSObjectProtocol?
    private weak var didDisconnectFromPeripheralObserver: NSObjectProtocol?

    private func registerNotifications(enabled: Bool) {
        let notificationCenter = NotificationCenter.default
        if enabled {
            didConnectToPeripheralObserver = notificationCenter.addObserver(forName: .didConnectToPeripheral, object: nil, queue: .main, using: {[weak self] notification in self?.didConnectToPeripheral(notification: notification)})
            didDisconnectFromPeripheralObserver = notificationCenter.addObserver(forName: .didDisconnectFromPeripheral, object: nil, queue: .main, using: {[weak self] notification in self?.didDisconnectFromPeripheral(notification: notification)})

        } else {
            if let didConnectToPeripheralObserver = didConnectToPeripheralObserver {notificationCenter.removeObserver(didConnectToPeripheralObserver)}
            if let didDisconnectFromPeripheralObserver = didDisconnectFromPeripheralObserver {notificationCenter.removeObserver(didDisconnectFromPeripheralObserver)}
        }
    }

    private func didConnectToPeripheral(notification: Notification) {
        guard let identifier = notification.userInfo?[BleManager.NotificationUserInfoKey.uuid.rawValue] as? UUID else { return }
        guard identifier == uuid else { return }
        
        // Clear cached data
        data.removeAll()
    }

    private func didDisconnectFromPeripheral(notification: Notification) {
        guard let identifier = notification.userInfo?[BleManager.NotificationUserInfoKey.uuid.rawValue] as? UUID else { return }
        guard identifier == uuid else { return }

        // Clean data on disconnect
        data.removeAll()

        dataSemaphore.signal()        // Force signal if it was waiting
    }
    
    func processQueue(receivedData: Data?, processingHandler: ((Data)->Int)) {
        // Don't append more data, till the delegate has finished processing it
        dataSemaphore.wait()
        
        // Append received data
        if let receivedData = receivedData {
            data.append(receivedData)
            //DLog("Data received. Queue size: \(data.count) bytes")
        }
        
        // Process chunks
        processQueuedChunks(processingHandler: processingHandler)
        
        // Ready to receive more data
        dataSemaphore.signal()
    }
    
    // Important: this method changes "data", so it should be used only when the semaphore is blocking concurrent access
    private func processQueuedChunks(processingHandler: ((Data)->Int)) {
        // Process chunk
        let processedDataCount = processingHandler(data)
        
        // Remove processed bytes
        if processedDataCount > 0 {
            data = Data(data.dropFirst(processedDataCount))
        }
        else {
            //DLog("Queue size: \(data.count) bytes. Waiting for more data to process packet...")
        }
        
        // If there is still unprocessed chunks in the queue, process the next one
        let isStillUnprocessedDataInQueue = processedDataCount > 0  && data.count > 0
        if  isStillUnprocessedDataInQueue {
            //DLog("Unprocessed data still in queue (\(data.count) bytes). Try to process next packet")
            processQueuedChunks(processingHandler: processingHandler)
        }
        else if data.isEmpty {
            //DLog("Data queue empty")
        }
    }
    
}
