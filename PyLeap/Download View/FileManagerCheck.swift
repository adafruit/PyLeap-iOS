//
//  FileManagerCheck.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/24/22.
//

import Foundation
import SwiftUI
import FileTransferClient

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
    
    // From previous code
    private weak var fileTransferClient: FileTransferClient?
    @Published var bootUpInfo = ""
    var projectDirectories: [URL] = []
    @Published var sendingBundle = false
    @Published var didCompleteTranfer = false
    @Published var writeError = false
    @Published var counter = 0
    @Published var isTransmiting = false
    
    
    @Published var fileArray: [ContentFile] = []
    @Published var contentList: [URLData] = []
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let cachesPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    
    enum ProjectViewError: LocalizedError {
        case fileTransferUndefined
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
    
    
    
//    func beginTransfer(projectName: String) {
//        print(#function)
//        fileArray.removeAll()
//        var files = [URL]()
//        if let enumerator = FileManager.default.enumerator(at: directoryPath, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
//            for case let fileURL as URL in enumerator {
//
//                do {
//                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey, .addedToDirectoryDateKey,.isDirectoryKey])
//
//                    contentList.append(.init(urlTitle: fileURL))
//                    if fileAttributes.isRegularFile! {
//
//                        files.append(fileURL)
//
//                        let resources = try fileURL.resourceValues(forKeys:[.fileSizeKey])
//                        let fileSize = resources.fileSize!
//
//                        let addedFile = ContentFile(title: fileURL.lastPathComponent, fileSize: fileSize)
//                        fileArray.append(addedFile)
//                    }
//
//
//                   // file:///var/mobile/Containers/Data/Application/5738843C-24BF-48AF-9BE8-5E86F16B197D/Documents/RainbowBundle/PyLeap_NeoPixel_demo
//                  //  location file:///private/var/mobile/Containers/Data/Application/E5FC477E-A739-4F41-973C-E3BCFFD2567F
//
//                    if fileAttributes.isDirectory! {
//                        if fileURL.lastPathComponent == projectName {
//                            let newURL = URL(fileURLWithPath: fileURL.path)
//                            print(newURL)
//                           // print("Path^")
//
//                            filesTransfer(url: newURL)
//                        }
//
//                    }
                    
                    
                    
//                    if fileURL.lastPathComponent == projectName {
//                        do {
//
//                            let newURL = try fileURL.path
//                            print("xxx")
//                            print(newURL)
//
//
//
//                         //   filesTransfer(url: newURL?)
//
//                        } catch {
//                            print("Error: \(error)")
//                        }
//
//
//                      //  print("Searching for... \(projectName) - \(text2)")
//
//
//                            print("Found \(projectName) project at this location...")
//                            print(fileURL.path)
//
//                            //filesTransfer(url: URL(string: "/private/var/mobile/Containers/Data/Application/45D346C8-EB2D-41F0-856E-E8B864062C83/Documents/NeoPixel Rainbows"))
//
//
//                    } else {
//                        print("Project was not found...")
//                    }
//
//                } catch { print(error, fileURL) }
//            }
//
//            
//            for i in contentList {
//
//            }
//            
//        }
//        
//        
//        
//    }
//
//
//
//
//    func filesTransfer(url: URL) {
//
//
//        print(#function)
//        print(url)
//        let localFileManager = FileManager()
//        let resourceKeys = Set<URLResourceKey>([.nameKey, .isDirectoryKey])
//        var fileURLs: [URL] = []
//
//        let dirEnumerator = localFileManager.enumerator(at: url, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)!
//
//        for case let fileURL as URL in dirEnumerator {
//            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
//                  let isDirectory = resourceValues.isDirectory,
//                  let name = resourceValues.name
//            else {
//                continue
//            }
//
//            if isDirectory {
//                print("Directories Found")
//                print(fileURL.lastPathComponent)
//                if name == "_extras" {
//                    dirEnumerator.skipDescendants()
//                }
//                projectDirectories.append(fileURL)
//            } else {
//                fileURLs.append(fileURL)
//            }
//        }
//
//        print("Listed Files")
//        for file in fileURLs {
//            print(file.lastPathComponent)
//        }
//
//        DispatchQueue.main.async {
//            self.sendingBundle = true
//        }
//        sortDirectory(dirList: projectDirectories, filesUrls: fileURLs)
//    }
//
//    func sortDirectory(dirList: [URL], filesUrls: [URL]) {
//        // let newarry = directoryArrayTest.sorted(by: { $1.pathComponents.count > $0.pathComponents.count} )
//        print(#function)
//        let tempDirectory = dirList.sorted(by: { $1.pathComponents.count > $0.pathComponents.count} )
//        print("Sorted Directory")
//        for i in tempDirectory{
//            print(i.lastPathComponent)
//        }
//
//        if dirList.isEmpty {
//            print("No directories left in queue")
//            self.transferFiles(files: filesUrls)
//        } else {
//            guard let directory = dirList.first else {
//                print("No directory exist here")
//                return
//            }
//
//            if directory.lastPathComponent == "lib" {
//                mkLibDir(libDirectory: directory, copiedDirectory: tempDirectory, filesUrl: filesUrls)
//
//            } else {
//                mkSubLibDir(subdirectory: directory, copiedDirectory: tempDirectory, filesURL: filesUrls)
//            }
//        }
//    }
//
//    func mkLibDir(libDirectory: URL, copiedDirectory: [URL], filesUrl: [URL]) {
//        print(#function)
//
//        var temp = copiedDirectory
//
//        listDirectoryCommand(path: "") { result in
//
//            switch result {
//
//            case .success(let contents):
//                print("ListDirCommand: \(String(describing: contents))")
//
//                if contents!.contains(where: { name in name.name == libDirectory.lastPathComponent}) {
//                    print("lib directory exist")
//
//                    temp.removeFirst()
//                    self.sortDirectory(dirList: temp, filesUrls: filesUrl)
//
//                } else {
//                    print("lib directory does not exist")
//
//                    var tempURL = libDirectory.pathComponents
//                    tempURL.removeFirst(12)
//
//                    let joined = tempURL.joined(separator: "/")
//                    print("FIXED PATHxx:\(joined)")
//
//                    self.makeDirectoryCommand(path: joined) { result in
//                        switch result {
//                        case .success:
//                            print("Success")
//
//                            temp.removeFirst()
//                            self.sortDirectory(dirList: temp, filesUrls: filesUrl)
//
//                        case .failure:
//                            self.displayErrorMessage()
//                        }
//                    }
//                }
//
//            case .failure:
//                print("Failure mkLibDir")
//                self.displayErrorMessage()
//            }
//        }
//    }
//
//    func mkSubLibDir(subdirectory: URL, copiedDirectory: [URL], filesURL: [URL]) {
//        print(#function)
//
//        var temp = copiedDirectory
//
//        listDirectoryCommand(path: "lib/") { result in
//            print("In listDirectoryCommand loop ")
//            switch result {
//
//            case .success(let contents):
//
//                if contents!.contains(where: { name in name.name == subdirectory.lastPathComponent}) {
//                    print("FULL PATH OF: \(subdirectory.lastPathComponent)")
//                    print("\(subdirectory.path)")
//                    // Skips the existing directory.
//                    temp.removeFirst()
//                    self.sortDirectory(dirList: temp, filesUrls: filesURL)
//
//                } else {
//
//                    print("\(subdirectory.lastPathComponent) directory does not exist")
//
//                    var tempURL = subdirectory.pathComponents
//
//                    tempURL.removeFirst(12)
//                    let joined = tempURL.joined(separator: "/")
//                    print("FIXED PATHxx:\(joined)");
//
//
//                    self.makeDirectoryCommand(path: joined) { result in
//                        switch result {
//                        case .success:
//                            print("Success")
//
//                            temp.removeFirst()
//                            self.sortDirectory(dirList: temp, filesUrls: filesURL)
//
//                        case .failure:
//                            self.displayErrorMessage()
//                        }
//                    }
//                }
//
//            case .failure:
//                print("Failure mkSubLibDir")
//                self.displayErrorMessage()
//            }
//        }
//    }
//
//    func completedTransfer() {
//        DispatchQueue.main.async {
//            self.didCompleteTranfer = true
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            self.didCompleteTranfer = false
//        }
//    }
//
//    func transferFiles(files: [URL]) {
//        print(#function)
//        var copiedFiles = files
//
//        if files.isEmpty {
//            print("Array of contents empty - Check other directories")
//            self.completedTransfer()
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
//                self.sendingBundle = false
//                self.counter = 0
//            }
//
//        } else {
//
//            guard let selectedUrl = files.first else {
//                print("No such file exist here")
//                return
//            }
//
//            guard let data = try? Data(contentsOf: URL(fileURLWithPath: selectedUrl.deletingPathExtension().lastPathComponent, relativeTo: selectedUrl).appendingPathExtension(selectedUrl.pathExtension)) else {
//                print("File not found")
//                return
//            }
//
//            if selectedUrl.deletingLastPathComponent().lastPathComponent == "CircuitPython 7.x"{
//
//                print("Selected Path: \(selectedUrl.path)")
//
//                var tempURL = selectedUrl.pathComponents
//                //tempURL.removeFirst(142)
//
//                //  var tempURL = subdirectory.pathComponents
//
//                tempURL.removeFirst(12)
//                let joined = tempURL.joined(separator: "/")
//                print("FIXED PATHxx:\(joined)")
//
//
//
//                print("Updated Path:\(joined)")
//
//                self.writeFileCommand(path: joined, data: data) { result in
//                    switch result {
//
//                    case .success(_):
//                        copiedFiles.removeFirst()
//                        self.transferFiles(files: copiedFiles)
//
//                    case .failure(_):
//                        self.displayErrorMessage()
//                    }
//                }
//            }
//
//            else if selectedUrl.deletingLastPathComponent().lastPathComponent == "lib" {
//
//
//
//                var tempURL = selectedUrl.pathComponents
//                tempURL.removeFirst(12)
//                let joined = tempURL.joined(separator: "/")
//                print("FIXED PATHxx:\(joined)")
//
//
//
//                print("Updated Path:\(joined)")
//
//
//
//                writeFileCommand(path: joined, data: data) { result in
//                    switch result {
//                    case .success(_):
//                        copiedFiles.removeFirst()
//                        self.transferFiles(files: copiedFiles)
//
//                    case .failure(_):
//                        self.displayErrorMessage()
//                    }
//                }
//            } else {
//
//                var tempURL = selectedUrl.pathComponents
//                tempURL.removeFirst(12)
//                let joined = tempURL.joined(separator: "/")
//                print("FIXED PATHxx:\(joined)")
//
//
//
//                print("Updated Path:\(joined)")
//
//
//                writeFileCommand(path: joined, data: data) { result in
//                    switch result {
//                    case .success(_):
//                        copiedFiles.removeFirst()
//                        self.transferFiles(files: copiedFiles)
//                    case .failure(_):
//                        self.displayErrorMessage()
//
//                    }
//                }
//            }
//        }
//
//        DispatchQueue.main.async {
//            self.sendingBundle = true
//        }
//    }
//
//
//
//    // MARK: System
//
//    struct TransmissionProgress {
//        var description: String
//        var transmittedBytes: Int
//        var totalBytes: Int?
//
//        init (description: String) {
//            self.description = description
//            transmittedBytes = 0
//        }
//    }
//
//    @Published var transmissionProgress: TransmissionProgress?
//
//    struct TransmissionLog: Equatable {
//        enum TransmissionType: Equatable {
//            case read(data: Data)
//            case write(size: Int)
//            case delete
//            case listDirectory(numItems: Int?)
//            case makeDirectory
//            case error(message: String)
//        }
//        let type: TransmissionType
//
//        var description: String {
//            let modeText: String
//            switch self.type {
//            case .read(let data): modeText = "Received \(data.count) bytes"
//            case .write(let size): modeText = "Sent \(size) bytes"
//            case .delete: modeText = "Deleted file"
//            case .listDirectory(numItems: let numItems): modeText = numItems != nil ? "Listed directory: \(numItems!) items" : "Listed nonexistent directory"
//            case .makeDirectory: modeText = "Created directory"
//            case .error(let message): modeText = message
//            }
//
//            return modeText
//        }
//    }
//    @Published var lastTransmit: TransmissionLog? =  TransmissionLog(type: .write(size: 334))
//
//    enum ActiveAlert: Identifiable {
//        case error(error: Error)
//
//        var id: Int {
//            switch self {
//            case .error: return 1
//            }
//        }
//    }
//    @Published var activeAlert: ActiveAlert?
//
//    // Data
//    private let bleManager = BleManager.shared
//
//
//    override init() {
//
//    }
//
//    // MARK: - Setup
//    func onAppear() {
//        //registerNotifications(enabled: true)
//        //setup(fileTransferClient: fileTransferClient)
//    }
//
//    func onDissapear() {
//        //registerNotifications(enabled: false)
//    }
//
//    func setup(fileTransferClient: FileTransferClient?) {
//        guard let fileTransferClient = fileTransferClient else {
//            DLog("Error: undefined fileTransferClient")
//            return
//        }
//
//        self.fileTransferClient = fileTransferClient
//
//    }
//
//    // MARK: - Actions
//
//    func readFile(filename: String) {
//        startCommand(description: "Reading \(filename)")
//        readFileCommand(path: filename) { [weak self] result in
//            guard let self = self else { return }
//
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let data):
//                    self.lastTransmit = TransmissionLog(type: .read(data: data))
//                    let str = String(decoding: data, as: UTF8.self)
//                    print("Read: \(str)")
//                    self.bootUpInfo = str
//
//                case .failure(let error):
//                    self.lastTransmit = TransmissionLog(type: .error(message: error.localizedDescription))
//                }
//
//                self.endCommand()
//            }
//        }
//    }
//
//    func writeFile(filename: String, data: Data) {
//        startCommand(description: "Writing \(filename)")
//        writeFileCommand(path: filename, data: data) { [weak self] result in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    self.lastTransmit = TransmissionLog(type: .write(size: data.count))
//
//                case .failure(let error):
//                    self.lastTransmit = TransmissionLog(type: .error(message: error.localizedDescription))
//                }
//
//                self.endCommand()
//            }
//        }
//    }
//
//    func listDirectory(filename: String) {
//        let directory = FileTransferPathUtils.pathRemovingFilename(path: filename)
//
//        startCommand(description: "List directory")
//
//        listDirectoryCommand(path: directory) { [weak self] result in
//            guard let self = self else { return }
//
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let entries):
//                    self.lastTransmit = TransmissionLog(type: .listDirectory(numItems: entries?.count))
//
//                case .failure(let error):
//                    self.lastTransmit = TransmissionLog(type: .error(message: error.localizedDescription))
//                }
//
//                self.endCommand()
//            }
//        }
//    }
//
//    func deleteFile(filename: String) {
//        startCommand(description: "Deleting \(filename)")
//
//        deleteFileCommand(path: filename) { [weak self]  result in
//            guard let self = self else { return }
//
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    self.lastTransmit = TransmissionLog(type: .delete)
//
//                case .failure(let error):
//                    self.lastTransmit = TransmissionLog(type: .error(message: error.localizedDescription))
//                }
//
//                self.endCommand()
//            }
//        }
//    }
//
//    func makeDirectory(path: String) {
//        // Make sure that the path ends with the separator
//        guard let fileTransferClient = fileTransferClient else { DLog("Error: makeDirectory called with nil fileTransferClient"); return }
//        DLog("makeDirectory: \(path)")
//        isTransmiting = true
//        fileTransferClient.makeDirectory(path: path) { [weak self] result in
//            guard let self = self else { return }
//
//            DispatchQueue.main.async {
//                self.isTransmiting = false
//
//                switch result {
//                case .success(_ /*let date*/):
//                    print("Success! Path made!")
//
//                case .failure(let error):
//                    DLog("makeDirectory \(path) error: \(error)")
//                }
//            }
//        }
//    }
//
//    // MARK: - Command Status
//    private func startCommand(description: String) {
//        transmissionProgress = TransmissionProgress(description: description)    // Start description with no progress 0 and undefined Total
//        lastTransmit = nil
//    }
//
//    private func endCommand() {
//        transmissionProgress = nil
//    }
//
//    private func readFileCommand(path: String, completion: ((Result<Data, Error>) -> Void)?) {
//        guard let fileTransferClient = fileTransferClient else { return }
//
//        DLog("start readFile \(path)")
//        fileTransferClient.readFile(path: path, progress: { [weak self] read, total in
//            DLog("reading progress: \( String(format: "%.1f%%", Float(read) * 100 / Float(total)) )")
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.transmissionProgress?.transmittedBytes = read
//                self.transmissionProgress?.totalBytes = total
//            }
//        }) { result in
//            if AppEnvironment.isDebug {
//                switch result {
//                case .success(let data):
//                    DLog("readFile \(path) success. Size: \(data.count)")
//
//                case .failure(let error):
//                    DLog("readFile  \(path) error: \(error)")
//                }
//            }
//
//            completion?(result)
//        }
//    }
//
//    private func writeFileCommand(path: String, data: Data, completion: ((Result<Date?, Error>) -> Void)?) {
//        guard let fileTransferClient = fileTransferClient else { completion?(.failure(ProjectViewError.fileTransferUndefined)); return }
//        counter += 1
//        DLog("start writeFile \(path)")
//        fileTransferClient.writeFile(path: path, data: data, progress: { [weak self] written, total in
//            DLog("writing progress: \( String(format: "%.1f%%", Float(written) * 100 / Float(total)) )")
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.transmissionProgress?.transmittedBytes = written
//                self.transmissionProgress?.totalBytes = total
//            }
//        }) { result in
//            if AppEnvironment.isDebug {
//                switch result {
//                case .success:
//                    DLog("writeFile \(path) success. Size: \(data.count)")
//
//                case .failure(let error):
//                    DLog("writeFile  \(path) error: \(error)")
//                }
//            }
//
//            completion?(result)
//        }
//    }
//
//    private func deleteFileCommand(path: String, completion: ((Result<Void, Error>) -> Void)?) {
//        guard let fileTransferClient = fileTransferClient else { completion?(.failure(ProjectViewError.fileTransferUndefined)); return }
//
//        DLog("start deleteFile \(path)")
//        fileTransferClient.deleteFile(path: path) { result in
//            if AppEnvironment.isDebug {
//                switch result {
//                case .success:
//                    DLog("deleteFile \(path) success")
//
//                case .failure(let error):
//                    DLog("deleteFile  \(path) error: \(error)")
//                }
//            }
//
//            completion?(result)
//        }
//    }
//
//    private func listDirectoryCommand(path: String, completion: ((Result<[BlePeripheral.DirectoryEntry]?, Error>) -> Void)?) {
//        guard let fileTransferClient = fileTransferClient else { completion?(.failure(ProjectViewError.fileTransferUndefined)); return }
//
//        DLog("start listDirectory \(path)")
//        fileTransferClient.listDirectory(path: path) { result in
//            switch result {
//            case .success(let entries):
//                DLog("listDirectory \(path). \(entries != nil ? "Entries: \(entries!.count)" : "Directory does not exist")")
//
//            case .failure(let error):
//                DLog("listDirectory \(path) error: \(error)")
//            }
//
//            completion?(result)
//        }
//    }
//
//    private func makeDirectoryCommand(path: String, completion: ((Result<Date?, Error>) -> Void)?) {
//        guard let fileTransferClient = fileTransferClient else { completion?(.failure(ProjectViewError.fileTransferUndefined)); return }
//
//        DLog("start makeDirectory \(path)")
//        fileTransferClient.makeDirectory(path: path) { result in
//            switch result {
//            case .success(_ /*let date*/):
//                DLog("makeDirectory \(path)")
//
//            case .failure(let error):
//                DLog("makeDirectory \(path) error: \(error)")
//            }
//
//            completion?(result)
//        }
//    }
//
}
