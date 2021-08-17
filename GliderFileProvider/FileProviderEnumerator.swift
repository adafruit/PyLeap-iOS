//
//  FileProviderEnumerator.swift
//  GliderFileProvider
//
//  Created by Antonio García on 26/6/21.
//

import FileProvider

class FileProviderEnumerator: NSObject, NSFileProviderEnumerator {
    // Data
    private let gliderClient: GliderClient
    private let path: String
    
    // MARK: -
    init (gliderClient: GliderClient, path: String) {
        self.gliderClient = gliderClient
        self.path = path
        super.init()
    }
    
    /*
    var enumeratedItemIdentifier: NSFileProviderItemIdentifier
    
    init(enumeratedItemIdentifier: NSFileProviderItemIdentifier) {
        self.enumeratedItemIdentifier = enumeratedItemIdentifier
        super.init()
    }*/

    func invalidate() {
        DLog("FileProviderEnumerator invalidate")
        // Perform invalidation of server connection if necessary
        //gliderClient.disconnect()
    }

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        /* TODO:
         - inspect the page to determine whether this is an initial or a follow-up request
         
         If this is an enumerator for a directory, the root container or all directories:
         - perform a server request to fetch directory contents
         If this is an enumerator for the active set:
         - perform a server request to update your local database
         - fetch the active set from your local database
         
         - inform the observer about the items returned by the server (possibly multiple times)
         - inform the observer that you are finished with this page
         */
        
        
        // Enumerate items for .rootDirectory
        gliderClient.setupFileTransferIfNeeded() { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let client):
                client.listDirectory(path: self.path) { result in
                    switch result {
                    case .success(let entries):
                        if let entries = entries {
                            let items = entries.map {  FileProviderItem(path: self.path, entry: $0) }
                            
                            DLog("listDirectory returned \(items.count) items")
                            self.gliderClient.metadataCache.updateMetadata(items: items)
                            observer.didEnumerate(items)
                        }
                        else {
                            DLog("listDirectory: nonexistent directory")
                            observer.didEnumerate([])
                        }
                        observer.finishEnumerating(upTo: nil)

                    case .failure(let error):
                        DLog("listDirectory \(self.path) error: \(error)")
                        observer.finishEnumeratingWithError(error)
                    }
                }
                
            case .failure(let error):
                DLog("setupFileTransferIfNeeded error: \(error)")
                observer.finishEnumeratingWithError(NSFileProviderError(.serverUnreachable))
            }
        }
        
    }
    
    func enumerateChanges(for observer: NSFileProviderChangeObserver, from anchor: NSFileProviderSyncAnchor) {
        /* TODO:
         - query the server for updates since the passed-in sync anchor
         
         If this is an enumerator for the active set:
         - note the changes in your local database
         
         - inform the observer about item deletions and updates (modifications + insertions)
         - inform the observer when you have finished enumerating up to a subsequent sync anchor
         */
        
        DLog("enumerateChanges for anchor: \(anchor.rawValue)")
    }

    
}
