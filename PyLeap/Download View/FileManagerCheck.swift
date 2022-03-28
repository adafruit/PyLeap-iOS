//
//  FileManagerCheck.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/24/22.
//

import Foundation
import SwiftUI

struct URLData: Identifiable {
    let id = UUID()
    let urlTitle: URL
}

struct ContentFile: Identifiable {
    var id = UUID()
    var title: String
    var fileSize: Int
}

class FileManagerCheck: NSObject, ObservableObject {
    
    @Published var fileArray: [ContentFile] = []
    @Published var contentList: [URLData] = []
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let cachesPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    
    
    func filesDownloaded() {
        
        fileArray.removeAll()
        var files = [URL]()
        if let enumerator = FileManager.default.enumerator(at: directoryPath, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey, .addedToDirectoryDateKey,.isDirectoryKey])
                    
                    contentList.append(.init(urlTitle: fileURL))
                    if fileAttributes.isRegularFile! {
                        
                        files.append(fileURL)
                        
                        let resources = try fileURL.resourceValues(forKeys:[.fileSizeKey])
                        let fileSize = resources.fileSize!
                        
                        let addedFile = ContentFile(title: fileURL.lastPathComponent, fileSize: fileSize)
                        fileArray.append(addedFile)
                    }
                    
                    if fileAttributes.isDirectory! {
                       // directoryArrayTest.append(fileURL)
                    }
                    
                    if fileURL.lastPathComponent == "code.py" {
                        
                        do {
                            
                            let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                            print(text2)
                         //   editableContent1 = text2
                        }
                        
                    }
                    
                    if fileAttributes.isDirectory! {
                        
                        let addedFile = ContentFile(title: fileURL.lastPathComponent, fileSize: 0)
                        
                   //     directoryArray.append(addedFile)
                    }
                    
                } catch { print(error, fileURL) }
            }
          //  numOfFiles = fileArray.count
            print("File Count: \(self.fileArray.count)")
            
            for i in contentList {
                
                //print("CL: \(i.urlTitle.pathComponents.count - 12)")
                print("CL: \(i.urlTitle.pathComponents)")
            }
            
        }
    }
    
    
}
