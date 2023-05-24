//
//  BleContentTransfer.swift
//  PyLeap
//
//  Created by Trevor Beaton on 9/22/22.
//

import SwiftUI
import FileTransferClient

protocol BoardInfoDelegate: AnyObject {
    func boardInfoDidUpdate(to newBoard: Board?)
}

enum ListCommandError: Error {
    case belowMinimum
    case isPrime
}

class BleContentTransfer: ObservableObject, BoardInfoDelegate {
    
    @Published var currentBoard: Board? {
        didSet {

        }
    }
    
    static let shared = BleContentTransfer()
    
    private weak var fileTransferClient: FileTransferClient?
    
    @Published var entries = [BlePeripheral.DirectoryEntry]()
    
    var projectName: String?
    
    @ObservedObject var downloadModel = DownloadViewModel()
    
    var manager = FileManager.default
    
    @Published var downloadState: DownloadState = .idle
    
    
    @Published var isTransmiting = false
    
    @Published var isTransferring = false
    
    @Published var transferError = false
    
    @Published var downloaderror = false

    
    
    @Published var contentCommands = BleContentCommands()
    // CLEAN UP
    var projectDirectories: [URL] = []
    var projectFiles: [URL] = []
    
    
    @Published var sendingBundle = false
    @Published var didCompleteTranfer = false
    @Published var writeError = false
    
    @Published var counter = 0
    @Published var numOfFiles = 0
    
    @Published var fileArray: [ContentFile] = []
    @Published var contentList: [URLData] = []
    
    @Published var isConnectedToInternet = false
    @Published var showAlert = false
        
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    func boardInfoDidUpdate(to newBoard: Board?) {
            self.currentBoard = newBoard
            // Add any other logic you need to handle the new board here.
        }
    
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
        registerNotification(enabled: true)
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

        projectDirectories.removeFirst()
        
        DispatchQueue.main.async {
            self.numOfFiles = self.filterCPVersion(incomingArray: self.projectFiles).count
        }
        
       
        
        makeDirectory(directoryArray: filterCPVersion(incomingArray: projectDirectories), regularFilesArray: filterCPVersion(incomingArray: projectFiles))
        
    }
    
    
    
    
    
    
    func filterCPVersion(incomingArray: [URL]) -> [URL] {

        let filteredList = incomingArray.filter {
            let lastPathComponent = $0.lastPathComponent
            return lastPathComponent != "CircuitPython 8.x"
                && lastPathComponent != "CircuitPython 7.x"
                && lastPathComponent != "CircuitPython_Templates"
        }
            
                let listForCurrentCPVersion = filteredList.filter {
                    $0.absoluteString.contains("CircuitPython%20\(Board.shared.versionNumber).x")
                }
     
            return listForCurrentCPVersion
        }
    
    
    func makeDirectory(directoryArray: [URL], regularFilesArray: [URL]) {
        print("\(#function) @Line: \(#line)")
        var recursiveArray = directoryArray
        
     
        if directoryArray.isEmpty {
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
        
        indexOfCP = tempPathComponents.firstIndex(of: "CircuitPython \(Board.shared.versionNumber).x")!
            tempPathComponents.removeSubrange(0...indexOfCP)
            tempPathComponents.removeLast()
            var joinedArrayPath = tempPathComponents.joined(separator: "/")
            print("\(#function) @Line: \(#line)")
            print("Outgoing makeFileString: \(joinedArrayPath) for CP 8")
            return joinedArrayPath
        
        
    
    }
    
    
    
    
    func makeDirectoryString (url: URL) -> String {
        var indexOfCP = 0
        var tempPathComponents = url.pathComponents
        
        print("Incoming URL: \(url.absoluteString) ")
        
        print(tempPathComponents)
        indexOfCP = tempPathComponents.firstIndex(of: "CircuitPython \(Board.shared.versionNumber).x")!
            
            
            tempPathComponents.removeSubrange(0...indexOfCP)
            var joinedArrayPath = tempPathComponents.joined(separator: "/")
            print("\(#function) @Line: \(#line)")
            print("Outgoing Directory String: \(joinedArrayPath) for CP \(Board.shared.versionNumber)")
            return joinedArrayPath
        
    }
    
    
    func newTransfer(listOf urls: [URL]) {
        guard !urls.isEmpty else {
            print("All Files Transferred! 👍")
            completedTransfer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                self.resetTransferParameters()
            }
            return
        }
        
        print("\(#function) @Line: \(#line)")
        print("Files left for transfer: \(urls.count)")
        print("Attempting to transfer... \(urls.first?.lastPathComponent ?? "No file found")")
        DispatchQueue.main.async { self.counter += 1 }
        
        guard let url = urls.first,
              let data = try? Data(contentsOf: url) else {
            print("File not found")
            return
        }
        
        let path = isDirectFile(name: url.lastPathComponent) ? url.lastPathComponent : makeDirectoryString(url: url)
        
        contentCommands.writeFileCommand(path: path, data: data) { result in
            switch result {
            case .success:
                print("Success ✅")
                self.newTransfer(listOf: Array(urls.dropFirst()))
            case .failure(let error):
                print("Transfer Failure \(error)")
                self.handleTransferError(error)
            }
        }
    }

    private func handleTransferError(_ error: Error) {
        DispatchQueue.main.async {
            print("\(#function) @Line: \(#line)")
            print(error)
            self.downloadState = .failed
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.downloadState = .idle
            }
            NotificationCenter.default.post(name: .didEncounterTransferError, object: nil, userInfo: nil)
        }
    }

    private func resetTransferParameters() {
        sendingBundle = false
        completedTransfer()
        numOfFiles = 0
        counter = 0
        contentList.removeAll()
    }

    private func isDirectFile(name: String) -> Bool {
        return name == "code.py" || name == "README.txt"
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
