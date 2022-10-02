//
//  BleContentTransfer.swift
//  PyLeap
//
//  Created by Trevor Beaton on 9/22/22.
//

import SwiftUI
import FileTransferClient

class BleContentTransfer: ObservableObject {
    
    private weak var fileTransferClient: FileTransferClient?
    @Published var entries = [BlePeripheral.DirectoryEntry]()
    @Published var isTransmiting = false
    @Published var bootUpInfo = ""
    
    @Published var contentCommands = BleContentCommands()
    
    var projectDirectories: [URL] = []
    @Published var sendingBundle = false
    @Published var didCompleteTranfer = false
    @Published var writeError = false
    
    
    @Published var counter = 0
    @Published var numOfFiles = 0
    
    @Published var fileArray: [ContentFile] = []
    @Published var contentList: [URLData] = []
    
    @Published var isConnectedToInternet = false
    @Published var showAlert = false
    
    var downloadPhases: String = ""
    
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    @Published var state: DownloadState = .idle
    
    enum ProjectViewError: LocalizedError {
        case fileTransferUndefined
    }
    
    func displayErrorMessage() {
        
        DispatchQueue.main.async {
            self.writeError = true
            self.sendingBundle = false
        }

    }
    
    
    /// Deletes all files and directories on Bluefruit device *Except boot_out.txt*
    
       func removeAllFiles(){
           contentCommands.listDirectoryCommand(path: "") { result in
               
               switch result {
                   
               case .success(let contents):
                   
                   for i in contents! where i.name != "boot_out.txt" {
                       self.contentCommands.deleteFileCommand(path: i.name) { deletionResult in
                           switch deletionResult {
                           case .success:
                               print("Successfully Deleted")
                           case .failure:
                               print("Failed to delete.")
                           }
                       }
                   }
               case .failure:
                   print("No content listed")
               }
           }
       }
    
    func appendDirectories(_ url: URL) {
        projectDirectories.append(url)
    }
    
    func appendFileArrayElements(fileContent: ContentFile) {
        fileArray.append(fileContent)
    }
    
    func removeFileArrayElements() {
        fileArray.removeAll()
    }
    
    func getProjectURL(nameOf project: String) {
        print("getProjectURL called")
        counter = 0
        state = .transferring
        if let enumerator = FileManager.default.enumerator(at: directoryPath, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
           // for case condition: Only process URLs
            
            
            
            for case let fileURL as URL in enumerator {
                
                do {
                    
                    if fileURL.lastPathComponent == project {
                        
                        print("Searching for... \(project)")
                       
                        do {

                            print("Found \(project) project at this location...")
                            print("URL Path: \(fileURL.path)")
                            print("URL : \(fileURL)")
                            let newURL = URL(fileURLWithPath: fileURL.path, relativeTo: directoryPath)
                            print("URL: \(newURL)")
                            filesDownloaded(url: fileURL)
                            
                            return
                        } catch { print(error, fileURL) }
                    } else {
                        
                        print("Project was not found for...\(project)")
                        print("\(state)")
                        state = .idle
                        
                    }
                    
                }
            }
            
        }
        
    }
    
    
    func filesDownloaded(url: URL) {
        print("filesDownloaded was called")
        //Cycles through files and directories in File Manager Document Directory
        fileArray.removeAll()
        
        var files = [URL]()
        removeFileArrayElements()
        // Returns a directory enumerator object that can be used to perform a deep enumeration of the directory at the specified URL.
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
           // for case condition: Only process URLs
            for case let fileURL as URL in enumerator {
                
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey, .addedToDirectoryDateKey,.isDirectoryKey])
                    
                    print("INCOMING FILE: \(fileURL.path)")
                    
                    if fileURL.path.contains("adafruit-circuitpython-bundle-7.x-mpy") {
                        print("Removing adafruit-circuitpython-bundle-7.x-mpy: \(fileURL.path)")
                        
                    } else {
                        
                        contentList.append(.init(urlTitle: fileURL))
                        if fileAttributes.isRegularFile! {
                            
                            files.append(fileURL)
                            
                            let resources = try fileURL.resourceValues(forKeys:[.fileSizeKey])
                            let fileSize = resources.fileSize!
                            
                            let addedFile = ContentFile(title: fileURL.lastPathComponent, fileSize: fileSize)
                            appendFileArrayElements(fileContent: addedFile)
                        }
                        
                        let addedFile = ContentFile(title: fileURL.lastPathComponent, fileSize: 0 )
                        appendFileArrayElements(fileContent: addedFile)
                    }
                    
                } catch { print(error, fileURL) }
            }
            
            startFileTransfer(url: url)
            
            numOfFiles = files.count
            print("Contents in URL \(fileArray.count)")
            print("Number of Files in URL \(files.count)")
           
            for i in contentList {
                
               print("CL: \(i.urlTitle.pathComponents)")
            }
            
            contentList.removeAll()
        }
    }
    
    
    
    
    func startFileTransfer(url: URL) {
        print("Project Location: \(url)")
        let localFileManager = FileManager()
        let resourceKeys = Set<URLResourceKey>([.nameKey, .isDirectoryKey])
        var fileURLs: [URL] = []
        
        let dirEnumerator = localFileManager.enumerator(at: url, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)!
        
        for case let fileURL as URL in dirEnumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                  let isDirectory = resourceValues.isDirectory,
                  let name = resourceValues.name
            else {
                continue
            }
            
            if fileURL.path.contains("adafruit-circuitpython-bundle-7.x-mpy") {
                print("Removing adafruit-circuitpython-bundle-7.x-mpy: \(fileURL.path)")
                
            } else {
                if isDirectory {
                    print("Directories Found")
                    print(fileURL.lastPathComponent)
                    if name == "_extras" {
                        dirEnumerator.skipDescendants()
                    }
                    //adafruit-circuitpython-bundle
                    if fileURL.lastPathComponent.contains("adafruit-circuitpython-bundle") {
                        print("We got one!")
                        print("Bad file - \(fileURL)")
                    } else {
                        if fileURL.pathComponents.count > 12 {
                            print("File Path component count: \(fileURL.pathComponents.count)")
                            projectDirectories.append(fileURL)
                        }
                    }
                    
                    
                   
                } else {
                    print("APPENDED: \(fileURL.path)")
                    fileURLs.append(fileURL)
                }
            }
            
           
        }
        
        print("List of Directories")
        for i in projectDirectories {
            print("Directory: \(i.path)")
        }
        print("List of Files")
        for i in fileURLs {
            print("Files: \(i.path)")
        }
        
        DispatchQueue.main.async {
            self.sendingBundle = true
        }

     
        print("Current projectDirectories: \(projectDirectories[0])")
        
        sortDirectory(dirList: projectDirectories, filesUrls: fileURLs)
    }
    
    
    func sortDirectory(dirList: [URL], filesUrls: [URL]) {

        print(#function)
        //Creates a sorted list of directories
        var tempDirectory = dirList.sorted(by: { $1.pathComponents.count > $0.pathComponents.count} )
        print("Evaluating: \(String(describing: tempDirectory.first?.lastPathComponent))")
        print("With Path: \(String(describing: tempDirectory.first?.path))")
        
        print("Sorted Directory")
        for i in tempDirectory{
            
            print(i.lastPathComponent)
        }
        // If directories are not found, start transferring files over to directories.
        if dirList.isEmpty {
            print("No directories left in queue")
            projectDirectories.removeAll()
            self.transferFiles(files: filesUrls)
            
        } else {
            guard let firstDirectory = tempDirectory.first else {
                print("No directory exist here")
                return
            }
            
            // If lib/ directory is found in the project bundle, make a lib directory on client.
            if firstDirectory.lastPathComponent == "lib" {
                mkLibDir(libDirectory: firstDirectory, copiedDirectory: tempDirectory, filesUrl: filesUrls)
                
            } else {
                mkSubLibDir(subdirectory: firstDirectory, copiedDirectory: tempDirectory, filesURL: filesUrls)
            }
        }
        self.projectDirectories.removeAll()
    }
   
    //Make lib/ Directory
    func mkLibDir(libDirectory: URL, copiedDirectory: [URL], filesUrl: [URL]) {
        print(#function)
        var temp = copiedDirectory
       // print(temp)
        
        print("mkLibDir list")
        for i in temp {
            print("\(i)")
        }
        
            contentCommands.listDirectoryCommand(path: "") { result in
            
            switch result {
                // Check that lib/ exist.
            case .success(let contents):
                print("ListDirCommand: \(String(describing: contents))")
                
                if contents!.contains(where: { name in name.name == libDirectory.lastPathComponent}) {
                    print("lib directory exist")
                    
                    temp.removeFirst()
                    self.sortDirectory(dirList: temp, filesUrls: filesUrl)
                    
                } else {
                    print("lib directory does not exist")
                    print("XXXX mkLibDir")
                    var tempURL = libDirectory.pathComponents
                    tempURL.removeFirst(12)
                    
                    let joined = tempURL.joined(separator: "/")
                    print("FIXED PATHxx:\(joined)")
                
                    
                    self.contentCommands.makeDirectoryCommand(path: joined) { result in
                        switch result {
                        case .success:
                            print("Success")
                            
                            temp.removeFirst()
                            self.sortDirectory(dirList: temp, filesUrls: filesUrl)
                            
                        case .failure:
                            print("Failed to create directory \(joined)")
                            temp.removeAll()
                            self.projectDirectories.removeAll()
                            self.displayErrorMessage()
                        }
                    }
                }
                
            case .failure:
                print("Failure - mkLibDir")
                temp.removeAll()
                self.projectDirectories.removeAll()
                self.displayErrorMessage()
            }
        }
    }
    
   
    func mkSubLibDir(subdirectory: URL, copiedDirectory: [URL], filesURL: [URL]) {
        print(#function)
        var temp = copiedDirectory
       
       print("List of Directories Currently in mkSubLibDir")
        for i in temp {
            
            print("\(i.path)")
        }
        
        var tempURL = subdirectory.pathComponents
        tempURL.removeFirst(12)
        
        let joined = tempURL.joined(separator: "/")
        
        print("Modified Path top: \(joined)")
        
        var pathDirectoryForListCommand = tempURL
        pathDirectoryForListCommand.removeLast()
        let pathDirectoryForListCommandJoined = pathDirectoryForListCommand.joined(separator: "/")
        
        
        print("pathDirectoryForListCommandJoined: \(pathDirectoryForListCommandJoined)")
        print("How its taken: \(pathDirectoryForListCommandJoined)/")
        
        
        contentCommands.listDirectoryCommand(path: "\(pathDirectoryForListCommandJoined)/") { result in
            
            switch result {
                
            case .success(let contents):
                
                
               
                
                if contents!.contains(where: { name in name.name == subdirectory.lastPathComponent}) {
                    print("FULL PATH OF: \(subdirectory.lastPathComponent)")
                    print("\(subdirectory.path)")
                    // Skips the existing directory.
                    temp.removeFirst()
                    self.sortDirectory(dirList: temp, filesUrls: filesURL)
                    
                } else {
                    
                    print("\(subdirectory.lastPathComponent) directory does not exist")
                    print("Here's the full path of \(subdirectory.lastPathComponent): \(subdirectory.path)")
                    print("XXXX mkSubLibDir")
                    
                    var tempURL = subdirectory.pathComponents
                    
                    print("Incoming URL: \(tempURL)")
                   
                    tempURL.removeFirst(12)
                    
                    print("Modified Path without seperators: \(tempURL)")
                    
                    let joined = tempURL.joined(separator: "/")
                    
                    print("Modified Path: \(joined)")
                    
                    var pathDirectoryForListCommand = tempURL
                    pathDirectoryForListCommand.removeLast()
                    let pathDirectoryForListCommandJoined = pathDirectoryForListCommand.joined(separator: "/")
                    
                    
                    print("pathDirectoryForListCommandJoined: \(pathDirectoryForListCommandJoined)")
                   
                    
                    self.contentCommands.makeDirectoryCommand(path: joined) { result in
                       
                        switch result {
                        case .success:
                            print("Success")

                            temp.removeFirst()
                            self.sortDirectory(dirList: temp, filesUrls: filesURL)

                        case .failure:
                            print("Failed to create directory - 2")
                            temp.removeAll()
                            self.projectDirectories.removeAll()
                            self.displayErrorMessage()
                        }
                    }
                }
                
            case .failure:
                print("Fail in: \(#function)")
                print("\(tempURL)")
                temp.removeAll()
                self.projectDirectories.removeAll()
                self.displayErrorMessage()
            }
        }
    }
    
    func completedTransfer() {
       
       
        DispatchQueue.main.async {
            self.didCompleteTranfer = true
            self.numOfFiles = 0
            self.counter = 0
            self.state = .complete

        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.didCompleteTranfer = false
            self.state = .idle
            
        }
    }
    
    func transferFiles(files: [URL]) {
        print(#function)
        var copiedFiles = files
        print("Number of files in filesArray \(files.count)")
        print(files)
        
        if files.isEmpty {
            print("Array of contents empty - Check other directories")
            self.completedTransfer()
            
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                self.sendingBundle = false
                self.counter = 0
                
                self.numOfFiles = 0
                self.contentList.removeAll()
            }
            
        } else {
            
            guard let selectedUrl = files.first else {
                print("No such file exist here")
                return
            }
            
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: selectedUrl.deletingPathExtension().lastPathComponent, relativeTo: selectedUrl).appendingPathExtension(selectedUrl.pathExtension)) else {
                print("File not found")
                return
            }
            
            if selectedUrl.deletingLastPathComponent().lastPathComponent == "CircuitPython 7.x"{
                
                print("Selected Path: \(selectedUrl.path)")
                
                var tempURL = selectedUrl.pathComponents

                tempURL.removeFirst(12)
                let joined = tempURL.joined(separator: "/")
               
                
                var newModPath = tempURL
                newModPath.removeLast()
                print("Test file path: \(tempURL)")
                
                print("File transfer modified path xx: \(joined)")
                
                
                
                self.contentCommands.writeFileCommand(path: joined, data: data) { result in
                    switch result {
                        
                    case .success(_):
                        copiedFiles.removeFirst()
                        self.transferFiles(files: copiedFiles)
                        
                    case .failure(_):
                        DispatchQueue.main.async {
                           
                            print("Transfer Failure")
                            print("\(joined)")
                            self.state = .failed
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.state = .idle
                            }
                            
                        }
                        
                        
                        self.displayErrorMessage()
                    }
                }
            }
            
            
            
            else if selectedUrl.deletingLastPathComponent().lastPathComponent == "lib" {
                
                
                
                var tempURL = selectedUrl.pathComponents
                tempURL.removeFirst(12)
                let joined = tempURL.joined(separator: "/")
                print("File transfer modified path 11:\(joined)")
                
                
                
                print("Updated Path:\(joined)")
                
                
                
                contentCommands.writeFileCommand(path: joined, data: data) { result in
                    switch result {
                    case .success(_):
                        copiedFiles.removeFirst()
                        self.transferFiles(files: copiedFiles)
                        
                    case .failure(_):
                        print("Transfer Failure - 2")
                        self.state = .failed
                        self.displayErrorMessage()
                    }
                }
            } else {
                
                if selectedUrl.lastPathComponent == "README.txt" {
                    print("Got one")
                    copiedFiles.removeFirst()
                    self.transferFiles(files: copiedFiles)
                   

                } else {
                    var tempURL = selectedUrl.pathComponents
                    
                    tempURL.removeFirst(12)
                    let joined = tempURL.joined(separator: "/")
                    print("File transfer modified path: \(joined)")



                    print("Updated Path:\(joined)")


                    contentCommands.writeFileCommand(path: joined, data: data) { result in
                        switch result {
                        case .success(_):
                            copiedFiles.removeFirst()
                            self.transferFiles(files: copiedFiles)
                        case .failure(let error):
                            print("Failed: \(error): \(result)")
                           // self.displayErrorMessage()

                        }
                    }
                }
                
                
                
            }
        }
        
        DispatchQueue.main.async {
            self.sendingBundle = true
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    func readMyStatus() {
       // model.readFile(filename: "boot_out.txt")
        print(#function)

        print("BOOT INFO: \(bootUpInfo)")
        
        switch bootUpInfo.description {
            
        case let str where str.contains("circuitplayground_bluefruit"):
            print("Circuit Playground Bluefruit device")
            bootUpInfo = "circuitplayground_bluefruit"
//            DispatchQueue.main.async { [self] in
//                    self.globalString.compatibilityString = "circuitplayground_bluefruit"
//            }
        case let str where str.contains("clue_nrf52840_express"):
            print("Clue device")
            bootUpInfo = "clue_nrf52840_express"
//            DispatchQueue.main.async { [self] in
//                globalString.compatibilityString = "clue_nrf52840_express"
//
//            }
        default:
            print("Unknown Device")
        }
        
    }
    
    
    
    
    
}
