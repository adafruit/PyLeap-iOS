//
//  ProjectViewModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 6/30/21.
//

import SwiftUI
import FileTransferClient

class ProjectViewModel: ObservableObject  {
    
    var networkMonitor = NetworkMonitor()
    
    
    @Published var sendingBundle = false
    
    @AppStorage("index") var index = 0
    private weak var fileTransferClient: FileTransferClient?
    
    @Published var fileArray: [ContentFile] = []
    @Published var directoryArray: [ContentFile] = []
    
    @Published var bootUpInfo = ""
    
    @Published var entries = [BlePeripheral.DirectoryEntry]()
    @Published var isTransmiting = false
    @Published var isRootDirectory = false
    @Published var directory = ""
    
    @Published var numOfFiles = 0
    @Published var counter = 0
    @Published var showAlert = false
    
    @Published var didDownload = false
    
    @Published var isConnectedToInternet = false
    
    @Published var newBundleDownloaded = false
    @Published var didCompleteTranfer = false
    @Published var writeError = false
    
    var projectDirectories: [URL] = []
    
    enum ProjectViewError: LocalizedError {
        case fileTransferUndefined
    }
    
    func completedTransfer() {
        DispatchQueue.main.async {
            self.didCompleteTranfer = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.didCompleteTranfer = false
        }
    }
    
    func displayErrorMessage() {
        DispatchQueue.main.async {
            self.writeError = true
            self.sendingBundle = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.writeError = false
        }
    }
    // MARK: - View Startup
    func downloadCheck(at filePath: URL){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                if FileManager.default.fileExists(atPath: filePath.path) {
                    self.didDownload = true
                    DispatchQueue.main.async {
                        print("Bundle downloaded.")
                        self.didDownload = false
                        self.didDownload = true
                        self.filesDownloaded(url: filePath)
                    }
                } else {
                    DispatchQueue.main.async {
                        print("Bundle did not download. Check PyLeap Learn Guide for selected project.")
                    }
                }
            }
        }
    }
    
    func internetMonitoring() {
        
        networkMonitor.startMonitoring()
        networkMonitor.monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Connected to internet.")
                
                DispatchQueue.main.async {
                    self.showAlert = false
                    self.isConnectedToInternet = true
                }
            } else {
                print("No connection.")
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.isConnectedToInternet = false
                }
            }
            print("isExpensive: \(path.isExpensive)")
        }
    }
    
    // Deletes all files and dic. on Bluefruit device *Except boot_out.txt*
    func removeAllFiles(){
        self.listDirectoryCommand(path: "") { result in
            
            switch result {
                
            case .success(let contents):
                
                print("Listed Content")
                
                for i in contents! where i.name != "boot_out.txt" {
                    self.deleteFileCommand(path: i.name) { deletionResult in
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
    
    func filesDownloaded(url: URL){
        
        fileArray.removeAll()
        
        var files = [URL]()
        
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey, .addedToDirectoryDateKey,.isDirectoryKey])
                    if fileAttributes.isRegularFile!  {
                        
                        files.append(fileURL)
                        
                        print("File name: \(fileURL.deletingPathExtension().lastPathComponent)")
                        print("Path Extention:.\(fileURL.pathExtension)\n")
                        
                        let resources = try fileURL.resourceValues(forKeys:[.fileSizeKey])
                        let fileSize = resources.fileSize!
                        
                        print("Path Size:\(fileSize) kb\n")
                        
                        let addedFile = ContentFile(title: fileURL.lastPathComponent, fileSize: fileSize)
                        fileArray.append(addedFile)
                    }
                    
                    if fileAttributes.isDirectory! {
                        
                        let addedFile = ContentFile(title: fileURL.lastPathComponent, fileSize: 0)
                        
                        directoryArray.append(addedFile)
                        
                        print("directory name: \(fileURL.deletingPathExtension().lastPathComponent)")
                    }
                    
                } catch { print(error, fileURL) }
            }
            numOfFiles = fileArray.count
            print("File Count: \(self.fileArray.count)")
            print("\(files)")
        }
    }
    
    func filesTransfer(url: URL) {
        print(#function)
        
        let localFileManager = FileManager()
        let resourceKeys = Set<URLResourceKey>([.nameKey, .isDirectoryKey])
        var topLvlFiles: [URL] = []
        var fileURLs: [URL] = []
        
        
        let dirEnumerator = localFileManager.enumerator(at: url, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)!
        
        do {
            
            let directoryContents = try localFileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            print("base contents: \(directoryContents)")
            
            for content in directoryContents {
                
                if !content.hasDirectoryPath {
                    topLvlFiles.append(content)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        for case let fileURL as URL in dirEnumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                  let isDirectory = resourceValues.isDirectory,
                  let name = resourceValues.name
            else {
                continue
            }
            
            if isDirectory {
                if name == "_extras" {
                    dirEnumerator.skipDescendants()
                }
                projectDirectories.append(fileURL)
            } else {
                fileURLs.append(fileURL)
            }
        }
        
        print(fileURLs)

        DispatchQueue.main.async {
            self.sendingBundle = true
        }
        directoryList(dirList: projectDirectories, filesUrls: fileURLs)
    }
    
    func directoryList(dirList: [URL], filesUrls: [URL]) {
        var copiedDirectory = dirList
        
        // if directory is not lib, add to lib
        if dirList.isEmpty {
            print("No directories left in queue")
            self.sendTopfiles(topFiles: filesUrls)
        } else {
            guard let directory = dirList.first else {
                print("No directory exist here")
                return
            }
            
            print("Directory: \(directory.lastPathComponent)")
            
            if directory.lastPathComponent == "lib" {
                
                mkLibDir(libDirectory: directory, copiedDirectory: copiedDirectory, filesUrl: filesUrls)
                
            } else {
                
                mkSubLibDir(subdirectory: directory, copiedDirectory: copiedDirectory, filesURL: filesUrls)
            }
        }
    }
    
    func mkLibDir(libDirectory: URL, copiedDirectory: [URL], filesUrl: [URL]){
        var temp = copiedDirectory
        
        listDirectoryCommand(path: "") { result in
            
            switch result {
                
            case .success(let contents):
                print("ListDirCommand: \(String(describing: contents))")
                
                if contents!.contains(where: { name in name.name == libDirectory.lastPathComponent}) {
                    print("lib directory exist")
                    
                    temp.removeFirst()
                    self.directoryList(dirList: temp, filesUrls: filesUrl)
                    
                } else {
                    print("lib directory does not exist")
                    
                    self.makeDirectoryCommand(path: libDirectory.lastPathComponent) { result in
                        switch result {
                        case .success:
                            print("Success")
                            
                            temp.removeFirst()
                            self.directoryList(dirList: temp, filesUrls: filesUrl)
                            
                        case .failure:
                            self.displayErrorMessage()
                        }
                    }
                }
                
            case .failure:
                print("failure")
                self.displayErrorMessage()
            }
        }
    }
    
    func mkSubLibDir(subdirectory: URL, copiedDirectory: [URL], filesURL: [URL]) {
        var temp = copiedDirectory
        
        listDirectoryCommand(path: "lib/") { result in
            
            switch result {
                
            case .success(let contents):
                
                if contents!.contains(where: { name in name.name == subdirectory.lastPathComponent}) {
                    print("\(subdirectory.lastPathComponent) directory exist")
                    
                    temp.removeFirst()
                    self.directoryList(dirList: temp, filesUrls: filesURL)
                    
                } else {
                    print("\(subdirectory.lastPathComponent) directory does not exist")
                    
                    self.makeDirectoryCommand(path: "lib/\(subdirectory.lastPathComponent)") { result in
                        switch result {
                        case .success:
                            print("Success")
                            
                            temp.removeFirst()
                            self.directoryList(dirList: temp, filesUrls: filesURL)
                            
                        case .failure:
                            self.displayErrorMessage()
                        }
                    }
                }
                
            case .failure:
                self.displayErrorMessage()
            }
        }
    }
    
    func sendTopfiles(topFiles: [URL]) {
        
        var copiedFiles = topFiles
        
        if topFiles.isEmpty {
            print("Array of contents empty - Check other directories")
            self.completedTransfer()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                self.sendingBundle = false
                self.counter = 0
            }
            
        } else {
            
            guard let topFile = topFiles.first else {
                print("No such file exist here")
                return
            }
            
            print(topFile.lastPathComponent)
            print(topFile.path)
            
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: topFile.deletingPathExtension().lastPathComponent, relativeTo: topFile).appendingPathExtension(topFile.pathExtension)) else {
                print("File not found")
                return
            }
            
            if topFile.deletingLastPathComponent().lastPathComponent == "CircuitPython 7.x"{
                self.writeFileCommand(path: "/\(topFile.deletingPathExtension().lastPathComponent).\(topFile.pathExtension)", data: data) { result in
                    switch result {
                        
                    case .success(_):
                        copiedFiles.removeFirst()
                        self.sendTopfiles(topFiles: copiedFiles)
                        
                    case .failure(_):
                        self.displayErrorMessage()
                    }
                }
            }
            
            else if topFile.deletingLastPathComponent().lastPathComponent == "lib" {
                
                writeFileCommand(path: "/lib/\(topFile.deletingPathExtension().lastPathComponent).\(topFile.pathExtension)", data: data) { result in
                    switch result {
                    case .success(_):
                        copiedFiles.removeFirst()
                        self.sendTopfiles(topFiles: copiedFiles)
                        
                    case .failure(_):
                        self.displayErrorMessage()
                    }
                }
            } else {
                
                writeFileCommand(path: "/lib/\(topFile.deletingLastPathComponent().lastPathComponent)/\(topFile.deletingPathExtension().lastPathComponent).\(topFile.pathExtension)", data: data) { result in
                    switch result {
                    case .success(_):
                        copiedFiles.removeFirst()
                        self.sendTopfiles(topFiles: copiedFiles)
                    case .failure(_):
                        self.displayErrorMessage()
                        
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.sendingBundle = true
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
    
    enum ActiveAlert: Identifiable {
        case error(error: Error)
        
        var id: Int {
            switch self {
            case .error: return 1
            }
        }
    }
    @Published var activeAlert: ActiveAlert?
    
    // Data
    private let bleManager = BleManager.shared
    
    
    init() {
        
    }
    
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
                    print("Read: \(str)")
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
        counter += 1
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
