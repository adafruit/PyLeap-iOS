//
//  MetadataCache.swift
//  GliderFileProvider
//
//  Created by Antonio García on 26/6/21.
//

import Foundation
import FileProvider

struct FileMetadataCache {
    private static let userDefaults = UserDefaults(suiteName: "group.com.adafruit.PyLeap")!        // Shared between the app and extensions
    private static let fileMetadataKey = "metadataKey"
    
    private var metadata = [NSFileProviderItemIdentifier: FileProviderItem]()
            
    init() {
        // Load from userDefaults
        loadFromUserDefaults()
        
        // If is the first time add root container
        if metadata[.rootContainer] == nil {
            metadata[.rootContainer] = FileProviderItem(path: FileTransferPathUtils.rootDirectory, entry: BlePeripheral.DirectoryEntry(name: "", type: .directory, modificationDate: nil))
            saveToUserDefaults()
        }
    }
    
    /*
    mutating func setFileProviderItems(items: [FileProviderItem]) {
        for item in items {
            metadata[item.itemIdentifier] = item
        }
        
        // Update user Defaults
        saveToUserDefaults()
    }*/
    
    mutating func setFileProviderItem(item: FileProviderItem) {
        metadata[item.itemIdentifier] = item
                
        // Update user Defaults
        saveToUserDefaults()
    }
    
    mutating func setDirectoryItems(items: [FileProviderItem]) {
        guard let commonPath = items.first?.path else { return }
        let areAllDirectoriesEqual = items.map{$0.path}.allSatisfy{$0 == commonPath}
        guard areAllDirectoriesEqual else {
            DLog("setDirectoryItems error: all items should have the same directory ")
            return
        }
        
        // Sync: Delete any previous contents of the directory that is not present in the new items array
        let itemsIdentifiers = items.map {$0.itemIdentifier}
        let itemsToDelete = metadata.filter({(fileProviderItemIdentifier, fileProviderItem) in
            let alreadyExists = fileProviderItem.path == commonPath
            let isInNewSet =  itemsIdentifiers.contains(fileProviderItem.itemIdentifier)    // This check could be elminated because we are going to add all new elements later. So we could just delete all of the current elements in the directory
            return alreadyExists && !isInNewSet && fileProviderItemIdentifier != .rootContainer
        })
        let _ = itemsToDelete.map { metadata.removeValue(forKey: $0.key) }
        if itemsToDelete.count > 0 {
            DLog("Metadata: deleted \(itemsToDelete.count) items that are no longer present in directory: \(commonPath)")
        }
                
        // Insert updated items
        for item in items {
            metadata[item.itemIdentifier] = item
        }
        
        // Update user Defaults
        saveToUserDefaults()
    }
    
    mutating func deleteFileProviderItem(identifier: NSFileProviderItemIdentifier) {
        metadata.removeValue(forKey: identifier)
        //metadata[identifier] = nil
    }
    
    func fileProviderItem(for identifier: NSFileProviderItemIdentifier) -> FileProviderItem? {
        return metadata[identifier]
    }
    
    // MARK: - Save / Load from UserDefaults
    private func saveToUserDefaults() {
        guard let encodedData = try? JSONEncoder().encode(metadata) else { DLog("Error encoding metadata"); return }
            
        Self.userDefaults.set(encodedData, forKey: Self.fileMetadataKey)
    }
    
    private mutating func loadFromUserDefaults() {
        guard let decodedData = Self.userDefaults.object(forKey: Self.fileMetadataKey) as? Data else { return }
        guard let decodedMetadata = try? JSONDecoder().decode([NSFileProviderItemIdentifier: FileProviderItem].self, from: decodedData) else {  DLog("Error decoding metadata"); return  }
        
        self.metadata = decodedMetadata
    }
}

extension NSFileProviderItemIdentifier: Codable {}
