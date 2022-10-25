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
    @Published var fileArray: [ContentFile] = []
    @Published var contentList: [URLData] = []
    
    @Published var projectDownloaded = false
    @Published var failedProjectLaunch = false
    
    @Published var downloadState: DownloadState = .idle
    
    var manager = FileManager.default
    
    var projectDirectories: [URL] = []
    var projectFiles: [URL] = []
    
    var returnedArray = [[String]]()
    
    @Published var counter = 0
    @Published var numOfFiles = 0
    
    var projectName: String?
    @ObservedObject var downloadModel = DownloadViewModel()
    
    func removeFileArrayElements() {
        fileArray.removeAll()
    }
    
    func appendFileArrayElements(fileContent: ContentFile) {
        fileArray.append(fileContent)
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
    
    
    private func registerNotification(enabled: Bool) {
        print("\(#function) @Line: \(#line)")
        
        let notificationCenter = NotificationCenter.default
        
        if enabled {
            //    public static let wifiDownloadComplete = Notification.Name(kPrefix+".wifiDownloadComplete")
            
            NotificationCenter.default.addObserver(self, selector: #selector(zipSuccess(_:)), name: .wifiDownloadComplete,object: nil)
            
            
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
    
    
    func projectValidation(nameOf project: String) {
        print("getProjectURL called")
        
        if let enumerator = FileManager.default.enumerator(at: directoryPath, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            // for case condition: Only process URLs
            for case let fileURL as URL in enumerator {
                
                do {
                    print("Starting a loop...")
                    
                    if fileURL.lastPathComponent == project {
                        
                        print("Searching for... \(project)")
                        
                        do {
                            print(#function)
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
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    
    
    
    
    func filesDownloaded(url: URL) {
        removeFileArrayElements()
        removeDirectoryAndFiles()
        var files = [URL]()
        // Returns a directory enumerator object that can be used to perform a deep enumeration of the directory at the specified URL.
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            // for case condition: Only process URLs
            for case let fileURL as URL in enumerator {
                
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey, .addedToDirectoryDateKey,.isDirectoryKey])
                    
                    
                    print("FILTERED INCOMING FILE: \(fileURL.path)")
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
                    
                    
                } catch { print(error, fileURL) }
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
                        appendDirectories(fileURL)
                        
                    }
                    
                } else {
                    regularFileUrls.append(fileURL)
                    appendRegularFiles(fileURL)
                }
            }
        }
        
        //projectDirectories.removeFirst()
        
        //   print(projectDirectories)
        
        
        
        // newMakeDirectory(directoryArray: projectDirectories, regularFilesArray: projectFiles)
        
        // pathManipulation(arrayOfAny: filterOutCPDirectories(fileArray: projectDirectories), fileArray: regularFileUrls)
        
        newMakeDirectory(directoryArray: filterOutCPDirectories(urls: projectDirectories), regularFilesArray: filterOutCPDirectories(urls: projectFiles))
        
        
        // print("Out going \(removeNonCPDirectories(urls: projectDirectories))")
        
        
    }
    
    func makeDirectoryStrings(url: URL) {
        var indexOfCP = 0
        var tempPathComponents = url.pathComponents
        print(tempPathComponents)
        
        if tempPathComponents.contains("CircuitPython") {
            print("YES")
        } else {
            print("NO")
        }
    }
    
    
    func makeDirectoryString (url: URL) -> String {
        var indexOfCP = 0
        var tempPathComponents = url.pathComponents
        
        
        
        
        if sharedBootinfo.contains("CircuitPython 7") {
            indexOfCP = tempPathComponents.firstIndex(of: "CircuitPython 7.x")!
            tempPathComponents.removeSubrange(0...indexOfCP)
            var joinedArrayPath = tempPathComponents.joined(separator: "/")
            print("Outgoing String: \(joinedArrayPath)")
            return joinedArrayPath
        }
        
        
        return ""
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
        
        //condition
        // With Circuit Python version number "8"
        // Will need to filter out the string: Circuit Python + version number
        // Ex: If CP version is 8 - Filter out 7
        // 8 must remain
        
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
    
    //    func makeDirectory(directoryArray: [URL], regularFilesArray: [URL]) {
    //        var indexOfCP = 0
    //        var recursiveArray = directoryArray
    //
    //        print(#function)
    //
    //        var tempPath = recursiveArray[0]
    //        let joined = tempPath.joined(separator: "/")
    //        print("Outgoing path:\(joined)")
    //
    //
    //        if recursiveArray.isEmpty {
    //
    //            print("Start File Transfer!")
    //
    //        } else {
    //
    //            wifiTransferService.putDirectory(directoryPath: joined) { result in
    //
    //                switch result {
    //
    //                case .success(let consent):
    //                    print("Successful")
    //                    recursiveArray.removeFirst()
    //                    self.makeDirectory(directoryArray: recursiveArray, regularFilesArray: regularFilesArray)
    //
    //                case .failure(let error):
    //                    print("Error: \(error)")
    //                }
    //            }
    //
    //        }
    //
    //
    //
    //    }
    
    
    
    
    func newMakeDirectory(directoryArray: [URL], regularFilesArray: [URL]) {
        print("==============Start=================\n")
        
        print("Count: \(directoryArray.count)")
        var recursiveArray = removeNonCPDirectories(urls: directoryArray)
        
        if recursiveArray.isEmpty {
            print("newMakeDirectory is empty!")
            
            var tempArray = removeNonCPDirectories(urls: regularFilesArray)
            
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
            
            //                wifiTransferService.putDirectory(directoryPath: joined) { result in
            //
            //                    switch result {
            //
            //                    case .success(let consent):
            //                        print("Successful")
            //                        recursiveArray.removeFirst()
            //                        self.makeDirectory(directoryArray: recursiveArray, regularFilesArray: regularFilesArray)
            //
            //                    case .failure(let error):
            //                        print("Error: \(error)")
            //                    }
            //                }
            
            //                var indexOfCP = 0
            //                print("\(#function) @Line: \(#line)")
            //                print("For \(tempPath)")
            //
            //                print("Count \(tempPath.count)")
            //
            //                indexOfCP = tempPath.firstIndex(of: "Documents")!
            //
            //                print("indexOfCP \(indexOfCP)")
            //                print(tempPath)
            //
            //
            //                tempPath.removeSubrange(0...indexOfCP)
            //
            //                let joined = tempPath.joined(separator: "/")
            //                print("Outgoing path:\(joined)")
            //                print(indexOfCP)
            //                print(recursiveArray[0].pathComponents.count)
            //                recursiveArray.removeFirst()
            //                newMakeDirectory(directoryArray: recursiveArray, regularFilesArray: regularFilesArray)
            //
        }
        
    }
    
    
    
    
    
    
    
    //    func filterCPVersion(incomingArray: [URL]) -> [URL] {
    //        print("project name \(projectName)")
    //
    //
    //        for i in incomingArray {
    //            print("incoming Array \(i.absoluteString)")
    //        }
    //
    //        let listWithoutCP8Folder = incomingArray.filter {
    //            $0.lastPathComponent != ("CircuitPython 8.x")
    //        }
    //
    //        let listWithoutCP7Folder = listWithoutCP8Folder.filter {
    //            $0.lastPathComponent != ("CircuitPython 7.x")
    //        }
    //
    //
    //
    //        if sharedBootinfo.contains("CircuitPython 8") {
    //            let listForCurrentCPVersion = listWithoutCP7Folder.filter {
    //                !$0.absoluteString.contains("CircuitPython%207.x")
    //            }
    //
    //            for i in listForCurrentCPVersion {
    //                print("listForCurrentCPVersion :- \(i.absoluteString)")
    //            }
    //
    //            return listForCurrentCPVersion
    //
    //        }
    //
    //        if sharedBootinfo.contains("CircuitPython 7") {
    //
    //            let listForCurrentCPVersion = listWithoutCP7Folder.filter {
    //                !$0.absoluteString.contains("CircuitPython%208.x")
    //            }
    //
    //            for i in listForCurrentCPVersion {
    //                print("listForCurrentCPVersion :- \(i.absoluteString)")
    //            }
    //            return listForCurrentCPVersion
    //        }
    //        return listWithoutCP7Folder
    //    }
    
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
    
    
    
    func pathManipulation(arrayOfAny: [URL], fileArray: [URL]) {
        print(#function)
        var indexOfCP = 0
        
        
        print("RETURNED PATHS: \(returnedArray)")
        
        var tempArray = arrayOfAny
        
        if arrayOfAny.isEmpty {
            // Continue
            print("Done!")
            validateDirectory(directoryArray: returnedArray, fileArray: fileArray)
            
        } else {
            
            var tempPath = arrayOfAny[0].pathComponents
            
            if arrayOfAny[0].pathComponents.contains("CircuitPython 7.x") {
                
                print("Found CircuitPython 8.x")
                
                indexOfCP = arrayOfAny[0].pathComponents.firstIndex(of: "CircuitPython 7.x")!
                
                tempPath.removeSubrange(0...indexOfCP)
                
                tempArray.removeFirst()
                
                returnedArray.append(tempPath)
                
                pathManipulation(arrayOfAny: tempArray, fileArray: fileArray)
            }
            
            if arrayOfAny[0].pathComponents.contains("CircuitPython 8.x") {
                print("Found CircuitPython 7.x")
                indexOfCP = arrayOfAny[0].pathComponents.firstIndex(of: "CircuitPython 8.x")!
                
                tempPath.removeSubrange(0...indexOfCP)
                
                tempArray.removeFirst()
                
                returnedArray.append(tempPath)
                pathManipulation(arrayOfAny: tempArray, fileArray: fileArray)
                
            }
            
        }
        
    }
    
    
    
    func validateDirectory(directoryArray: [[String]], fileArray: [URL]) {
        print(#function)
        // Use Recursion to go through each directory
        if self.returnedArray.isEmpty {
            print("No directories left in queue")
            print("Start file transfer...")
            // self.transferFiles(files: fileArray)
            
            makeFile(files: fileArray)
        } else {
            
            guard let firstDirectory = directoryArray.first else {
                return
            }
            print("Array count \(returnedArray.count)")
            //    makeDirectory(fileArray: fileArray)
            
        }
        
    }
    
    func makeFileString(url: URL)-> String {
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
        
        
        
        DispatchQueue.main.async {
            self.downloadState = .complete
            self.numOfFiles = 0
          //  self.contentCommands.counter = 0
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.downloadState = .idle
            
        }
    }
    
    func makeFile(files: [URL]) {
        print(#function)
        
        for i in files {
            print("makeFile: \(i.absoluteString)")
        }
        
        
        
        var copiedArray = files
        
        if copiedArray.isEmpty {
            print("Transfer Complete")
           completedTransfer()
            
        } else {
            
            DispatchQueue.main.async {
                self.counter += 1
            }
            
            guard let data = try? Data(contentsOf: URL(string: copiedArray.first!.absoluteString)!) else {
                print("File not found")
                return
            }
            
            if copiedArray.first?.lastPathComponent == "code.py" || copiedArray.first?.lastPathComponent == "README.txt" {
                
                wifiTransferService.sendPutRequest(fileName: copiedArray.first!.lastPathComponent , body: data) { result in
                    switch result {
                        
                    case .success(_):
                        print("Success")
                        
                        copiedArray.removeFirst()
                        self.makeFile(files: copiedArray)
                    case .failure(_):
                        print("Failed to write")
                    }
                }
        }
            else {
                
                guard let data = try? Data(contentsOf: URL(string: copiedArray.first!.absoluteString)!) else {
                    print("File not found")
                    return
                }
                
                print("Outgoing sendPutRequest \(copiedArray.first!)")
                print("Outgoing sendPutRequest \(makeFileString(url: copiedArray.first!))")

                wifiTransferService.sendPutRequest(fileName: makeFileString(url: copiedArray.first!), body: data) { result in
                    switch result {

                    case .success(_):
                        print("Success")

                        copiedArray.removeFirst()
                        self.makeFile(files: copiedArray)
                    case .failure(_):
                        print("Failed to write")
                    }
                }
                
                
                
                //                if copiedArray.first!.pathComponents.contains("CircuitPython 7.x") {
                //                    print("Found CircuitPython 7.x")
                //
                //                    var indexOfCP = 0
                //
                //                    indexOfCP = copiedArray[0].pathComponents.firstIndex(of: "CircuitPython 7.x")!
                //
                //                    tempPath.removeSubrange(0...indexOfCP)
                //
                //                    let joined = tempPath.joined(separator: "/")
                //
                //
                //
                //                    if (copiedArray[0].pathExtension == "py") || (copiedArray[0].pathExtension == "txt") {
                //
                //                        wifiTransferService.putRequest(fileName: joined, fileContent: data) { result in
                //                            switch result {
                //
                //                            case .success(let content):
                //                                copiedArray.removeFirst()
                //                                self.makeFile(files: copiedArray)
                //                            case .failure(let error):
                //                                print("Failed write")
                //                            }
                //                        }
                //
                //                    } else {
                //
                //                        wifiTransferService.sendPutRequest(fileName: joined, body: data) { result in
                //                            switch result {
                //
                //                            case .success(_):
                //                                print("Success")
                //
                //                                copiedArray.removeFirst()
                //                                self.makeFile(files: copiedArray)
                //                            case .failure(_):
                //                                print("Failed to write")
                //                            }
                //                        }
                //
                //                    }
                //
                //
                //
                //                }
                
                
                
                //                if copiedArray[0].pathComponents.contains("CircuitPython 8.x") {
                //                    print("Found CircuitPython 8.x")
                //                    var tempPath = copiedArray[0].pathComponents
                //
                //                    var indexOfCP = Int()
                //
                //                    indexOfCP = copiedArray[0].pathComponents.firstIndex(of: "CircuitPython 8.x")!
                //
                //                    tempPath.removeSubrange(0...indexOfCP)
                //                    let joined = tempPath.joined(separator: "/")
                //                    print("joined : \(joined)")
                //
                //                    if (copiedArray[0].pathExtension == "py") || (copiedArray[0].pathExtension == "txt") {
                //
                //                        wifiTransferService.putRequest(fileName: joined, fileContent: data) { result in
                //                            switch result {
                //
                //                            case .success(let content):
                //                                copiedArray.removeFirst()
                //                                self.makeFile(files: copiedArray)
                //                            case .failure(let error):
                //                                print("Failed write")
                //                            }
                //                        }
                //
                //                    } else {
                //
                //                        wifiTransferService.sendPutRequest(fileName: joined, body: data) { result in
                //                            switch result {
                //
                //                            case .success(_):
                //                                print("Success")
                //
                //                                copiedArray.removeFirst()
                //                                self.makeFile(files: copiedArray)
                //                            case .failure(_):
                //                                print("Failed to write")
                //                            }
                //                        }
                //
                //                    }
                //
                //
                //                }
                
            }
            
            
            
            
            
            
            
            //                do {
            //                    let text2 = try String(contentsOf: copiedArray[10], encoding: .utf8)
            //                    text = text2
            //
            //
            //
            //
            ////                    putRequest(fileName: joined, fileContent: data) { result in
            ////                        switch result {
            ////
            ////                        case .success(let content):
            ////                            copiedArray.removeFirst()
            ////                            self.makeFile(files: copiedArray)
            ////                        case .failure(let error):
            ////                            print("Failed write")
            ////                        }
            ////                    }
            //
            //                } catch {
            //                    print("catch error")
            //                }
            
            
            //
            //        do {
            //                let text2 = try String(contentsOf: fileURLs[0], encoding: .utf8)
            //                text = text2
            //            putRequest(fileName: file, fileContent: text)
            //            }
            //            catch {/* error handling here */}
            //
            //        print("Reading File:")
            //        print("""
            //\(text)
            //""")
            
        }
        
        //            var tempURL = files[0].pathComponents
        //            tempURL.removeFirst(12)
        //            print(tempURL.joined(separator: "/"))
        
        
    }
    
    
    
    //    func sendPutRequest(fileName: String,
    //                        body: Data,
    //                        then handler: @escaping(Result<Data, Error>) -> Void) {
    //
    //        var urlSession = URLSession.shared
    //
    //        print(#function)
    //        let parameters = body
    //        let postData = parameters
    //
    //        postData.base64EncodedData(options: []).description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    //
    //        let username = ""
    //        let password = "passw0rd"
    //        let loginString = "\(username):\(password)"
    //
    //        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
    //            return
    //        }
    //        let base64LoginString = loginData.base64EncodedString()
    //
    //        // var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/")!,timeoutInterval: Double.infinity)
    //        var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/\(fileName)")!,timeoutInterval: Double.infinity)
    //        request.addValue("application/json", forHTTPHeaderField: "Accept")
    //        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
    //        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    //
    //        request.httpMethod = "PUT"
    //        request.httpBody = postData
    //
    //        print("Print curl:")
    //        print(request.cURL(pretty: true))
    //
    //        let task = urlSession.dataTask(
    //            with: request,
    //            completionHandler: { data, response, error in
    //                // Validate response and call handler
    //
    //                if let error = error  {
    //                    print("File write error")
    //
    //                    handler(.failure(error))
    //
    //                }
    //
    //                if let data = data {
    //                    print("File write success!")
    //                    handler(.success(data))
    //                }
    //
    //            }
    //        )
    //
    //        task.resume()
    //
    //    }
    
    
    
    
}
