//
//  FileTransferPathUtils.swift
//  Glider
//
//  Created by Antonio García on 24/5/21.
//

import Foundation

// TODO: FileProvider should not use this utils because even if the separators for FileProvider and URLs are the same, it could change in the future
struct FileTransferPathUtils {
    static let pathSeparatorCharacter: Character = "/"
    static let pathSeparator = String(pathSeparatorCharacter)
    
    // MARK: - Path management
    static func pathRemovingFilename(path: String) -> String {
        guard let filenameIndex = path.lastIndex(of: Self.pathSeparatorCharacter) else {
            return path
        }
        
        return String(path[path.startIndex...filenameIndex])
    }
    
    static func upPath(from path: String) -> String {
        
        // Remove trailing separator if exists
        let filenamePath: String
        if path.last == Self.pathSeparatorCharacter {
            filenamePath = String(path.dropLast())
        }
        else {
            filenamePath = path
        }
        
        // Remove any filename
        let pathWithoutFilename = FileTransferPathUtils.pathRemovingFilename(path: filenamePath)
        return pathWithoutFilename
    }
    
    static func parentPath(from path: String) -> String {
        guard !isRootDirectory(path: path) else { return rootDirectory }     // Root parent is root
        
        let parentPath: String
        // Remove leading '/' and find the next one. Keep anything after the one found
        let pathWithoutLeadingSlash = path.deletingPrefix(rootDirectory)
        if let indexOfLastSlash = pathWithoutLeadingSlash.lastIndex(of: "/") {//(pathWithoutLeadingSlash.range(of: "/")?.lowerBound) {
            let parentPathWithoutLeadingSlash = String(pathWithoutLeadingSlash.prefix(upTo: indexOfLastSlash))
            parentPath = rootDirectory + parentPathWithoutLeadingSlash
        }
        else {      // Is root (only the leading '/' found)
            parentPath = rootDirectory
        }
        
        return parentPath
    }
    
    static func pathWithTrailingSeparator(path: String) -> String {
        return path.hasSuffix("/") ? path : path.appending("/")      // Force a trailing separator
    }
    
    // MARK: - Root Directory
    static var rootDirectory: String {
        return Self.pathSeparator
    }
    
    static func isRootDirectory(path: String) -> Bool {
        return path == rootDirectory
    }
    
}
