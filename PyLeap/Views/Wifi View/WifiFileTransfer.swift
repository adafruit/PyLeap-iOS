//
//  WifiFileTransfer.swift
//  PyLeap
//
//  Created by Trevor Beaton on 9/13/22.
//
import Foundation
import SwiftUI

struct WifiCPVersion {
    static var versionNumber = 0
}

class WifiFileTransfer: ObservableObject {
    
    @Published var wifiTransferService = WifiTransferService()
    
    // File Manager Data
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    @Published var projectDownloaded = false
    @Published var failedProjectLaunch = false
    @Published var transferError = false

    @Published var downloadState: DownloadState = .idle
    
    var manager = FileManager.default
    
    var projectDirectories: [URL] = []
    var projectFiles: [URL] = []
    
    
    @Published var counter = 0
    @Published var numOfFiles = 0
    
    var projectName: String?
    @ObservedObject var downloadModel = DownloadViewModel()
    
    func printArray(array: [Any]) {
        
        for i in array {
            print("\(i)")
        }
    }
    
    func restFileCounter() {
        DispatchQueue.main.async {
            self.counter = 0
            self.numOfFiles = 0
        }
        
    }
    
    func appendDirectories(_ url: URL) {
        projectDirectories.append(url)
    }
    
    func appendRegularFiles(_ url: URL) {
        projectFiles.append(url)
    }
    
    func removeDirectoryAndFiles() {
        projectDirectories.removeAll()
        projectFiles.removeAll()
    }
    
    
    init() {
        registerNotification(enabled: true)
    }
    
    
    
    private weak var wifiDownloadComplete: NSObjectProtocol?
    private weak var didEncounterTransferError: NSObjectProtocol?
    private weak var downloadErrorDidOccur: NSObjectProtocol?
    
    private func registerNotification(enabled: Bool) {
        print("\(#function) @Line: \(#line)")
        
        let notificationCenter = NotificationCenter.default
        
        if enabled {
            //    public static let wifiDownloadComplete = Notification.Name(kPrefix+".wifiDownloadComplete")
            
            NotificationCenter.default.addObserver(self, selector: #selector(zipSuccess(_:)), name: .wifiDownloadComplete,object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(displayErrorMessage(_:)), name: .didEncounterTransferError,object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(projectDownloadDidFail(_:)), name: .downloadErrorDidOccur,object: nil)
            
            
        } else {
            if let testObserver = wifiDownloadComplete {notificationCenter.removeObserver(testObserver)}
        }
    }
    
    @objc func zipSuccess(_ notification: NSNotification) {
        print("Zip - Success.")
        print("\(#function) @Line: \(#line)")
        if let projectInfo = notification.userInfo as Dictionary? {
            if let title = projectInfo["projectTitle"] as? String, let link = projectInfo["projectLink"] as? String {
                testFileExistance(for: title, bundleLink: link)
            }
        }
    }
    
    
    @objc func displayErrorMessage(_ notification: Notification) {
        print("displayErrorMessage occurred.")
     
        
    }
    
    @objc func projectDownloadDidFail(_ notification: Notification) {
        DispatchQueue.main.async {
            self.transferError = true
            self.downloadState = .failed
        }
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.downloadState = .idle
            self.restFileCounter()
        }
    }
    
    
    
    
    func getProjectForSubClass(nameOf project: String) {
        
        if let enumerator = FileManager.default.enumerator(at: directoryPath, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            // for case condition: Only process URLs
            for case let fileURL as URL in enumerator {
                
                if fileURL.lastPathComponent == project {
                    failedProjectLaunch = false
                    projectDownloaded = true
                    print(#function)
                    print("Searching for... \(project)")
                    print("URL Path: \(fileURL.path)")
                    print("URL : \(fileURL)")
                    
                    return
                    
                } else {
                    failedProjectLaunch = true
                    projectDownloaded = false
                    print("Project was not found...")
                    
                }
            }
        }
    }
    
    func testFileExistance(for project: String, bundleLink: String) {
        print("\(#function) @Line: \(#line)")
        //removeFileArrayElements()
        
        projectName = project
        
        DispatchQueue.main.async {
            self.downloadState = .transferring
        }
        
        let nestedFolderURL = directoryPath.appendingPathComponent(project)
        
        if manager.fileExists(atPath: nestedFolderURL.relativePath) {
            print("Exist")
                        
            removeDirectoryAndFiles()
            startFileTransfer(url: nestedFolderURL)
            
        } else {
            print("Does not exist - downloading \(project)")
            
            downloadModel.trueDownload(useProject: bundleLink, projectName: project)
        }
    }
    
    

    
    
    
    
    
    
    func filesDownloaded(url: URL) {
        // removeFileArrayElements()
        
        var files = [URL]()
        // Returns a directory enumerator object that can be used to perform a deep enumeration of the directory at the specified URL.
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            // for case condition: Only process URLs
            for case let fileURL as URL in enumerator {
                
            }
            
            
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
                        appendDirectories(fileURL)
                        
                    }
                    
                } else {
                    regularFileUrls.append(fileURL)
                    appendRegularFiles(fileURL)
                }
            }
        }
        
        newMakeDirectory(directoryArray: filterOutCPDirectories(urls: projectDirectories), regularFilesArray: filterOutCPDirectories(urls: projectFiles))
        
    }
    
    
    
    
    func filterOutCPDirectories(urls: [URL]) -> [URL] {
        // Removes - CircuitPython 8.x directory at the lastPathComponent
        let removingCP8FromArray = urls.filter {
            $0.lastPathComponent != ("CircuitPython 8.x")
        }
        
        // Removes - CircuitPython 7.x directory at the lastPathComponent
        let removingCP7FromArray = removingCP8FromArray.filter {
            $0.lastPathComponent != ("CircuitPython 7.x")
        }
        
        if WifiCPVersion.versionNumber == 8 {
            let listForCurrentCPVersion = removingCP7FromArray.filter {
                !$0.absoluteString.contains("CircuitPython%207.x")
                
            }
            return listForCurrentCPVersion
        }
        
        if WifiCPVersion.versionNumber == 7 {
            let listForCurrentCPVersion = removingCP7FromArray.filter {
                !$0.absoluteString.contains("CircuitPython%208.x")
                
            }
            return listForCurrentCPVersion
        }
        
        
        
        return removingCP7FromArray
        
    }
    
    func removeNonCPDirectories(urls: [URL]) -> [URL] {
        var mutableURLList = urls
        var outgoingArray = [URL]()
        
        for i in mutableURLList {
            if i.pathComponents.contains("CircuitPython 7.x") || i.pathComponents.contains("CircuitPython 8.x") {
                print(i.absoluteString)
                outgoingArray.append(i)
            } else {
                print("Removed non-CP Directories: \(i)")
            }
            
        }
        
        return outgoingArray
    }
    
    
    
    func newMakeDirectory(directoryArray: [URL], regularFilesArray: [URL]) {
        print("==============Start=================\n")
        
        print("Count: \(directoryArray.count)")
        var recursiveArray = removeNonCPDirectories(urls: directoryArray)
        
        if recursiveArray.isEmpty {
            print("newMakeDirectory is empty!")
            
            var tempArray = removeNonCPDirectories(urls: regularFilesArray)
            
            DispatchQueue.main.async {
                self.numOfFiles = tempArray.count

            }
                
            
            
            print("tempArry set numOfFiles to : \(self.numOfFiles)")
            
            
            makeFile(files: tempArray)
            
        } else {
            
            print("Input URL: \(recursiveArray.first!)")
            var tempPath = recursiveArray.first!.pathComponents
            
            
            if tempPath.contains("CircuitPython 7.x") {
                var indexOfCP = 0
                
                print("Found CircuitPython 8.x")
                
                indexOfCP = recursiveArray[0].pathComponents.firstIndex(of: "CircuitPython 7.x")!
                
                tempPath.removeSubrange(0...indexOfCP)
                
                let joined = tempPath.joined(separator: "/")
                print("Outgoing path:\(joined)")
                
                print(indexOfCP)
                print(recursiveArray[0].pathComponents.count)
                
                wifiTransferService.putDirectory(directoryPath: joined) { result in
                    
                    switch result {
                        
                    case .success(let consent):
                        print("Successful")
                        
                        recursiveArray.removeFirst()
                        self.newMakeDirectory(directoryArray: recursiveArray, regularFilesArray: regularFilesArray)
                        
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }
                
            }
            
            if tempPath.contains("CircuitPython 8.x") {
                var indexOfCP = 0
                
                print("For \(recursiveArray[0].absoluteString)")
                
                print("Count \(tempPath.count)")
                
                
                
                indexOfCP = recursiveArray[0].pathComponents.firstIndex(of: "CircuitPython 8.x")!
                print("indexOfCP \(indexOfCP)")
                print(tempPath)
                tempPath.removeSubrange(0...indexOfCP)
                
                let joined = tempPath.joined(separator: "/")
                print("Outgoing path:\(joined)")
                print(indexOfCP)
                print(recursiveArray[0].pathComponents.count)
                
                wifiTransferService.putDirectory(directoryPath: joined) { result in
                    
                    switch result {
                        
                    case .success(let consent):
                        print("Successful")
                        recursiveArray.removeFirst()
                        self.newMakeDirectory(directoryArray: recursiveArray, regularFilesArray: regularFilesArray)
                        
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }
                
                
            }
            
        }
        
    }
    
    
    
    
    func filterOutCPDirectories(incomingArray: [URL]) -> [URL] {
        
        for i in incomingArray {
            print("incoming Array \(i.absoluteString)")
        }
        
        let listWithoutCP8Folder = incomingArray.filter {
            $0.lastPathComponent != ("CircuitPython 8.x")
        }
        
        let listWithoutCP7Folder = listWithoutCP8Folder.filter {
            $0.lastPathComponent != ("CircuitPython 7.x")
        }
        
        return listWithoutCP7Folder
        
    }
    
    
    
    func makeFileString(url: URL) -> String {
        var indexOfCP = 0
        var tempPathComponents = url.pathComponents
        print("Incoming URL for makeFileString: \(url.absoluteString)")
        
        
        if WifiCPVersion.versionNumber == 7 {
            
            indexOfCP = tempPathComponents.firstIndex(of: "CircuitPython 7.x")!
            tempPathComponents.removeSubrange(0...indexOfCP)
            var joinedArrayPath = tempPathComponents.joined(separator: "/")
            print("\(#function) @Line: \(#line)")
            print("Outgoing makeFileString: \(joinedArrayPath) for CP 7")
            return joinedArrayPath
        }
        
        if WifiCPVersion.versionNumber == 8 {
            indexOfCP = tempPathComponents.firstIndex(of: "CircuitPython 8.x")!
            tempPathComponents.removeSubrange(0...indexOfCP)
            var joinedArrayPath = tempPathComponents.joined(separator: "/")
            print("\(#function) @Line: \(#line)")
            print("Outgoing makeFileString: \(joinedArrayPath) for CP 8")
            return joinedArrayPath
        }
        
        return ""
    }
    
    func completedTransfer() {
        print("Is main queue: \(Thread.isMainThread)")
        DispatchQueue.main.async {
            print("\(#function) @Line: \(#line)")
            self.downloadState = .complete
            self.counter = 0
            self.numOfFiles = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            print("\(#function) @Line: \(#line)")
            self.downloadState = .idle
            
        }
    }
    
    func checkForExistingFilesOnBoard(url: URL) -> String {
        var indexOfCP = 0
        var tempPathComponents = url.pathComponents
        
        if WifiCPVersion.versionNumber == 7 {
            
            indexOfCP = tempPathComponents.firstIndex(of: "CircuitPython 7.x")!
            tempPathComponents.removeSubrange(0...indexOfCP)
            tempPathComponents.removeLast()

            var pathWithSeparator = tempPathComponents.joined(separator: "/") + String("/")
            print("\(#function) @Line: \(#line)")
            print("Outgoing makeFileString: \(pathWithSeparator) for CP 7")
            return pathWithSeparator
        }
        
        if WifiCPVersion.versionNumber == 8 {
            indexOfCP = tempPathComponents.firstIndex(of: "CircuitPython 8.x")!
            tempPathComponents.removeSubrange(0...indexOfCP)
            tempPathComponents.removeLast()
            var pathWithSeparator = tempPathComponents.joined(separator: "/") + String("/")
            
            print("\(#function) @Line: \(#line)")
            print("Outgoing makeFileString: \(pathWithSeparator) for CP 8")
            return pathWithSeparator
        }
        
        
        return ""
    }
    
    
    func makeFile(files: [URL]) {
        print("=======makeFile=========")
        print("Incoming files for makeFile function\n")
        printArray(array: files)
        var copiedArray = files
        
        if copiedArray.isEmpty {
            completedTransfer()
            print("Transfer Complete")
            print("Copied Array: \(copiedArray)")
            print("Files Array: \(files)")
            print("Counter: \(counter)")
            print("\(#function) @Line: \(#line)")
            
            print("Status: \(downloadState)")
            

        } else {

            guard let data = try? Data(contentsOf: URL(string: copiedArray.first!.absoluteString)!) else {
                print("File not found")
                return
            }
            // || copiedArray.first?.lastPathComponent == "README.txt"
            if copiedArray.first?.lastPathComponent == "code.py" {
                
                wifiTransferService.sendPutRequest(fileName: copiedArray.first!.lastPathComponent , body: data) { result in
                    switch result {
                        
                    case .success(_):
                        print("Success\n")
                        
                        print("Removing: \(copiedArray.first!.lastPathComponent)\n")
                        
                        DispatchQueue.main.async {
                            self.counter += 1
                        }
                        
                        copiedArray.removeFirst()
                        self.makeFile(files: copiedArray)
                        
                    case .failure(_):
                        print("Failed to write")
                    }
                }
            } else {
                
                print("ELSE")
                
                guard let data = try? Data(contentsOf: URL(string: copiedArray.first!.absoluteString)!) else {
                    print("File not found")
                    return
                }
                
                print("Checking for URL: \(copiedArray.first?.lastPathComponent)")
                
                wifiTransferService.getRequestForFileCheck(read: checkForExistingFilesOnBoard(url: copiedArray.first!.absoluteURL)) { success in
                    
                    if success.contains(where: { name in name.name == copiedArray.first?.lastPathComponent }) {
                        print("Exists in the array")
                        
                        DispatchQueue.main.async {
                            self.counter += 1
                        }
                        
                        copiedArray.removeFirst()
                        self.makeFile(files: copiedArray)
                        
                    } else {
                        
                        self.wifiTransferService.sendPutRequest(fileName: self.makeFileString(url: copiedArray.first!), body: data) { result in
                            switch result {
                                
                            case .success(_):
                                print("Successful Write for: \(copiedArray.first!.lastPathComponent)\n")

                                DispatchQueue.main.async {
                                    self.counter += 1
                                    print("Current counter: \(self.counter)")
                                }
                                copiedArray.removeFirst()
                                self.makeFile(files: copiedArray)
                            case .failure(_):
                                print("Failed to write")
                            }
                        }
                        
                        
                    }
                }
                
            }
            
        }
        
    }
    
    
    
}
