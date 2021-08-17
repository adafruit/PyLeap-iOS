//
//  MetadataCache.swift
//  GliderFileProvider
//
//  Created by Antonio García on 26/6/21.
//

import Foundation
import FileProvider



struct FileMetadataCache {
    private var metadata = [NSFileProviderItemIdentifier: FileProviderItem]()
            
    init() {
        // Add root container
        metadata[.rootContainer] = FileProviderItem(path: "/", entry: BlePeripheral.DirectoryEntry(name: "", type: .directory))
    }
    
    mutating func updateMetadata(items: [FileProviderItem]) {
        for item in items {
            metadata[item.itemIdentifier] = item
        }
    }
    
    func fileProviderItem(for identifier: NSFileProviderItemIdentifier) -> FileProviderItem? {
        return metadata[identifier]
    }
}
