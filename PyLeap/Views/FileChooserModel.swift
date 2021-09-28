//
//  FileChooserViewModel.swift
//  Glider
//
//  Created by Antonio García on 24/5/21.
//

import Foundation

class FileChooserViewModel: ObservableObject {
    @Published var isRootDirectory = false
    @Published var entries = [BlePeripheral.DirectoryEntry]()
    @Published var directory = ""
    @Published var isTransmiting = false

    private var fileTransferClient: FileTransferClient?
    
    func setup(fileTransferClient: FileTransferClient?, directory: String) {
        self.fileTransferClient = fileTransferClient
        
        // Clean directory name
        let directoryName = FileTransferPathUtils.pathRemovingFilename(path: directory)
        self.directory = directoryName
        
        // List directory
        listDirectory(directory: directoryName)
    }
    
    func listDirectory(directory: String) {
        isRootDirectory = FileTransferPathUtils.isRootDirectory(path: directory)
        entries.removeAll()
        isTransmiting = true
        
        fileTransferClient?.listDirectory(path: directory) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isTransmiting = false
                
                switch result {
                case .success(let entries):
                    if let entries = entries {
                        self.setEntries(entries)
                        self.directory = directory
                    }
                    else {
                        DLog("listDirectory: nonexistent directory")
                        self.directory = directory
                    }
                    
                case .failure(let error):
                    DLog("listDirectory \(directory) error: \(error)")
                }
            }
        }
    }
    
    func makeDirectory(path: String) {
        // Make sure that the path ends with the separator
        DLog("makeDirectory: \(path)")
        isTransmiting = true
        fileTransferClient?.makeDirectory(path: path) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isTransmiting = false
                
                switch result {
                case .success(_ /*let date*/):
                    DLog("makeDirectory \(path) success")
                    self.listDirectory(directory: self.directory)      // Force list again directory
                    
                case .failure(let error):
                    DLog("makeDirectory \(path) error: \(error)")
                }
            }
        }
    }
    
    private func setEntries(_ entries: [BlePeripheral.DirectoryEntry]) {
        // Order by directory and as a second criteria order by name
        self.entries = entries.sorted(by: {
            if case .directory = $0.type, case .directory = $1.type  {    // Both directories: order alphabetically
                return $0.name < $1.name
            }
            else if case .file = $0.type, case .file = $1.type {          // Both files: order alphabetically
                return $0.name < $1.name
            }
            else {      // Compare directory and file
                if case .directory = $0.type { return true } else { return false }
            }
        })
    }
    
    func delete(at offsets: IndexSet) {
        for offset in offsets {
            let entry = entries[offset]
            let filename = directory + entry.name
            DLog("delete: \(offset) - \(filename)")

            isTransmiting = true
            fileTransferClient?.deleteFile(path: filename) { [weak self]  result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isTransmiting = false
                    
                    switch result {
                    case .success(let success):
                        DLog("deleteFile \(filename) success: \(success)")
                        self.listDirectory(directory: self.directory)      // Force list again directory
                        
                    case .failure(let error):
                        DLog("deleteFile \(filename) error: \(error)")
                    }
                }
            }
        }
    }
}
