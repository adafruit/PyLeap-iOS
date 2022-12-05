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
    
    var projectName: String?
    
    @ObservedObject var downloadModel = DownloadViewModel()
    
    var manager = FileManager.default
    
    @Published var downloadState: DownloadState = .idle
    
    @State var circuitPythonVersion = String()
    
    @Published var isTransmiting = false
    
    @Published var isTransferring = false
    
    @Published var transferError = false
    
    @Published var downloaderror = false
    
    @Published var bootUpInfo = ""
    
    
    
    @Published var contentCommands = BleContentCommands()
    // CLEAN UP
    var projectDirectories: [URL] = []
    var projectFiles: [URL] = []
    var returnedArray = [[String]]()
    var fileTransferArray : [URL] = []
    
    var filesReadyForTransfer : [URL] = []
    
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
    
    
    enum ProjectViewError: LocalizedError {
        case fileTransferUndefined
    }
    
    @objc func displayErrorMessage(_ notification: Notification) {
        
        DispatchQueue.main.async {
            self.transferError = true
            self.downloadState = .failed
        }
        
    }
    
    init() {
        getCPVersion()
        registerNotification(enabled: true)
    }
    
    func getCPVersion() {
        if sharedBootinfo.contains("CircuitPython 7") {
            print("circuitPythonVersion = 7")
            circuitPythonVersion = "7"
            print(circuitPythonVersion)
        }
        
        if sharedBootinfo.contains("CircuitPython 8") {
            print("circuitPythonVersion = 8")
            circuitPythonVersion = "8"
            print(circuitPythonVersion)
        }
    }
    
    
    private weak var didCompleteZip: NSObjectProtocol?
    private weak var didEncounterTransferError: NSObjectProtocol?
    private weak var downloadErrorDidOccur: NSObjectProtocol?
    
    private func registerNotification(enabled: Bool) {
        print("\(#function) @Line: \(#line)")
        
        let notificationCenter = NotificationCenter.default
        
        if enabled {
            
            NotificationCenter.default.addObserver(self, selector: #selector(zipSuccess(_:)), name: .didCompleteZip,object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(displayErrorMessage(_:)), name: .didEncounterTransferError,object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(projectDownloadDidFail(_:)), name: .downloadErrorDidOccur,object: nil)
            
        } else {
            if let testObserver = didCompleteZip {notificationCenter.removeObserver(testObserver)}
            if let downloadErrorObserver = downloadErrorDidOccur {notificationCenter.removeObserver(downloadErrorObserver)}
            
        }
    }
    
    
    
    @objc func zipSuccess(_ notification: NSNotification) {
        print("Zip - Success.")
        print("\(#function) @Line: \(#line)")
        if let projectInfo = notification.userInfo as Dictionary? {
            if let title = projectInfo["projectTitle"] as? String, let link = projectInfo["projectLink"] as? String {
                testFileExistance(for: title, bundleLink: link)
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.downloadState = .transferring
                }
            }
        }
    }
    
    @objc func projectDownloadDidFail(_ notification: Notification) {
        downloadState = .failed
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.downloadState = .idle
        }
    }
    
    
    func testFileExistance(for project: String, bundleLink: String) {
        removeFileArrayElements()
        
        projectName = project
        
        DispatchQueue.main.async {
            self.downloadState = .transferring
        }
        
        let nestedFolderURL = directoryPath.appendingPathComponent(project)
        
        if manager.fileExists(atPath: nestedFolderURL.relativePath) {
            print("Exist")
            
            filesDownloaded(url: nestedFolderURL)
            
        } else {
            print("Does not exist - downloading \(project)")
            
            downloadModel.trueDownload(useProject: bundleLink, projectName: project)
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
    
    func appendRegularFiles(_ url: URL) {
        projectFiles.append(url)
    }
    
    func appendFileArrayElements(fileContent: ContentFile) {
        fileArray.append(fileContent)
    }
    
    func removeFileArrayElements() {
        fileArray.removeAll()
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
                    
                    contentList.append(.init(urlTitle: fileURL))
                    if fileAttributes.isRegularFile! {
                        
                        files.append(fileURL)
                        
                        let resources = try fileURL.resourceValues(forKeys:[.fileSizeKey])
                        let fileSize = resources.fileSize!
                        
                        let addedFile = ContentFile(title: fileURL.lastPathComponent, fileSize: fileSize)
                        appendFileArrayElements(fileContent: addedFile)
                    }
                    
                    let addedFile = ContentFile(title: fileURL.lastPathComponent, fileSize: 0)
                    appendFileArrayElements(fileContent: addedFile)
                    
                    
                } catch { print(error, fileURL) }
            }
            
            
            DispatchQueue.main.async {
                self.numOfFiles = files.count
            }
            
            print("Contents in URL \(fileArray.count)")
            print("Number of Files in URL \(files.count)")
            
            for i in contentList {
                print("CL: \(i.urlTitle.pathComponents)")
            }
            
            startFileTransfer(url: url)
            contentList.removeAll()
        }
    }
    
    func startFileTransfer(url: URL) {
        print("Project Location: \(url)")
        let localFileManager = FileManager()
        let resourceKeys = Set<URLResourceKey>([.nameKey, .isDirectoryKey])
        var regularFileUrls: [URL] = []
        
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
                    
                    
                    if fileURL.lastPathComponent.contains("adafruit-circuitpython-bundle") {
                        print("We got one!")
                        print("Bad file - \(fileURL)")
                    } else {
                        // print("Directories: \(fileURL.path)")
                        appendDirectories(fileURL)
                        
                    }
                    
                } else {
                    //  print("Regular Files: \(fileURL.path)")
                    regularFileUrls.append(fileURL)
                    appendRegularFiles(fileURL)
                }
            }
        }
        
        
        //  filterCPVersion(incomingArray: regularFileUrls)
        //  filterCPFiles(filesArray: regularFileUrls)
        
        
        // pathManipulation(arrayOfAny: filterCPVersion(incomingArray: projectDirectories), regularArray: filterCPVersion(incomingArray: projectFiles))
        
        projectDirectories.removeFirst()
        
        DispatchQueue.main.async {
            self.numOfFiles = self.filterCPVersion(incomingArray: self.projectFiles).count
        }
        
       
        
        makeDirectory(directoryArray: filterCPVersion(incomingArray: projectDirectories), regularFilesArray: filterCPVersion(incomingArray: projectFiles))
        
    }
    
    
    
    
    
    
    func filterCPVersion(incomingArray: [URL]) -> [URL] {
        print("project name \(projectName)")
        
        
        for i in incomingArray {
            print("incoming Array \(i.absoluteString)")
        }
        
        
        
        let listWithoutCP8Folder = incomingArray.filter {
            $0.lastPathComponent != ("CircuitPython 8.x")
        }
        
        let listWithoutCP7Folder = listWithoutCP8Folder.filter {
            $0.lastPathComponent != ("CircuitPython 7.x")
        }
        
        //CircuitPython_Templates
        
        let removedCPTemplates = listWithoutCP7Folder.filter {
            $0.lastPathComponent != ("CircuitPython_Templates")
            
        }
        
        
        if sharedBootinfo.contains("CircuitPython 8") {
            let listForCurrentCPVersion = removedCPTemplates.filter {
                !$0.absoluteString.contains("CircuitPython%207.x")
            }
            
            for i in listForCurrentCPVersion {
                print("listForCurrentCPVersion :- \(i.absoluteString)")
            }
            
            return listForCurrentCPVersion
            
        }
        
        if sharedBootinfo.contains("CircuitPython 7") {
            
            let listForCurrentCPVersion = listWithoutCP7Folder.filter {
                !$0.absoluteString.contains("CircuitPython%208.x")
            }
            
            for i in listForCurrentCPVersion {
                print("listForCurrentCPVersion :- \(i.absoluteString)")
            }
            return listForCurrentCPVersion
        }
        
        return listWithoutCP7Folder
    }
    
    
    func makeDirectory(directoryArray: [URL], regularFilesArray: [URL]) {
        print("\(#function) @Line: \(#line)")
        var recursiveArray = directoryArray
        
        for i in recursiveArray {
            print("recursiveArray \(i.absoluteString)")
        }
        
        if directoryArray.isEmpty {
            print("Array is empty. makeDirectory is done - Ready for file transfer!")
            newTransfer(listOf: regularFilesArray)
        } else {
            
            if recursiveArray.first?.lastPathComponent == "CircuitPython_Templates" {
                recursiveArray.removeFirst()
                self.makeDirectory(directoryArray: recursiveArray, regularFilesArray: regularFilesArray)
            }
            
            if recursiveArray.first?.lastPathComponent == "lib" {
                
                contentCommands.listDirectoryCommand(path: "") {  result in
                    switch result {
                    case .success(let contents):
                        if contents!.contains(where: { name in name.name == recursiveArray.first?.lastPathComponent}) {
                            print("Lib Folder Found - Will Skip")
                            
                            recursiveArray.removeFirst()
                            self.makeDirectory(directoryArray: recursiveArray, regularFilesArray: regularFilesArray)
                            return
                        } else {
                            
                            print("File does not exist on board: \(self.makeDirectoryString(url: (recursiveArray.first)!))")
                            
                            self.contentCommands.makeDirectoryCommand(path: self.makeDirectoryString(url: (recursiveArray.first)!)) { result in
                                switch result {
                                case .success:
                                    print("Directory made.")
                                    recursiveArray.removeFirst()
                                    self.makeDirectory(directoryArray: recursiveArray, regularFilesArray: regularFilesArray)
                                case .failure(let error):
                                      print("\(#function) @Line: \(#line)")
                                    print("Failure - \(error)")
                                }
                            }
                            
                        }
                        
                        
                    case .failure(let error):
                        print(error)
                        
                    }
                }
            } else {
                let path = recursiveArray.first?.deletingLastPathComponent()
                print("check path \(path?.absoluteString ?? "path")")
                
                contentCommands.listDirectoryCommand(path: makeDirectoryString(url: path!)) { [self] result in
                    switch result {
                        
                    case .success(let contents):
                        
                        if contents!.contains(where: { name in name.name == recursiveArray.first?.lastPathComponent}) {
                           // print(contents)
                            print("Exists for: \(String(describing: path?.absoluteString))")
                            recursiveArray.removeFirst()
                            makeDirectory(directoryArray: recursiveArray, regularFilesArray: regularFilesArray)
                            
                        } else {
                            
                            print("File does not exist on board: \(path?.absoluteString ?? "path")")
                            print("MAKE DIRECTORY HERE")
                            
                            contentCommands.makeDirectoryCommand(path: makeDirectoryString(url: (recursiveArray.first)!)) { result in
                                switch result {
                                case .success:
                                    print("Directory made.")
                                    recursiveArray.removeFirst()
                                    self.makeDirectory(directoryArray: recursiveArray, regularFilesArray: regularFilesArray)
                                    
                                case .failure(let error):
                                      print("\(#function) @Line: \(#line)")
                                    print("Failure - \(error)")
                                }
                            }
                            
                        }
                        
                    case .failure(let error):
                        print(error)
                        print("\(#function) @Line: \(#line)")
                    }
                }
                
            }
            
        }
        
    }
    
    enum ListCommandError: Error {
        case belowMinimum
        case isPrime
    }
    
    func checkIfFilesExistOnBoard(url: URL) {
        
        contentCommands.listDirectoryCommand(path: makeDirectoryString(url: url)) { [self] result in
          
            switch result {
                
            case .success(let contents):
                
                if contents!.contains(where: { name in name.name == url.lastPathComponent}) {
                    print(contents)
                    print("Exists for: \(url.absoluteString)")
                  
                } else {
                    print("File does not exist on board:  \(url.absoluteString)")
                    print("Make File")
                }
                
            case .failure(let error):
                print(error)
                print("\(#function) @Line: \(#line)")
            }
        }
        
    }
    
    
    
    func makeFileString(url: URL)-> String {
        var indexOfCP = 0
        var tempPathComponents = url.pathComponents
        print("Incoming URL for makeFileString: \(url.absoluteString)")
        
        
        if sharedBootinfo.contains("CircuitPython 7") {
            
            indexOfCP = tempPathComponents.firstIndex(of: "CircuitPython 7.x")!
            tempPathComponents.removeSubrange(0...indexOfCP)
            tempPathComponents.removeLast()
            var joinedArrayPath = tempPathComponents.joined(separator: "/")
            print("\(#function) @Line: \(#line)")
            print("Outgoing makeFileString: \(joinedArrayPath) for CP 7")
            return joinedArrayPath
        }
        
        if sharedBootinfo.contains("CircuitPython 8") {
            indexOfCP = tempPathComponents.firstIndex(of: "CircuitPython 8.x")!
            tempPathComponents.removeSubrange(0...indexOfCP)
            tempPathComponents.removeLast()
            var joinedArrayPath = tempPathComponents.joined(separator: "/")
            print("\(#function) @Line: \(#line)")
            print("Outgoing makeFileString: \(joinedArrayPath) for CP 8")
            return joinedArrayPath
        }
        
        return ""
    }
    
    
    
    
    func makeDirectoryString (url: URL) -> String {
        var indexOfCP = 0
        var tempPathComponents = url.pathComponents
        
        print("Incoming URL: \(url.absoluteString) ")
        
        
        
        if sharedBootinfo.contains("CircuitPython 7") {
            
            indexOfCP = tempPathComponents.firstIndex(of: "CircuitPython 7.x")!
            tempPathComponents.removeSubrange(0...indexOfCP)
            var joinedArrayPath = tempPathComponents.joined(separator: "/")
            print("\(#function) @Line: \(#line)")
            print("Outgoing String: \(joinedArrayPath) for CP 7")
            return joinedArrayPath
        }
        
        if sharedBootinfo.contains("CircuitPython 8") {
            indexOfCP = tempPathComponents.firstIndex(of: "CircuitPython 8.x")!
            tempPathComponents.removeSubrange(0...indexOfCP)
            var joinedArrayPath = tempPathComponents.joined(separator: "/")
            print("\(#function) @Line: \(#line)")
            print("Outgoing String: \(joinedArrayPath) for CP 8")
            return joinedArrayPath
        } else {
            
            guard let projectName = projectName else {
                   return "Unknown"
               }
            
            indexOfCP = tempPathComponents.firstIndex(of: projectName)!
            tempPathComponents.removeSubrange(0...indexOfCP)
            var joinedArrayPath = tempPathComponents.joined(separator: "/")
            print("\(#function) @Line: \(#line)")
            print("Outgoing String: \(joinedArrayPath) for CP 7")
            return joinedArrayPath
        }
        
        return ""
    }
    
    
    func newTransfer(listOf urls: [URL]) {
        print("\(#function) @Line: \(#line)")
        var copiedFiles = urls
        print("Files left for transfer: \(urls.count)")
        
        print("Attempting to transfer... \(urls.first?.lastPathComponent ?? "No file found")")
        
        DispatchQueue.main.async {
            self.counter += 1
        }
        
        
        if copiedFiles.isEmpty {
            print("All Files Transferred! 👍")
            self.completedTransfer()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                self.sendingBundle = false
                self.completedTransfer()
                self.numOfFiles = 0
                self.counter = 0
                self.contentList.removeAll()
            }
            
        } else {
            
            guard let data = try? Data(contentsOf: URL(string: copiedFiles.first!.absoluteString)!) else {
                print("File not found")
                return
            }
            
            
            if copiedFiles.first?.lastPathComponent == "code.py" || copiedFiles.first?.lastPathComponent == "README.txt" {
                
                print("Input for writeFileCommand: \(copiedFiles.first?.absoluteString)")
              
                
                self.contentCommands.writeFileCommand(path: copiedFiles.first!.lastPathComponent, data: data) { result in
                    switch result {
                        
                    case .success(_):
                        print("Success ✅")
                        copiedFiles.removeFirst()
                        self.newTransfer(listOf: copiedFiles)
                        
                    case .failure(let error):
                        print("\(#function) @Line: \(#line)")
                        print(error)
                        DispatchQueue.main.async {
                            print("Transfer Failure \(error)")
                            self.downloadState = .failed
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.downloadState = .idle
                            }
                            NotificationCenter.default.post(name: .didEncounterTransferError, object: nil, userInfo: nil)
                        }
                    }
                }
            } else {
                
                print("Checking... 🫥")
              //  print("makeDirectoryString transfer \(makeDirectoryString(url: copiedFiles.first!))")
                
                let directoryPath = makeDirectoryString(url: copiedFiles.first!)

                print("Input writeFileCommand: \(directoryPath)")
                self.contentCommands.writeFileCommand(path: directoryPath, data: data) { result in
                    switch result {

                    case .success(_):
                        print("Success ✅")
                        copiedFiles.removeFirst()
                        self.newTransfer(listOf: copiedFiles)

                    case .failure(let error):
                        print("\(#function) @Line: \(#line)")
                        print(error)
                        DispatchQueue.main.async {
                            print("Transfer Failure \(error)")
                            self.downloadState = .failed

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.downloadState = .idle
                            }
                            NotificationCenter.default.post(name: .didEncounterTransferError, object: nil, userInfo: nil)
                        }
                    }
                }
            }
            
        }
        
        
    }
    
    
    
    func filePathMod(listOf files: [URL]) {
        var indexOfCP = 0
        
        for i in files {
            print("-\(i.absoluteString)-\n")
        }
        
        var tempArray = files
        
        if files.isEmpty {
            // Continue
            print("\(#function) @Line: \(#line)")
            print("Done!")
            // print("RETURNED PATHS: \(returnedArray)\n")
            
            for i in filesReadyForTransfer {
                print("\(i)")
            }
            
            //  self.transferFiles(files: fileArray)
            
            //          validateDirectory(directoryArray: returnedArray, fileArray: fileArray)
            
        } else {
            
            var tempPath = files[0].pathComponents
            
            print("temp path \(tempPath)")
            
            if tempPath.contains("CircuitPython 7.x") {
                
                print("\(#function) @Line: \(#line)")
                
                indexOfCP = tempPath.firstIndex(of: "CircuitPython 7.x")!
                
                tempPath.removeSubrange(0...indexOfCP)
                
                print("removeSubrange temp path - \(tempPath)")
                
                
                tempArray.removeFirst()
                
                var joinedArrayPath = tempPath.joined(separator: "/")
                
                
                filesReadyForTransfer.append(URL(string: joinedArrayPath)!)
                
                filePathMod(listOf: tempArray)
                
            }
            
            if tempPath.contains("CircuitPython 8.x") {
                
                print("\(#function) @Line: \(#line)")
                
                indexOfCP = tempPath.firstIndex(of: "CircuitPython 8.x")!
                
                tempPath.removeSubrange(0...indexOfCP)
                
                print("removeSubrange temp path - \(tempPath)")
                
                
                tempArray.removeFirst()
                
                var joinedArrayPath = tempPath.joined(separator: "/")
                
                filesReadyForTransfer.append(URL(string: joinedArrayPath)!)
                
                filePathMod(listOf: tempArray)
                
            }
            
            
            if tempPath.contains(projectName ?? "unknown") {
                
                print("\(#function) @Line: \(#line)")
                
                indexOfCP = tempPath.firstIndex(of: projectName!)!
                
                tempPath.removeSubrange(0...indexOfCP+1)
                
                print("removeSubrange temp path - \(tempPath)")
                
                tempArray.removeFirst()
                
                var joinedArrayPath = tempPath.joined(separator: "/")
                
                filesReadyForTransfer.append(URL(string: joinedArrayPath)!)
                
                filePathMod(listOf: tempArray)
                
            }
            
            
            
        }
        
        
    }
    
    
    


    

    
    
    
    func completedTransfer() {
        
        
        
        DispatchQueue.main.async {
            self.downloadState = .complete
            self.didCompleteTranfer = true
            self.numOfFiles = 0
            self.contentCommands.counter = 0
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.didCompleteTranfer = false
            self.downloadState = .idle
            
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
                self.completedTransfer()
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
                            self.downloadState = .failed
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.downloadState = .idle
                            }
                            
                        }
                        
                        NotificationCenter.default.post(name: .didEncounterTransferError, object: nil, userInfo: nil)
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
                        self.downloadState = .failed
                        NotificationCenter.default.post(name: .didEncounterTransferError, object: nil, userInfo: nil)
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
                            NotificationCenter.default.post(name: .didEncounterTransferError, object: nil, userInfo: nil)
                            
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
        ///model.readFile(filename: "boot_out.txt")
        print(#function)
        
        print("BOOT INFO: \(bootUpInfo)")
        
        switch bootUpInfo.description {
            
        case let str where str.contains("CircuitPython 7"):
            print("CircuitPython 7")
            circuitPythonVersion = "CircuitPython 7"
            
        case let str where str.contains("CircuitPython 8"):
            print("CircuitPython 8")
            circuitPythonVersion = "CircuitPython 8"
        default:
            print("Unknown Device")
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    // MARK: System
    
    struct TransmissionProgress {
        var description: String
        var transmittedBytes: Int
        var totalBytes: Int?
        
        init (description: String) {
            self.description = description
            transmittedBytes = 0
        }
    }
    
    @Published var transmissionProgress: TransmissionProgress?
    
    struct TransmissionLog: Equatable {
        enum TransmissionType: Equatable {
            case read(data: Data)
            case write(size: Int)
            case delete
            case listDirectory(numItems: Int?)
            case makeDirectory
            case error(message: String)
        }
        let type: TransmissionType
        
        var description: String {
            let modeText: String
            switch self.type {
            case .read(let data): modeText = "Received \(data.count) bytes"
            case .write(let size): modeText = "Sent \(size) bytes"
            case .delete: modeText = "Deleted file"
            case .listDirectory(numItems: let numItems): modeText = numItems != nil ? "Listed directory: \(numItems!) items" : "Listed nonexistent directory"
            case .makeDirectory: modeText = "Created directory"
            case .error(let message): modeText = message
            }
            
            return modeText
        }
    }
    @Published var lastTransmit: TransmissionLog? =  TransmissionLog(type: .write(size: 334))
    
    
    @Published var activeAlert: ActiveAlert?
    
    // Data
    private let bleManager = BleManager.shared
    
    
    
    // MARK: - Setup
    func onAppear() {
        //registerNotifications(enabled: true)
        //setup(fileTransferClient: fileTransferClient)
    }
    
    func onDissapear() {
        //registerNotifications(enabled: false)
    }
    
    func setup(fileTransferClient: FileTransferClient?) {
        guard let fileTransferClient = fileTransferClient else {
            DLog("Error: undefined fileTransferClient")
            return
        }
        
        self.fileTransferClient = fileTransferClient
        
    }
    
    // MARK: - Actions
    
    func readFile(filename: String) {
        startCommand(description: "Reading \(filename)")
        readFileCommand(path: filename) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.lastTransmit = TransmissionLog(type: .read(data: data))
                    let str = String(decoding: data, as: UTF8.self)
                    print("\(#function) @Line: \(#line)")
                    print("Read: \(str)")
                    //self.readMyStatus()
                    self.bootUpInfo = str
                    
                    
                    
                    
                    
                case .failure(let error):
                    self.lastTransmit = TransmissionLog(type: .error(message: error.localizedDescription))
                }
                
                self.endCommand()
            }
        }
    }
    
    func writeFile(filename: String, data: Data) {
        startCommand(description: "Writing \(filename)")
        writeFileCommand(path: filename, data: data) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.lastTransmit = TransmissionLog(type: .write(size: data.count))
                    
                case .failure(let error):
                    self.lastTransmit = TransmissionLog(type: .error(message: error.localizedDescription))
                }
                
                self.endCommand()
            }
        }
    }
    
    func listDirectory(filename: String) {
        let directory = FileTransferPathUtils.pathRemovingFilename(path: filename)
        
        startCommand(description: "List directory")
        
        listDirectoryCommand(path: directory) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self.lastTransmit = TransmissionLog(type: .listDirectory(numItems: entries?.count))
                    
                case .failure(let error):
                    self.lastTransmit = TransmissionLog(type: .error(message: error.localizedDescription))
                }
                
                self.endCommand()
            }
        }
    }
    
    func deleteFile(filename: String) {
        startCommand(description: "Deleting \(filename)")
        
        deleteFileCommand(path: filename) { [weak self]  result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.lastTransmit = TransmissionLog(type: .delete)
                    
                case .failure(let error):
                    self.lastTransmit = TransmissionLog(type: .error(message: error.localizedDescription))
                }
                
                self.endCommand()
            }
        }
    }
    
    func makeDirectory(path: String) {
        // Make sure that the path ends with the separator
        guard let fileTransferClient = fileTransferClient else { DLog("Error: makeDirectory called with nil fileTransferClient"); return }
        DLog("makeDirectory: \(path)")
        isTransmiting = true
        fileTransferClient.makeDirectory(path: path) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isTransmiting = false
                
                switch result {
                case .success(_ /*let date*/):
                    print("Success! Path made!")
                    
                case .failure(let error):
                    DLog("makeDirectory \(path) error: \(error)")
                }
            }
        }
    }
    
    // MARK: - Command Status
    private func startCommand(description: String) {
        transmissionProgress = TransmissionProgress(description: description)    // Start description with no progress 0 and undefined Total
        lastTransmit = nil
    }
    
    private func endCommand() {
        transmissionProgress = nil
    }
    
    private func readFileCommand(path: String, completion: ((Result<Data, Error>) -> Void)?) {
        guard let fileTransferClient = fileTransferClient else { return }
        
        DLog("start readFile \(path)")
        fileTransferClient.readFile(path: path, progress: { [weak self] read, total in
            DLog("reading progress: \( String(format: "%.1f%%", Float(read) * 100 / Float(total)) )")
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.transmissionProgress?.transmittedBytes = read
                self.transmissionProgress?.totalBytes = total
            }
        }) { result in
            if AppEnvironment.isDebug {
                switch result {
                case .success(let data):
                    DLog("readFile \(path) success. Size: \(data.count)")
                    
                case .failure(let error):
                    DLog("readFile  \(path) error: \(error)")
                }
            }
            
            completion?(result)
        }
    }
    
    private func writeFileCommand(path: String, data: Data, completion: ((Result<Date?, Error>) -> Void)?) {
        guard let fileTransferClient = fileTransferClient else { completion?(.failure(ProjectViewError.fileTransferUndefined)); return }
        
        DispatchQueue.main.async {
            
        }
        
        
        DLog("start writeFile \(path)")
        fileTransferClient.writeFile(path: path, data: data, progress: { [weak self] written, total in
            DLog("writing progress: \( String(format: "%.1f%%", Float(written) * 100 / Float(total)) )")
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.transmissionProgress?.transmittedBytes = written
                self.transmissionProgress?.totalBytes = total
            }
        }) { result in
            if AppEnvironment.isDebug {
                switch result {
                case .success:
                    DLog("writeFile \(path) success. Size: \(data.count)")
                    
                case .failure(let error):
                    DLog("writeFile  \(path) error: \(error)")
                }
            }
            
            completion?(result)
        }
    }
    
    private func deleteFileCommand(path: String, completion: ((Result<Void, Error>) -> Void)?) {
        guard let fileTransferClient = fileTransferClient else { completion?(.failure(ProjectViewError.fileTransferUndefined)); return }
        
        DLog("start deleteFile \(path)")
        fileTransferClient.deleteFile(path: path) { result in
            if AppEnvironment.isDebug {
                switch result {
                case .success:
                    DLog("deleteFile \(path) success")
                    
                case .failure(let error):
                    DLog("deleteFile  \(path) error: \(error)")
                }
            }
            
            completion?(result)
        }
    }
    
    private func listDirectoryCommand(path: String, completion: ((Result<[BlePeripheral.DirectoryEntry]?, Error>) -> Void)?) {
        guard let fileTransferClient = fileTransferClient else { completion?(.failure(ProjectViewError.fileTransferUndefined)); return }
        
        DLog("start listDirectory \(path)")
        fileTransferClient.listDirectory(path: path) { result in
            switch result {
            case .success(let entries):
                DLog("listDirectory \(path). \(entries != nil ? "Entries: \(entries!.count)" : "Directory does not exist")")
                
            case .failure(let error):
                DLog("listDirectory \(path) error: \(error)")
            }
            
            completion?(result)
        }
    }
    
    private func makeDirectoryCommand(path: String, completion: ((Result<Date?, Error>) -> Void)?) {
        guard let fileTransferClient = fileTransferClient else { completion?(.failure(ProjectViewError.fileTransferUndefined)); return }
        
        DLog("start makeDirectory \(path)")
        fileTransferClient.makeDirectory(path: path) { result in
            switch result {
            case .success(_ /*let date*/):
                DLog("makeDirectory \(path)")
                
            case .failure(let error):
                DLog("makeDirectory \(path) error: \(error)")
            }
            
            completion?(result)
        }
    }
    
}
