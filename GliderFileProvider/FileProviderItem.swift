//
//  FileProviderItem.swift
//  GliderFileProvider
//
//  Created by Antonio García on 26/6/21.
//

import FileProvider
import UniformTypeIdentifiers

class FileProviderItem: NSObject, NSFileProviderItem {

    private(set) var path: String
    private(set) var entry: BlePeripheral.DirectoryEntry
    var fullPath: String { path + entry.name }
    
    init(path: String, entry: BlePeripheral.DirectoryEntry) {
        self.path = path
        self.entry = entry
    }
    
    var itemIdentifier: NSFileProviderItemIdentifier {
        return itemIdentifier(from: fullPath)
    }
    
    var parentItemIdentifier: NSFileProviderItemIdentifier {
        let parentPath: String
        
        // Remove leading '/' and find the next one. Keep anything after the one found
        let pathWithoutLeadingSlash = path.deletingPrefix("/")
        if let indexOfFirstSlash = (pathWithoutLeadingSlash.range(of: "/")?.lowerBound) {
            let parentPathWithoutLeadingSlash = String(pathWithoutLeadingSlash.prefix(upTo: indexOfFirstSlash))
            parentPath = "/"+parentPathWithoutLeadingSlash
        }
        else {      // Is root (only the leading '/' found)
            parentPath = path       // The parent for root is root
        }
        
        //DLog("parent for: '\(fullPath)' -> '\(parentPath)'")
        return itemIdentifier(from: parentPath)
        
    }

    var capabilities: NSFileProviderItemCapabilities {
        if entry.isDirectory {
            return [.allowsContentEnumerating]
        }
        else {
            return [.allowsReading]
        }
//        return .allowsAll
    }
    
    var filename: String {
        return entry.name
    }
    
    var contentType: UTType {
        // Types defined here: https://developer.apple.com/documentation/uniformtypeidentifiers/system_declared_uniform_type_identifiers
        if entry.isDirectory {
            return .folder
        }
        else {
            let fileExtension = URL(fileURLWithPath: entry.name).pathExtension
            return UTType(filenameExtension: fileExtension) ?? .item
        }
    }
    
    var documentSize: NSNumber? {
        guard case let .file(size) = entry.type else { return nil }
        return size as NSNumber
    }
    
    
    // MARK: - Utils
    private func itemIdentifier(from path: String) -> NSFileProviderItemIdentifier {
        let isRootDirectory = path == "/"
        if isRootDirectory {
            return .rootContainer
        }
        else {
            return NSFileProviderItemIdentifier(path)
        }
    }
}

