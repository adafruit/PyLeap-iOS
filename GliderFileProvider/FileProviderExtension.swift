//
//  FileProviderExtension.swift
//  GliderFileProvider
//
//  Created by Antonio García on 26/6/21.
//

import FileProvider

class FileProviderExtension: NSFileProviderExtension {
    // Data
    private let gliderClient = GliderClient()
    private var fileManager = FileManager()
    
    // MARK: -
    override init() {
        super.init()
    }
    
    override func item(for identifier: NSFileProviderItemIdentifier) throws -> NSFileProviderItem {
        //DLog("item: \(identifier.rawValue)")
        guard let item = gliderClient.metadataCache.fileProviderItem(for: identifier) else {
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
    
        let manager = NSFileProviderManager.default
        let partialPath = item.fullPath.deletingPrefix("/")
        let url = manager.documentStorageURL.appendingPathComponent(partialPath, isDirectory: item.entry.isDirectory)
        print("urlForItem at: \(identifier.rawValue) -> \(url.absoluteString)")
        return url
    }
    
    override func persistentIdentifierForItem(at url: URL) -> NSFileProviderItemIdentifier? {
      
        /*
        // exploit the fact that the path structure has been defined as
        // <base storage directory>/<item identifier>/<item file name> above
        assert(pathComponents.count > 2)
        
        return NSFileProviderItemIdentifier(pathComponents[pathComponents.count - 2])
 */
        
        let pathComponents = url.pathComponents
        let fullPath = "/" + pathComponents[pathComponents.count - 1]
        let persistentIdentifier = NSFileProviderItemIdentifier(fullPath)
        print("persistentIdentifierForItem at: \(url.absoluteString) -> \(persistentIdentifier.rawValue)")
        return persistentIdentifier
    }
    
    override func providePlaceholder(at url: URL, completionHandler: @escaping (Error?) -> Void) {
        //DLog("providePlaceholder at: \(url.absoluteString)")
        
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
            print("providePlaceholder error: \(error)")
            completionHandler(error)
        }
    }

    override func startProvidingItem(at url: URL, completionHandler: @escaping ((_ error: Error?) -> Void)) {
        print("startProvidingItem at: \(url.absoluteString)")
        
        // Should ensure that the actual file is in the position returned by URLForItemWithIdentifier:, then call the completion handler
        
        /* TODO:
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
            completionHandler(NSFileProviderError(.noSuchItem))
            return
        }

        guard let fileProviderItem = try? item(for: identifier) as? FileProviderItem else {
            completionHandler(NSFileProviderError(.noSuchItem))
            return
        }
        
        // Check that the placeholder exists
        let isFileOnDisk = fileManager.fileExists(atPath: url.path)
        if !isFileOnDisk {
           
            gliderClient.setupFileTransferIfNeeded() { result in
                switch result {
                case .success(let client):
                    client.readFile(path: fileProviderItem.fullPath) { result in
                        switch result {
                        case .success(let data):
                            do {
                                try data.write(to: url, options: .atomic)
                                print("readFile \(fileProviderItem.fullPath) success")
                                completionHandler(nil)
                            }
                            catch(let error) {
                                print("readFile \(fileProviderItem.fullPath) write to disk error: \(error)")
                                completionHandler(error)
                            }
                            
                        case .failure(let error):
                            print("readFile \(fileProviderItem.fullPath) error: \(error)")
                            completionHandler(NSFileProviderError(.serverUnreachable))
                        }
                    }
                    
                case .failure(let error):
                    print("setupFileTransferIfNeeded error: \(error)")
                    completionHandler(NSFileProviderError(.serverUnreachable))

                }
            }
            
        }
        else {
            // TODO: check if the file is current
            
            completionHandler(nil)
        }
        
        //completionHandler(NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
    }
    
    
    override func itemChanged(at url: URL) {
        print("itemChanged at: \(url.absoluteString)")
        
        // Called at some point after the file has changed; the provider may then trigger an upload
        
        /* TODO:
         - mark file at <url> as needing an update in the model
         - if there are existing NSURLSessionTasks uploading this file, cancel them
         - create a fresh background NSURLSessionTask and schedule it to upload the current modifications
         - register the NSURLSessionTask with NSFileProviderManager to provide progress updates
         */
    }
    
    override func stopProvidingItem(at url: URL) {
        print("stopProvidingItem at: \(url.absoluteString)")
        
        // Called after the last claim to the file has been released. At this point, it is safe for the file provider to remove the content file.
        // Care should be taken that the corresponding placeholder file stays behind after the content file has been deleted.
        
        // Called after the last claim to the file has been released. At this point, it is safe for the file provider to remove the content file.
        
        // TODO: look up whether the file has local changes
        let fileHasLocalChanges = false
        
        if !fileHasLocalChanges {
            // remove the existing file to free up space
            do {
                _ = try FileManager.default.removeItem(at: url)
            } catch {
                // Handle error
            }
            
            // write out a placeholder to facilitate future property lookups
            self.providePlaceholder(at: url, completionHandler: { error in
                // TODO: handle any error, do any necessary cleanup
            })
        }
    }
    
    // MARK: - Actions
    
    /* TODO: implement the actions for items here
     each of the actions follows the same pattern:
     - make a note of the change in the local model
     - schedule a server request as a background task to inform the server of the change
     - call the completion block with the modified item in its post-modification state
     */
    
    // MARK: - Enumeration
    
    override func enumerator(for containerItemIdentifier: NSFileProviderItemIdentifier) throws -> NSFileProviderEnumerator {
        let maybeEnumerator: NSFileProviderEnumerator? = nil
        if (containerItemIdentifier == NSFileProviderItemIdentifier.rootContainer) {
            // TODO: instantiate an enumerator for the container root
            print("enumerator for rootContainer")
            return FileProviderEnumerator(gliderClient: gliderClient, path: "/" )
            
        } else if (containerItemIdentifier == NSFileProviderItemIdentifier.workingSet) {
            // TODO: instantiate an enumerator for the working set
            print("TODO: enumerator for workingSet")
            
            
        } else {
            // TODO: determine if the item is a directory or a file
            // - for a directory, instantiate an enumerator of its subitems
            // - for a file, instantiate an enumerator that observes changes to the file
            
            if let item = try item(for: containerItemIdentifier) as? FileProviderItem  {
                if item.entry.isDirectory {
                    print("enumerator for directory: \(containerItemIdentifier)")
                    let path = item.path + item.entry.name + "/"
                    return FileProviderEnumerator(gliderClient: gliderClient, path: path  )
                }
                else {
                    print("TODO: enumerator for file: \(containerItemIdentifier)")
                }
            }
            
        }
        guard let enumerator = maybeEnumerator else {
            print("TODO: enumerator")
            throw NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:])
        }
        return enumerator
    }
    
}
