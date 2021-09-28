//
//  FileProviderExtension.swift
//  GliderFileProvider
//
//  Created by Antonio García on 26/6/21.
//

import FileProvider

class FileProviderExtension: NSFileProviderExtension {
    // Data
    private let gliderClient = GliderClient.shared
    private var fileManager = FileManager()
    private var backgroundQueue = DispatchQueue.global(qos: .utility)
    
    // MARK: -
    override init() {
        super.init()
        
        DLog("FileProviderExtension init")
      //  LogManager.shared.load()
        
        if AppEnvironment.isDebug && false {
            DLog("Debug: force resync")
            FileProviderUtils.signalFileProviderChanges()
        }
    }
    
    deinit {
        DLog("FileProviderExtension deinit")
        LogManager.shared.save()
    }
    
    /*
     private weak var extensionDidBecomeActiveObserver: NSObjectProtocol?
     private func registerNotifications(enabled: Bool) {
     if enabled {
     extensionDidBecomeActiveObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSExtensionHostDidBecomeActive, object: nil, queue: .main, using: { notification in
     
     })
     
     } else {
     if let extensionDidBecomeActiveObserver = extensionDidBecomeActiveObserver {NotificationCenter.default.removeObserver(extensionDidBecomeActiveObserver)}
     
     }
     }*/
    
    // MARK: - Mandatory
    override func item(for identifier: NSFileProviderItemIdentifier) throws -> NSFileProviderItem {
        //DLog("item: \(identifier.rawValue)")
        guard let item = gliderClient.metadataCache.fileProviderItem(for: identifier) else {
            DLog("Error undefined item for identifier: \(identifier)")
            throw GliderClient.GliderError.undefinedFileProviderItem(identifier: identifier.rawValue)
        }
        return item
    }
    
    override func urlForItem(withPersistentIdentifier identifier: NSFileProviderItemIdentifier) -> URL? {
        //DLog("urlForItem: \(identifier.rawValue)")
        
        // resolve the given identifier to a file on disk
        guard let item = try? item(for: identifier) as? FileProviderItem else {
            return nil
        }
        
        let partialPath = item.fullPath.deletingPrefix(FileTransferPathUtils.pathSeparator)
        let url = NSFileProviderManager.default.documentStorageURL.appendingPathComponent(partialPath, isDirectory: item.entry.isDirectory)
        //DLog("urlForItem at: \(identifier.rawValue) -> \(url.absoluteString)")
        return url
    }
    
    override func persistentIdentifierForItem(at url: URL) -> NSFileProviderItemIdentifier? {
        
        var pathComponents = url.pathComponents
        
        // Remove all common elements with the FileProvider documents storage to get the specific components used as identifier
        let documentsStorageComponents = NSFileProviderManager.default.documentStorageURL.pathComponents
        for component in documentsStorageComponents {
            if component == pathComponents.first {
                pathComponents.removeFirst()
            }
        }
        
        let fullPath = FileTransferPathUtils.pathSeparator + pathComponents.joined(separator: FileTransferPathUtils.pathSeparator)
        let persistentIdentifier = NSFileProviderItemIdentifier(fullPath)
        //DLog("persistentIdentifierForItem at: \(url.absoluteString) -> \(persistentIdentifier.rawValue)")
        return persistentIdentifier
    }
    
    override func providePlaceholder(at url: URL, completionHandler: @escaping (Error?) -> Void) {
        // DLog("providePlaceholder at: \(url.absoluteString)")
        
        guard let identifier = persistentIdentifierForItem(at: url) else {
            completionHandler(NSFileProviderError(.noSuchItem))
            return
        }
        
        do {
            let fileProviderItem = try item(for: identifier)
            let placeholderURL = NSFileProviderManager.placeholderURL(for: url)
            try NSFileProviderManager.writePlaceholder(at: placeholderURL, withMetadata: fileProviderItem)
            completionHandler(nil)
        } catch let error {
            DLog("providePlaceholder error: \(error)")
            completionHandler(error)
        }
    }
    
    override func startProvidingItem(at url: URL, completionHandler: @escaping ((_ error: Error?) -> Void)) {
        DLog("startProvidingItem at: \(url.absoluteString)")
        
        /*
         Should ensure that the actual file is in the position returned by URLForItemWithIdentifier:, then call the completion handler
         
         This is one of the main entry points of the file provider. We need to check whether the file already exists on disk,
         whether we know of a more recent version of the file, and implement a policy for these cases. Pseudocode:
         
         if !fileOnDisk {
         downloadRemoteFile()
         callCompletion(downloadErrorOrNil)
         } else if fileIsCurrent {
         callCompletion(nil)
         } else {
         if localFileHasChanges {
         // in this case, a version of the file is on disk, but we know of a more recent version
         // we need to implement a strategy to resolve this conflict
         moveLocalFileAside()
         scheduleUploadOfLocalFile()
         downloadRemoteFile()
         callCompletion(downloadErrorOrNil)
         } else {
         downloadRemoteFile()
         callCompletion(downloadErrorOrNil)
         }
         }
         */
        
        guard let identifier = persistentIdentifierForItem(at: url) else {
            DLog("startProvidingItem. Unknown identifier")
            completionHandler(NSFileProviderError(.noSuchItem))
            return
        }
        
        guard let fileProviderItem = try? item(for: identifier) as? FileProviderItem else {
            DLog("startProvidingItem. Unknown fileProviderItem")
            completionHandler(NSFileProviderError(.noSuchItem))
            return
        }
        
        let isFileOnDisk = fileManager.fileExists(atPath: url.path)
        if !isFileOnDisk {
            // If no file on disk, donwload from peripheral
            DLog("File \(fileProviderItem.fullPath) does not exists locally. Get from peripheral")
            gliderClient.readFile(path: fileProviderItem.fullPath) { [weak self]  result in
                guard let self = self else { return }
                
                switch result {
                case .success(let data):
                    do {
                        // Write data locally
                        try self.writeReceivedFileLocally(url: url, fileProviderItem: fileProviderItem, receivedData: data)
                        
                        // Finished sync
                        DLog("syncFile \(fileProviderItem.fullPath) success")
                        completionHandler(nil)
                    }
                    catch(let error) {
                        DLog("syncFile \(fileProviderItem.fullPath) write to disk error: \(error)")
                        completionHandler(error)
                    }
                    
                case .failure(let error):
                    DLog("syncFile \(fileProviderItem.fullPath) error: \(error)")
                    completionHandler(NSFileProviderError(.serverUnreachable))
                }
            }
            
        }
        else {
            // Warning: if the local file has changes, and the remote file chas changes too, there is no way to determine which ones are the last ones without the remote file modification date. So we always prioritize local changes over remote changes
            
            if hasLocalChanges(url: url) {
                // The local files has changes, so upload it to the peripheral
                DLog("File \(fileProviderItem.fullPath) has local changes. Send to peripheral")
                
                uploadFile(localURL: url, item: fileProviderItem, completionHandler: completionHandler)
            }
            else {
                checkIfRemoteFileChangedAndDownload(url: url, fileProviderItem: fileProviderItem) { result in
                    
                    switch result {
                    case .success(let isRemoteFileChanged):
                        if isRemoteFileChanged {
                            DLog("File \(fileProviderItem.fullPath) has remote changes. Get from peripheral")
                        }
                        completionHandler(nil)
                        
                    case .failure(let fileProviderError):
                        completionHandler(fileProviderError)
                    }
                }
            }
        }
        
        //completionHandler(NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
    }
    
    override func itemChanged(at url: URL) {
        DLog("itemChanged at: \(url.absoluteString)")
        
        // Called at some point after the file has changed; the provider may then trigger an upload
        
        /*
         - mark file at <url> as needing an update in the model
         - if there are existing NSURLSessionTasks uploading this file, cancel them
         - create a fresh background NSURLSessionTask and schedule it to upload the current modifications
         - register the NSURLSessionTask with NSFileProviderManager to provide progress updates
         */
        
        guard let identifier = persistentIdentifierForItem(at: url) else {
            DLog("itemChanged. Unknown identifier")
            return
        }
        
        guard let fileProviderItem = try? item(for: identifier) as? FileProviderItem else {
            DLog("itemChanged. Unknown fileProviderItem")
            return
        }
        
        // TODO: check if the file was already being uploaded int the queue and cancel it
        // Schedule upload in background
        backgroundQueue.async {
            self.uploadFile(localURL: url, item: fileProviderItem) { error in
                if let error = error {
                    DLog("itemChanged upload \(fileProviderItem.fullPath) error: \(error.localizedDescription)")
                }
                else {
                    DLog("itemChanged uploaded \(fileProviderItem.fullPath)")
                }
            }
        }
    }
    
    override func stopProvidingItem(at url: URL) {
        DLog("stopProvidingItem at: \(url.absoluteString)")
        
        // Called after the last claim to the file has been released. At this point, it is safe for the file provider to remove the content file.
        // Care should be taken that the corresponding placeholder file stays behind after the content file has been deleted.
        
        // TODO: look up whether the file has local changes
        let fileHasLocalChanges = hasLocalChanges(url: url)
        
        if !fileHasLocalChanges {
            // remove the existing file to free up space
            do {
                _ = try FileManager.default.removeItem(at: url)
            } catch(let error) {
                // Handle error
                DLog("error deleting local file: \(url.absoluteString). Error: \(error.localizedDescription)")
            }
            
            // write out a placeholder to facilitate future property lookups
            self.providePlaceholder(at: url, completionHandler: { error in
                // TODO: handle any error, do any necessary cleanup
                DLog("error providing placeholder for deleted file: \(url.absoluteString). Error: \(error?.localizedDescription ?? "nil")")
            })
        }
    }
    
    
    // MARK: - Actions
    
    /* implement the actions for items here
     each of the actions follows the same pattern:
     - make a note of the change in the local model
     - schedule a server request as a background task to inform the server of the change
     - call the completion block with the modified item in its post-modification state
     */
    
    // MARK: - Enumeration
    
    override func enumerator(for containerItemIdentifier: NSFileProviderItemIdentifier) throws -> NSFileProviderEnumerator {
        let maybeEnumerator: NSFileProviderEnumerator? = nil
        if (containerItemIdentifier == NSFileProviderItemIdentifier.rootContainer) {
            // instantiate an enumerator for the container root
            DLog("enumerator for rootContainer")
            return FileProviderEnumerator(gliderClient: gliderClient, path: FileTransferPathUtils.rootDirectory, filename: nil )
            
        } else if (containerItemIdentifier == NSFileProviderItemIdentifier.workingSet) {
            // TODO: instantiate an enumerator for the working set
            DLog("TODO: enumerator for workingSet")
            
            
        } else {
            // determine if the item is a directory or a file
            // - for a directory, instantiate an enumerator of its subitems
            // - for a file, instantiate an enumerator that observes changes to the file
            
            if let item = try item(for: containerItemIdentifier) as? FileProviderItem  {
                if item.entry.isDirectory {
                    DLog("enumerator for directory: \(containerItemIdentifier.rawValue)")
                    let path = item.path + item.entry.name + FileTransferPathUtils.pathSeparator
                    return FileProviderEnumerator(gliderClient: gliderClient, path: path, filename: nil )
                }
                else {
                    DLog("enumerator for file: \(containerItemIdentifier.rawValue)")
                    return FileProviderEnumerator(gliderClient: gliderClient, path: item.path, filename: item.filename )
                    
                }
            }
        }
        guard let enumerator = maybeEnumerator else {
            DLog("TODO: enumerator")
            throw NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:])
        }
        return enumerator
    }
    
    
    // MARK: - Optional
    override func createDirectory(withName directoryName: String, inParentItemIdentifier parentItemIdentifier: NSFileProviderItemIdentifier, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        DLog("createDirectory: '\(directoryName)' at \(parentItemIdentifier.rawValue)")
        
        guard let parentFileProviderItem = try? item(for: parentItemIdentifier) as? FileProviderItem else {
            completionHandler(nil, NSFileProviderError(.noSuchItem))
            return
        }
        
        // Create fileProviderItem
        let fileProviderItem = FileProviderItem(path: parentFileProviderItem.fullPath, entry: BlePeripheral.DirectoryEntry(name: directoryName, type: .directory, modificationDate: Date()))
        
        createDirectoryLocally(fileProviderItem: fileProviderItem) { result in
            switch result {
            case .success:
                
                // Schedule create in background
                backgroundQueue.async {
                    self.gliderClient.makeDirectory(path: fileProviderItem.fullPath) { result in
                        switch result {
                        case .success(let date):
                            DLog("createDirectory '\(fileProviderItem.fullPath)' result successful")
                            if let date = date {
                                fileProviderItem.lastUpdate = date
                            }
                            self.gliderClient.metadataCache.setFileProviderItem(item: fileProviderItem)
                            
                        case .failure(let error):
                            DLog("createDirectory error: \(error)")
                            
                            if let fileTransferError = error as? BlePeripheral.FileTransferError, case .statusFailed = fileTransferError {
                                DLog("createDirectory signal parent enumerator")
                                NSFileProviderManager.default.signalEnumerator(for: fileProviderItem.parentItemIdentifier) { error in
                                    DLog("createDirectory parent enumerator signal finished")
                                }
                            }
                        }
                    }
                }
                
                // Return inmediately (before the directory is even created)
                completionHandler(fileProviderItem, nil)
                
            case .failure(let error):
                DLog("Error creating local directory: \(fileProviderItem.fullPath). Error: \(error.localizedDescription)")
                completionHandler(nil, error)
            }
        }
    }
    
    override func deleteItem(withIdentifier itemIdentifier: NSFileProviderItemIdentifier, completionHandler: @escaping (Error?) -> Void) {
        
        guard let fileProviderItem = try? item(for: itemIdentifier) as? FileProviderItem else {
            DLog("deleteItem. Unknown fileProviderItem")
            completionHandler(NSFileProviderError(.noSuchItem))
            return
        }
        
        deleteItemLocally(itemIdentifier: itemIdentifier) { result in
            // Note: .failure not checked to avoid irresoluble situations when in an inconsist internal state (i.e. item exists in metadata but not locally)
            
            // Schedule delete in background
            backgroundQueue.async {
                self.gliderClient.deleteFile(path: fileProviderItem.fullPath) { result in
                    switch result {
                    case .success:
                        DLog("deleteFile '\(fileProviderItem.fullPath)' result successful")
                        
                    case .failure(let error):
                        DLog("deleteFile error: \(error)")
                        
                        if let fileTransferError = error as? BlePeripheral.FileTransferError, case .statusFailed = fileTransferError {
                            DLog("createDirectory signal parent enumerator")
                            NSFileProviderManager.default.signalEnumerator(for: fileProviderItem.parentItemIdentifier) { error in
                                DLog("createDirectory parent enumerator signal finished")
                            }
                        }
                    }
                }
            }
            
            // Return inmediately (before the file is deleted)
            completionHandler(nil)
        }
    }
    
    override func importDocument(at fileURL: URL, toParentItemIdentifier parentItemIdentifier: NSFileProviderItemIdentifier, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        
        DLog("importDocument at: \(fileURL.absoluteString) to parent: \(parentItemIdentifier.rawValue)")
        guard let parentFileProviderItem = try? item(for: parentItemIdentifier) as? FileProviderItem else {
            completionHandler(nil, NSFileProviderError(.noSuchItem))
            return
        }
        
        guard fileURL.startAccessingSecurityScopedResource() else { DLog("Error accesing security scoped resource for: \(fileURL.absoluteString)"); return }
        
        do {
            let fileAttributes = try fileURL.resourceValues(forKeys:[.nameKey, .creationDateKey, .contentModificationDateKey])
            let data = try Data(contentsOf: fileURL)
            let completeFilename = fileAttributes.name ?? "imported"            // Default name for unknown imported documents
            let fileExtension = URL(fileURLWithPath: completeFilename).pathExtension
            let fileName = (completeFilename as NSString).deletingPathExtension
            
            // Check if the filename already exists and change it to prevent overwrite
            var disambiguationIndex = 1
            var disambiguationFilename = completeFilename
            while self.gliderClient.metadataCache.fileProviderItem(for: NSFileProviderItemIdentifier(parentFileProviderItem.fullPath + disambiguationFilename)) != nil {
                
                disambiguationIndex += 1
                disambiguationFilename = "\(fileName) \(disambiguationIndex).\(fileExtension)"
            }
            
            // Create fileProviderItem
            let fileProviderItem = FileProviderItem(path: parentFileProviderItem.fullPath, entry: BlePeripheral.DirectoryEntry(name: disambiguationFilename, type: .file(size: data.count), modificationDate: Date()))
            if let creationDate = fileAttributes.creationDate {
                fileProviderItem.creation = creationDate
            }
            if let lastUpdate = fileAttributes.contentModificationDate {
                fileProviderItem.lastUpdate = lastUpdate
            }
            self.gliderClient.metadataCache.setFileProviderItem(item: fileProviderItem)     // Set before  urlForItem
            
            guard let localUrl = self.urlForItem(withPersistentIdentifier: fileProviderItem.itemIdentifier) else { DLog("Error obtaining local url for imported document \(fileURL.absoluteString)"); return }
            
            // Write data locally
            try data.write(to: localUrl, options: .atomic)
            
            // Schedule updload in background
            backgroundQueue.async {
                
                self.gliderClient.writeFile(path: fileProviderItem.fullPath, data: data) { result in
                    switch result {
                    case .success:
                        DLog("importDocument '\(fileProviderItem.fullPath)' successful. (\(data.count) bytes")
                    case .failure(let error):
                        DLog("importDocument error: \(error)")
                        NSFileProviderManager.default.signalEnumerator(for: fileProviderItem.parentItemIdentifier) { error in
                            DLog("importDocument parent enumerator signal finished. Error?: \(error?.localizedDescription ?? "<nil>")")
                        }
                    }
                }
            }
            
            completionHandler(fileProviderItem, nil)
        } catch (let error) {
            DLog("Error importing data from fileURL: \(fileURL.absoluteString). Error: \(error.localizedDescription)")
            completionHandler(nil, error)
        }
        
        fileURL.stopAccessingSecurityScopedResource()
    }
    
    override func renameItem(withIdentifier itemIdentifier: NSFileProviderItemIdentifier, toName itemName: String, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        
        DLog("renameItem: \(itemIdentifier.rawValue) toName: \(itemName)")
        
        guard let fileProviderItem = try? item(for: itemIdentifier) as? FileProviderItem else {
            DLog("renameItem. Unknown fileProviderItem")
            completionHandler(nil, NSFileProviderError(.noSuchItem))
            return
        }
        
        // Only renaming directories is supported at the moment
        guard fileProviderItem.entry.isDirectory else {
            completionHandler(nil, NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError))
            return
        }
        
        // Rename fileproviderItem
        let renamedEntry = BlePeripheral.DirectoryEntry(name: itemName, type: fileProviderItem.entry.type, modificationDate: Date())
        let renamedItem = FileProviderItem(path: fileProviderItem.path, entry: renamedEntry)
        renamedItem.creation = fileProviderItem.creation        // Maintain creation date
        
        createDirectoryLocally(fileProviderItem: renamedItem) { result in
            switch result {
            case .success:
                
                deleteItemLocally(itemIdentifier: itemIdentifier) { result in
                    // Note: .failure not checked to avoid irresoluble situations when in an inconsist internal state (i.e. item exists in metadata but not locally)
                    
                    // Schedule delete in background
                    backgroundQueue.async {
                        
                        self.gliderClient.makeDirectory(path: renamedItem.fullPath) { result in
                            switch result {
                            case .success(_ /*let date*/):
                                DLog("rename step 1: createDirectory '\(renamedItem.fullPath)' result successful")
                                
                                self.gliderClient.deleteFile(path: fileProviderItem.fullPath) { result in
                                    switch result {
                                    case .success:
                                        DLog("rename step 2: deleteFile \(fileProviderItem.fullPath) result successful")
                                        
                                        
                                    case .failure(let error):
                                        DLog("rename step 2: deleteFile error: \(error)")
                                        
                                        if let fileTransferError = error as? BlePeripheral.FileTransferError, case .statusFailed = fileTransferError {
                                            DLog("rename step 2 signal parent enumerator")
                                            NSFileProviderManager.default.signalEnumerator(for: fileProviderItem.parentItemIdentifier) { error in
                                                DLog("rename step 2 parent enumerator signal finished")
                                            }
                                        }
                                        
                                    }
                                }
                                
                            case .failure(let error):
                                DLog("rename step 1: createDirectory error: \(error)")
                                
                                if let fileTransferError = error as? BlePeripheral.FileTransferError, case .statusFailed = fileTransferError {
                                    DLog("rename step 1 signal parent enumerator")
                                    NSFileProviderManager.default.signalEnumerator(for: fileProviderItem.parentItemIdentifier) { error in
                                        DLog("rename step 1 parent enumerator signal finished")
                                    }
                                }
                            }
                        }
                    }
                    
                    // Return inmediately (before the file is deleted)
                    completionHandler(renamedItem, nil)
                }
                
            case .failure(let error):
                DLog("Error creating local directory: \(fileProviderItem.fullPath). Error: \(error.localizedDescription)")
                completionHandler(nil, error)
            }
        }
    }
    
    override func reparentItem(withIdentifier itemIdentifier: NSFileProviderItemIdentifier, toParentItemWithIdentifier parentItemIdentifier: NSFileProviderItemIdentifier, newName: String?, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        DLog("reparentItem: \(itemIdentifier.rawValue) toParent: \(parentItemIdentifier.rawValue) with newName: \(newName ?? "<nil>")")
        
        completionHandler(nil, NSFileProviderError(.noSuchItem))
    }
    
    override func setLastUsedDate(_ lastUsedDate: Date?, forItemIdentifier itemIdentifier: NSFileProviderItemIdentifier, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        
        DLog("setLastUsedDate: \(itemIdentifier.rawValue) to \(String(describing: lastUsedDate))")
        guard let fileProviderItem = try? item(for: itemIdentifier) as? FileProviderItem else {
            completionHandler(nil, NSFileProviderError(.noSuchItem))
            return
        }
        
        // Save sync date
        fileProviderItem.lastUpdate = lastUsedDate ?? fileProviderItem.creation     // If no lastUsedDate is provided, we set the creation date
        self.gliderClient.metadataCache.setFileProviderItem(item: fileProviderItem)
        
        // Upload lastUpdate to the peripheral
        // TODO: there is no API available on the FileTransfer protocol to do it
        
        /*
         NSFileProviderManager.default.signalEnumerator(for: itemIdentifier) { error in
         DLog("signalFileProviderChanges for \(itemIdentifier.rawValue) completed. Error?: \(String(describing: error))")
         }*/
        
        completionHandler(fileProviderItem, nil)
    }
    
    // MARK: - Utils
    func fileModificationDate(url: URL) -> Date? {
        do {
            let attr = try fileManager.attributesOfItem(atPath: url.path)
            return attr[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }
    
    private func writeReceivedFileLocally(url: URL, fileProviderItem: FileProviderItem, receivedData: Data) throws {
        try receivedData.write(to: url, options: .atomic)
        
        // Update metadata with the date used on the modification date on the written file. It will be used to keep track of the local changes. If the metadata stored data is older than the file's modification date, then the file has been changed locally and needs to be updated on the peripheral
        let modificationDate = self.fileModificationDate(url: url)
        fileProviderItem.lastUpdate = modificationDate ?? Date()
        self.gliderClient.metadataCache.setFileProviderItem(item: fileProviderItem)
    }
    
    private func checkIfRemoteFileChangedAndDownload(url: URL, fileProviderItem: FileProviderItem, completion: @escaping((Result<Bool, Error>) -> Void) ) {
        // WARNING: major perfomance impact!!
        // TODO: this should only check the remote modification file, but the CircuitPython File Protocol used doesn't support it yet, so we have to download the whole file to check if it has changed
        
        do {
            let localData = try Data(contentsOf: url)
            
            // Retrieve remote file and compare with local data
            gliderClient.readFile(path: fileProviderItem.fullPath) { [weak self]  result in
                guard let self = self else { return }
                
                switch result {
                case .success(let data):
                    let isRemoFileChanged = data != localData
                    
                    if isRemoFileChanged {
                        do {
                            try self.writeReceivedFileLocally(url: url, fileProviderItem: fileProviderItem, receivedData: data)
                            completion(.success(true))
                        }
                        catch(let error) {
                            DLog("isRemoteFileChanged \(fileProviderItem.fullPath) error: \(error)")
                            completion(.failure(NSFileProviderError(.serverUnreachable)))
                        }
                    }
                    else {
                        completion(.success(false))
                    }
                    
                case .failure(let error):
                    DLog("isRemoteFileChanged \(fileProviderItem.fullPath) error: \(error)")
                    completion(.failure(error))
                }
            }
        }
        catch {
            completion(.failure(NSFileProviderError(.noSuchItem)))
        }
    }
    
    private func createDirectoryLocally(fileProviderItem: FileProviderItem, completion: (Result<Void, Error>)->Void) {
        // Update metadata
        self.gliderClient.metadataCache.setFileProviderItem(item: fileProviderItem)
        
        guard let localUrl = self.urlForItem(withPersistentIdentifier: fileProviderItem.itemIdentifier) else { DLog("Error obtaining local url for createDirectory: \(fileProviderItem.fullPath)"); return }
        
        guard !fileManager.fileExists(atPath: localUrl.path) else { completion(.success(())); return }
        
        do {
            try fileManager.createDirectory(at: localUrl, withIntermediateDirectories: true, attributes: [:])
            completion(.success(()))
        } catch(let error) {
            self.gliderClient.metadataCache.deleteFileProviderItem(identifier: fileProviderItem.itemIdentifier)     // Undo creation
            DLog("Error creating local directory: \(fileProviderItem.fullPath). Error: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    private func deleteItemLocally(itemIdentifier: NSFileProviderItemIdentifier, completion: (Result<Void, Error>)->Void) {
        guard let localUrl = self.urlForItem(withPersistentIdentifier: itemIdentifier) else { DLog("Error obtaining local url for deleteItem: \(itemIdentifier.rawValue)"); return }
        
        // Update metadata (before real delete)
        self.gliderClient.metadataCache.deleteFileProviderItem(identifier: itemIdentifier)
        
        // Delete local directory
        try? fileManager.removeItem(at: localUrl)
        completion(.success(()))
        
        /* Note: commented to always return delete successful in case we are in an inconsistent state
         let isLocalItemDeleted: Bool
         do {
         try fileManager.removeItem(atPath: fileProviderItem.fullPath)
         isLocalItemDeleted = true
         } catch(let error) {
         DLog("Error deleting local item: \(fileProviderItem.fullPath). Error: \(error.localizedDescription)")
         isLocalItemDeleted = false
         completionHandler(error)
         }
         */
    }
    
    private func uploadFile(localURL url: URL, item fileProviderItem: FileProviderItem, completionHandler: @escaping ((_ error: Error?) -> Void)) {
        do {
            let localData = try Data(contentsOf: url)
            gliderClient.writeFile(path: fileProviderItem.fullPath, data: localData) { result in
                switch result {
                case .success:
                    // Save sync date
                    let localModificationDate = self.fileModificationDate(url: url)
                    fileProviderItem.lastUpdate = localModificationDate ?? Date()
                    self.gliderClient.metadataCache.setFileProviderItem(item: fileProviderItem)
                    
                    // Finished
                    completionHandler(nil)
                    
                case .failure:
                    completionHandler(NSFileProviderError(.serverUnreachable))
                }
            }
        }
        catch(let error) {
            DLog("syncFile \(fileProviderItem.fullPath) load from disk error: \(error)")
            completionHandler(NSFileProviderError(.noSuchItem))
        }
    }
    
    private func hasLocalChanges(url: URL) -> Bool {
        guard let identifier = persistentIdentifierForItem(at: url) else { return false }
        guard let fileProviderItem = try? item(for: identifier) as? FileProviderItem else { return false }
        
        let localModificationDate = self.fileModificationDate(url: url)
        let localFileHasChanges = (localModificationDate ?? Date.distantPast) > fileProviderItem.lastUpdate
        return localFileHasChanges
    }
}
