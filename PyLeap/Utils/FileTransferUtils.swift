//
//  FileTransferUtils.swift
//  Glider
//
//  Created by Antonio García on 24/5/21.
//

import Foundation

struct FileTransferUtils {
    static let pathSeparator: Character = "/"
    
    static func pathRemovingFilename(path: String) -> String {
        guard let filenameIndex = path.lastIndex(of: Self.pathSeparator) else {
            return path
        }
        
        return String(path[path.startIndex...filenameIndex])
    }
    
    static func upPath(from path: String) -> String {
        
        // Remove trailing separator if exists
        let filenamePath: String
        if path.last == Self.pathSeparator {
            filenamePath = String(path.dropLast())
        }
        else {
            filenamePath = path
        }
        
        // Remove any filename
        let pathWithoutFilename = FileTransferUtils.pathRemovingFilename(path: filenamePath)
        return pathWithoutFilename
        
    }
}
