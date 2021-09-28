//
//  BlePeripheral+FileTransfer.swift
//  Glider
//
//  Created by Antonio García on 13/5/21.
//

import Foundation
import CoreBluetooth

// TODO: rethink sensors architecture. Extensions are too limiting for complex sensors that need to hook to connect/disconnect events or/and maintain an internal state
extension BlePeripheral {
    // Config
    private static let kDebugMessagesEnabled = AppEnvironment.isDebug && true
    
    // Constants
    static let kFileTransferServiceUUID = CBUUID(string: "FEBB")
    private static let kFileTransferVersionCharacteristicUUID = CBUUID(string: "ADAF0100-4669-6C65-5472-616E73666572")
    private static let kFileTransferDataCharacteristicUUID = CBUUID(string: "ADAF0200-4669-6C65-5472-616E73666572")
    private static let kAdafruitFileTransferVersion = 1

    private static let readFileResponseHeaderSize = 16      // (1+1+2+4+4+4+variable)
    private static let deleteFileResponseHeaderSize = 2     // (1+1)

    private func writeFileResponseHeaderSize(protocolVersion: Int) -> Int {
        if protocolVersion >= 3 {
            return 20       // (1+1+2+4+8+4)
        }
        else {
            return 12       // (1+1+2+4+4)
        }
    }
    
    private func makeDirectoryResponseHeaderSize(protocolVersion: Int) -> Int {
        if protocolVersion >= 3 {
            return 16       // (1+1+6+8)
        }
        else {
            return 2       // (1+1)
        }
    }
    
    private func listDirectoryResponseHeaderSize(protocolVersion: Int) -> Int {
        if protocolVersion >= 3 {
            return 28       // (1+1+2+4+4+4+8+4+variable)
        }
        else {
            return 20       // (1+1+2+4+4+4+4+variable)
        }
    }

    // Data types
    struct DirectoryEntry {
        enum EntryType {
            case file(size: Int)
            case directory

            enum CodingKeys: String, CodingKey {
                case file
                case directory
            }
        }

        let name: String
        let type: EntryType
        let modificationDate: Date?

        var isDirectory: Bool {
            switch type {
            case .directory: return true
            default: return false
            }
        }
    }

    private struct FileTransferReadStatus {
        var data = Data()
        var progress: FileTransferClient.ProgressHandler?
        var completion: ((Result<Data, Error>) -> Void)?
    }
    
    private struct FileTransferWriteStatus {
        var data: Data
        var progress: FileTransferClient.ProgressHandler?
        var completion: ((Result<Date?, Error>) -> Void)?
    }

    private struct FileTransferDeleteStatus {
        var completion: ((Result<Void, Error>) -> Void)?
    }

    private struct FileTransferListDirectoryStatus {
        var entries = [DirectoryEntry]()
        var completion: ((Result<[DirectoryEntry]?, Error>) -> Void)?
    }

    private struct FileTransferMakeDirectoryStatus {
        var completion: ((Result<Date?, Error>) -> Void)?
    }

    // MARK: - Errors
    enum FileTransferError: LocalizedError {
        case invalidData
        case unknownCommand
        case invalidInternalState
        case statusFailed(code: Int)
        
        var errorDescription: String? {
            switch self {
            case .invalidData: return "invalid data"
            case .unknownCommand: return "unknown command"
            case .invalidInternalState: return "invalid internal state"
            case .statusFailed(let code): return "status error: \(code)"
            }
        }
    }
    
    // MARK: - Custom properties
    private struct CustomPropertiesKeys {
        static var adafruitFileTransferVersion: Int = 1
        static var adafruitFileTransferDataCharacteristic: CBCharacteristic?
        static var adafruitFileTransferDataProcessingQueue: DataProcessingQueue?
        static var adafruitFileTransferReadStatus: FileTransferReadStatus?
        static var adafruitFileTransferWriteStatus: FileTransferWriteStatus?
        static var adafruitFileTransferDeleteStatus: FileTransferDeleteStatus?
        static var adafruitFileTransferListDirectoryStatus: FileTransferListDirectoryStatus?
        static var adafruitFileTransferMakeDirectoryStatus: FileTransferMakeDirectoryStatus?
    }

    
    private var adafruitFileTransferVersion: Int {
        get {
            return objc_getAssociatedObject(self, &CustomPropertiesKeys.adafruitFileTransferVersion) as! Int
        }
        set {
            objc_setAssociatedObject(self, &CustomPropertiesKeys.adafruitFileTransferVersion, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private var adafruitFileTransferDataCharacteristic: CBCharacteristic? {
        get {
            return objc_getAssociatedObject(self, &CustomPropertiesKeys.adafruitFileTransferDataCharacteristic) as? CBCharacteristic
        }
        set {
            objc_setAssociatedObject(self, &CustomPropertiesKeys.adafruitFileTransferDataCharacteristic, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private var adafruitFileTransferDataProcessingQueue: DataProcessingQueue? {
        get {
            return objc_getAssociatedObject(self, &CustomPropertiesKeys.adafruitFileTransferDataProcessingQueue) as? DataProcessingQueue
        }
        set {
            objc_setAssociatedObject(self, &CustomPropertiesKeys.adafruitFileTransferDataProcessingQueue, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private var adafruitFileTransferReadStatus: FileTransferReadStatus? {
        get {
            return objc_getAssociatedObject(self, &CustomPropertiesKeys.adafruitFileTransferReadStatus) as? FileTransferReadStatus
        }
        set {
            objc_setAssociatedObject(self, &CustomPropertiesKeys.adafruitFileTransferReadStatus, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private var adafruitFileTransferWriteStatus: FileTransferWriteStatus? {
        get {
            return objc_getAssociatedObject(self, &CustomPropertiesKeys.adafruitFileTransferWriteStatus) as? FileTransferWriteStatus
        }
        set {
            objc_setAssociatedObject(self, &CustomPropertiesKeys.adafruitFileTransferWriteStatus, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    private var adafruitFileTransferDeleteStatus: FileTransferDeleteStatus? {
        get {
            return objc_getAssociatedObject(self, &CustomPropertiesKeys.adafruitFileTransferDeleteStatus) as? FileTransferDeleteStatus
        }
        set {
            objc_setAssociatedObject(self, &CustomPropertiesKeys.adafruitFileTransferDeleteStatus, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private var adafruitFileTransferListDirectoryStatus: FileTransferListDirectoryStatus? {
        get {
            return objc_getAssociatedObject(self, &CustomPropertiesKeys.adafruitFileTransferListDirectoryStatus) as? FileTransferListDirectoryStatus
        }
        set {
            objc_setAssociatedObject(self, &CustomPropertiesKeys.adafruitFileTransferListDirectoryStatus, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private var adafruitFileTransferMakeDirectoryStatus: FileTransferMakeDirectoryStatus? {
        get {
            return objc_getAssociatedObject(self, &CustomPropertiesKeys.adafruitFileTransferMakeDirectoryStatus) as? FileTransferMakeDirectoryStatus
        }
        set {
            objc_setAssociatedObject(self, &CustomPropertiesKeys.adafruitFileTransferMakeDirectoryStatus, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    // MARK: - Actions
    func adafruitFileTransferEnable(completion: ((Result<Void, Error>) -> Void)?) {
        
        self.adafruitServiceEnable(serviceUuid: Self.kFileTransferServiceUUID, versionCharacteristicUUID: Self.kFileTransferVersionCharacteristicUUID, mainCharacteristicUuid: Self.kFileTransferDataCharacteristicUUID) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success((version, characteristic)):
                DLog("FileTransfer Protocol v\(version) detected")
                
                self.adafruitFileTransferVersion = version
                self.adafruitFileTransferDataCharacteristic = characteristic
                
                self.adafruitServiceSetNotifyResponse(characteristic: characteristic, responseHandler: self.receiveFileTransferData, completion: completion)
                
            case let .failure(error):
                self.adafruitFileTransferDataCharacteristic = nil
                completion?(.failure(error))
            }
        }
    }
    
    func adafruitFileTransferIsEnabled() -> Bool {
        return adafruitFileTransferDataCharacteristic != nil && adafruitFileTransferDataCharacteristic!.isNotifying
    }
    
    func adafruitFileTransferDisable() {
        // Clear all specific data
        adafruitFileTransferDataCharacteristic = nil
    }
    
    // MARK: - Commands
    func readFile(path: String, progress: FileTransferClient.ProgressHandler?, completion: ((Result<Data, Error>) -> Void)?) {
        self.adafruitFileTransferReadStatus = FileTransferReadStatus(progress: progress, completion: completion)
        
        let mtu = self.maximumWriteValueLength(for: .withoutResponse)
        
        let offset = 0
        let chunkSize = mtu - Self.readFileResponseHeaderSize
        let data = ([UInt8]([0x10, 0x00])).data
            + UInt16(path.utf8.count).littleEndian.data
            + UInt32(offset).littleEndian.data
            + UInt32(chunkSize).littleEndian.data
            + Data(path.utf8)
       
        sendCommand(data: data) { result in
            if case .failure(let error) = result {
                completion?(.failure(error))
            }
        }
    }
    
    func readFileChunk(offset: UInt32, chunkSize: UInt32, completion: ((Result<Void, Error>) -> Void)?) {
        let data = ([UInt8]([0x12, 0x01, 0x00, 0x00])).data
            + UInt32(offset).littleEndian.data
            + UInt32(chunkSize).littleEndian.data
       
        sendCommand(data: data, completion: completion)
    }
    
    func writeFile(path: String, data fileData: Data, progress: FileTransferClient.ProgressHandler?, completion: ((Result<Date?, Error>) -> Void)?) {
        let fileStatus = FileTransferWriteStatus(data: fileData, progress: progress, completion: completion)
        self.adafruitFileTransferWriteStatus = fileStatus
        
        let offset = 0
        let totalSize = fileStatus.data.count
        
        var data = ([UInt8]([0x20, 0x00])).data
            + UInt16(path.utf8.count).littleEndian.data
            + UInt32(offset).littleEndian.data
        
        if adafruitFileTransferVersion >= 3 {       // Version 3 adds currentTime
            let currentTime = UInt64(Date().timeIntervalSince1970 * 1000*1000*1000)
            data += UInt64(currentTime).littleEndian.data
        }
        
        data += UInt32(totalSize).littleEndian.data
            + Data(path.utf8)
        
        sendCommand(data: data) { result in
            if case .failure(let error) = result {
                completion?(.failure(error))
            }
        }
    }

    // Note: uses info stored in adafruitFileTransferFileStatus to resume writing data
    private func writeFileChunk(offset: UInt32, chunkSize: UInt32, completion: ((Result<Void, Error>) -> Void)?) {
        guard let adafruitFileTransferWriteStatus = adafruitFileTransferWriteStatus else { completion?(.failure(FileTransferError.invalidInternalState)); return; }

        let chunkData = adafruitFileTransferWriteStatus.data.subdata(in: Int(offset)..<(Int(offset)+Int(chunkSize)))
    
        let data = ([UInt8]([0x22, 0x01, 0x00, 0x00])).data
            + UInt32(offset).littleEndian.data
            + UInt32(chunkSize).littleEndian.data
            + chunkData
       
        if Self.kDebugMessagesEnabled { DLog("write chunk at offset \(offset) chunkSize: \(chunkSize). message size: \(data.count). mtu: \(self.maximumWriteValueLength(for: .withoutResponse))") }
        //DLog("\t\(String(data: chunkData, encoding: .utf8))")
        sendCommand(data: data, completion: completion)
    }
    
    func deleteFile(path: String, completion: ((Result<Void, Error>) -> Void)?) {
        self.adafruitFileTransferDeleteStatus = FileTransferDeleteStatus(completion: completion)
        
        let data = ([UInt8]([0x30, 0x00])).data
            + UInt16(path.utf8.count).littleEndian.data
            + Data(path.utf8)
       
        sendCommand(data: data) { result in
            if case .failure(let error) = result {
                completion?(.failure(error))
            }
        }
    }
    
    func listDirectory(path: String, completion: ((Result<[DirectoryEntry]?, Error>) -> Void)?) {
        if self.adafruitFileTransferListDirectoryStatus != nil { DLog("Warning: concurrent listDirectory") }
        self.adafruitFileTransferListDirectoryStatus = FileTransferListDirectoryStatus(completion: completion)
                
        let data = ([UInt8]([0x50, 0x00])).data
            + UInt16(path.utf8.count).littleEndian.data
            + Data(path.utf8)
        
        sendCommand(data: data)  { result in
            if case .failure(let error) = result {
                completion?(.failure(error))
            }
        }
    }
    
    func makeDirectory(path: String, completion: ((Result<Date?, Error>) -> Void)?) {
        self.adafruitFileTransferMakeDirectoryStatus = FileTransferMakeDirectoryStatus(completion: completion)
        
        var data = ([UInt8]([0x40, 0x00])).data
            + UInt16(path.utf8.count).littleEndian.data
        
        if adafruitFileTransferVersion >= 3 {       // Version 3 adds currentTime
            let currentTime = UInt64(Date().timeIntervalSince1970 * 1000*1000*1000)
            data += ([UInt8]([0x00, 0x00, 0x00, 0x00])).data        // 4 bytes padding
                + UInt64(currentTime).littleEndian.data
        }
        data += Data(path.utf8)
        
        sendCommand(data: data)  { result in
            if case .failure(let error) = result {
                completion?(.failure(error))
            }
        }
    }

    private func sendCommand(data: Data, completion: ((Result<Void, Error>) -> Void)?) {
        guard let adafruitFileTransferDataCharacteristic = adafruitFileTransferDataCharacteristic else {
            completion?(.failure(PeripheralAdafruitError.invalidCharacteristic))
            return
        }

        self.write(data: data, for: adafruitFileTransferDataCharacteristic, type: .withoutResponse) { error in
            guard error == nil else {
                completion?(.failure(error!))
                return
            }

            completion?(.success(()))
        }
    }
    
    // MARK: - Receive Data
    private func receiveFileTransferData(response: Result<(Data, UUID), Error>) {
        switch response {
        case .success(let (receivedData, peripheralIdentifier)):

            // Init received data
            if adafruitFileTransferDataProcessingQueue == nil {
                adafruitFileTransferDataProcessingQueue = DataProcessingQueue(uuid: peripheralIdentifier)
            }
            
            processDataQueue(receivedData: receivedData)
            
            /*
            var remainingData: Data? = data
            while remainingData != nil && remainingData!.count > 0 {
                remainingData = decodeResponseChunk(data: remainingData!)
            }*/
                                
        case .failure(let error):
            DLog("receiveFileTransferData error: \(error)")
        }
    }
    
    private func processDataQueue(receivedData: Data?) {
        guard let adafruitFileTransferDataProcessingQueue = adafruitFileTransferDataProcessingQueue else { return }
        
        adafruitFileTransferDataProcessingQueue.processQueue(receivedData: receivedData) { remainingData in
            return decodeResponseChunk(data: remainingData)
        }
    }
    
    /// Returns number of bytes processed (they will need to be discarded from the queue)
    // Note: Take into account that data can be a Data-slice
    private func decodeResponseChunk(data: Data) -> Int {
        var bytesProcessed =  0
        guard let command = data.first else { DLog("Error: response invalid data"); return bytesProcessed }
        
        //DLog("received command: \(command)")
        switch command {
        case 0x11:
            bytesProcessed = decodeReadFile(data: data)

        case 0x21:
            bytesProcessed = decodeWriteFile(data: data)

        case 0x31:
            bytesProcessed = decodeDeleteFile(data: data)

        case 0x41:
            bytesProcessed = decodeMakeDirectory(data: data)

        case 0x51:
            bytesProcessed = decodeListDirectory(data: data)

        default:
            DLog("Error: unknown command: \(HexUtils.hexDescription(bytes: [command], prefix: "0x")). Invalidating all received data...")
         
            bytesProcessed = Int.max        // Invalidate all received data
        }

        return bytesProcessed
    }

    private func decodeWriteFile(data: Data) -> Int {
        guard let adafruitFileTransferWriteStatus = adafruitFileTransferWriteStatus else { DLog("Error: write invalid internal status. Invalidating all received data..."); return Int.max }
        let completion = adafruitFileTransferWriteStatus.completion
        
        guard data.count >= writeFileResponseHeaderSize(protocolVersion: adafruitFileTransferVersion) else { return 0 }     // Header has not been fully received yet
        
        var decodingOffset = 1
        let status = data[decodingOffset]
        let isStatusOk = status == 0x01
        
        decodingOffset = 4  // Skip padding
        let offset: UInt32 = data.scanValue(start: decodingOffset, length: 4)
        decodingOffset += 4
        var writeDate: Date? = nil
        if adafruitFileTransferVersion >= 3 {
            let truncatedTime: UInt64 = data.scanValue(start: decodingOffset, length: 8)
            writeDate = Date(timeIntervalSince1970: TimeInterval(truncatedTime)/(1000*1000*1000))
            decodingOffset += 8
        }
        let freeSpace: UInt32 = data.scanValue(start: decodingOffset, length: 4)

        if Self.kDebugMessagesEnabled {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd-HH:mm:ss"
            DLog("write \(isStatusOk ? "ok":"error(\(status))") at offset: \(offset). \(writeDate == nil ? "" : "date: \(dateFormatter.string(from: writeDate!))") freespace: \(freeSpace)")
        }

        guard isStatusOk else {
            self.adafruitFileTransferWriteStatus = nil
            completion?(.failure(FileTransferError.statusFailed(code: Int(status))))
            return Int.max      // invalidate all received data on error
        }
        
        adafruitFileTransferWriteStatus.progress?(Int(offset), Int(adafruitFileTransferWriteStatus.data.count))

        if offset >= adafruitFileTransferWriteStatus.data.count  {
            self.adafruitFileTransferWriteStatus = nil
            completion?(.success((writeDate)))
        }
        else {
            writeFileChunk(offset: offset, chunkSize: freeSpace) { result in
                if case .failure(let error) = result {
                    self.adafruitFileTransferWriteStatus = nil
                    completion?(.failure(error))
                }
            }
        }
        
        return writeFileResponseHeaderSize(protocolVersion: adafruitFileTransferVersion)       // Return processed bytes
    }
    
    /// Returns number of bytes processed
    private func decodeReadFile(data: Data) -> Int {
        guard let adafruitFileTransferReadStatus = adafruitFileTransferReadStatus else { DLog("Error: read invalid internal status. Invalidating all received data..."); return Int.max }
        let completion = adafruitFileTransferReadStatus.completion
        
        guard data.count >= Self.readFileResponseHeaderSize else { return 0 }        // Header has not been fully received yet

        let status = data[1]
        let isStatusOk = status == 0x01
        
        let offset: UInt32 = data.scanValue(start: 4, length: 4)
        let totalLenght: UInt32 = data.scanValue(start: 8, length: 4)
        let chunkSize: UInt32 = data.scanValue(start: 12, length: 4)
        
        guard isStatusOk else {
            if Self.kDebugMessagesEnabled { DLog("read \(isStatusOk ? "ok":"error") at offset \(offset) chunkSize: \(chunkSize) totalLength: \(totalLenght)") }
            self.adafruitFileTransferReadStatus = nil
            completion?(.failure(FileTransferError.statusFailed(code: Int(status))))
            return Int.max      // invalidate all received data on error
        }

        let packetSize = Self.readFileResponseHeaderSize + Int(chunkSize)
        guard data.count >= packetSize else { return 0 }        // The first chunk is still no available wait for it

        if Self.kDebugMessagesEnabled { DLog("read \(isStatusOk ? "ok":"error") at offset \(offset) chunkSize: \(chunkSize) totalLength: \(totalLenght)") }
        let chunkData = data.subdata(in: Self.readFileResponseHeaderSize..<packetSize)
        self.adafruitFileTransferReadStatus!.data.append(chunkData)
        
        adafruitFileTransferReadStatus.progress?(Int(offset + chunkSize), Int(totalLenght))

        if offset + chunkSize < totalLenght {
            let mtu = self.maximumWriteValueLength(for: .withoutResponse)
            let maxChunkLength = mtu - Self.readFileResponseHeaderSize
            readFileChunk(offset: offset + chunkSize, chunkSize: UInt32(maxChunkLength)) { result in
                if case .failure(let error) = result {
                    self.adafruitFileTransferReadStatus = nil
                    completion?(.failure(error))
                }
            }
        }
        else {
            let fileData = self.adafruitFileTransferReadStatus!.data
            self.adafruitFileTransferReadStatus = nil
            completion?(.success(fileData))
        }
        
        return packetSize       // Return processed bytes
    }
    
    private func decodeDeleteFile(data: Data) -> Int {
        guard let adafruitFileTransferDeleteStatus = adafruitFileTransferDeleteStatus else { DLog("Error: delete invalid internal status. Invalidating all received data..."); return Int.max }
        let completion = adafruitFileTransferDeleteStatus.completion

        guard data.count >= Self.deleteFileResponseHeaderSize else { return 0 }      // Header has not been fully received yet

        let status = data[1]
        let isDeleted = status == 0x01
        
        if isDeleted {
            self.adafruitFileTransferDeleteStatus = nil
            completion?(.success(()))
        }
        else {
            completion?(.failure(FileTransferError.statusFailed(code: Int(status))))
        }
        
        return Self.deleteFileResponseHeaderSize        // Return processed bytes
    }
    
    private func decodeMakeDirectory(data: Data) -> Int {
        guard let adafruitFileTransferMakeDirectoryStatus = adafruitFileTransferMakeDirectoryStatus else { DLog("Error: makeDirectory invalid internal status. Invalidating all received data..."); return Int.max }
        let completion = adafruitFileTransferMakeDirectoryStatus.completion

        guard data.count >= makeDirectoryResponseHeaderSize(protocolVersion: adafruitFileTransferVersion) else { return 0 }      // Header has not been fully received yet

        let status = data[1]
        let isCreated = status == 0x01
        
        if isCreated {
            var modificationDate: Date? = nil
            if adafruitFileTransferVersion >= 3 {
                let truncatedTime: UInt64 = data.scanValue(start: 8, length: 8)
                modificationDate = Date(timeIntervalSince1970: TimeInterval(truncatedTime)/(1000*1000*1000))
            }
            
            self.adafruitFileTransferMakeDirectoryStatus = nil
            completion?(.success(modificationDate))
        }
        else {
            completion?(.failure(FileTransferError.statusFailed(code: Int(status))))
        }
        
        return makeDirectoryResponseHeaderSize(protocolVersion: adafruitFileTransferVersion)  // Return processed bytes
    }
    
    private func decodeListDirectory(data: Data) -> Int {
        guard let adafruitFileTransferListDirectoryStatus = adafruitFileTransferListDirectoryStatus else {
            DLog("Error: list invalid internal status. Invalidating all received data..."); return Int.max }
        let completion = adafruitFileTransferListDirectoryStatus.completion
        
        let headerSize = listDirectoryResponseHeaderSize(protocolVersion: adafruitFileTransferVersion)
        guard data.count >= headerSize else { return 0 }       // Header has not been fully received yet
        var packetSize = headerSize      // Chunk size processed (can be less that data.count if several chunks are included in the data)
        
        let directoryExists = data[data.startIndex + 1] == 0x1
        if directoryExists, data.count >= headerSize {
            let entryCount: UInt32 = data.scanValue(start: 8, length: 4)
            if entryCount == 0  {             // Empty directory
                self.adafruitFileTransferListDirectoryStatus = nil
                completion?(.success([]))
            }
            else {
                let pathLength: UInt16 = data.scanValue(start: 2, length: 2)
                let entryIndex: UInt32 = data.scanValue(start: 4, length: 4)
                
                if entryIndex >= entryCount  {     // Finished. Return entries
                    let entries = self.adafruitFileTransferListDirectoryStatus!.entries
                    self.adafruitFileTransferListDirectoryStatus = nil
                    if Self.kDebugMessagesEnabled { DLog("list: finished") }
                    completion?(.success(entries))
                }
                else {
                    let flags: UInt32 = data.scanValue(start: 12, length: 4)
                    let isDirectory = flags & 0x1 == 1
                    
                    var decodingOffset = 16
                    var modificationDate: Date? = nil
                    if adafruitFileTransferVersion >= 3 {
                        let truncatedTime: UInt64 = data.scanValue(start: decodingOffset, length: 8)
                        modificationDate = Date(timeIntervalSince1970: TimeInterval(truncatedTime)/(1000*1000*1000))
                        decodingOffset += 8
                    }
                    
                    let fileSize: UInt32 = data.scanValue(start: decodingOffset, length: 4)        // Ignore for directories
                    
                    guard data.count >= headerSize + Int(pathLength) else { return 0 } // Path is still no available wait for it
                    
                    if pathLength > 0, let path = String(data: data[(data.startIndex + headerSize)..<(data.startIndex + headerSize + Int(pathLength))], encoding: .utf8) {
                        packetSize += Int(pathLength)        // chunk includes the variable length path, so add it
                        
                        if Self.kDebugMessagesEnabled {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy/MM/dd-HH:mm:ss"
                            DLog("list: \(entryIndex+1)/\(entryCount) \(isDirectory ? "directory":"file size: \(fileSize) bytes") \(modificationDate == nil ? "" : "date: \(dateFormatter.string(from: modificationDate!))"), path: '/\(path)'")
                        }
                        let entry = DirectoryEntry(name: path, type: isDirectory ? .directory : .file(size: Int(fileSize)), modificationDate: modificationDate)
                        
                        // Add entry
                        self.adafruitFileTransferListDirectoryStatus?.entries.append(entry)
                    }
                    else {
                        self.adafruitFileTransferListDirectoryStatus = nil
                        completion?(.failure(FileTransferError.invalidData))
                    }
                }
            }
        }
        else {
            self.adafruitFileTransferListDirectoryStatus = nil
            completion?(.success(nil))      // nil means directory does not exist
        }
        
        return packetSize
    }
}

// MARK: - Codable extension for DirectoryEntry
extension BlePeripheral.DirectoryEntry.EntryType: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .directory:
            try container.encodeNil(forKey: .directory)
        case .file(let size):
            try container.encode(size, forKey: .file)
        }
    }
}

extension BlePeripheral.DirectoryEntry.EntryType: Decodable {
    init(from decoder: Decoder) throws {
        if let size = try? decoder.singleValueContainer().decode(Int.self) {
            self = .file(size: size)
        }
        else {
            self = .directory
        }
    }
}

extension BlePeripheral.DirectoryEntry: Codable { }
