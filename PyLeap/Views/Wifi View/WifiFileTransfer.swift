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

struct TestIndex {
     var count = 0
     var numberOfFiles = 0
}

class WifiFileTransfer: ObservableObject {
    
    
//    func fetchDocuments<T: Sequence>(in sequence: T) where T.Element == Int {
//        var documentNumbers = sequence.map { String($0) }
//
//        let timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] timer in
//            guard
//                let self = self,
//                let documentNumber = documentNumbers.first
//            else {
//                timer.invalidate()
//                return
//            }
//
//            self.fetchDocument(byNumber: documentNumber)
//            documentNumbers.removeLast()
//        }
//        timer.fire() // if you don't want to wait 2 seconds for the first one to fire, go ahead and fire it manually
//    }
    
    
    func fetchDocumentsq<T: Sequence>(in sequence: T) where T.Element == URL {
       
        print(sequence)
        
        guard let value = sequence.first(where: { _ in true }) else {
            print("Complete - fetchDocumentsq")
            return
            
        }

    //    let docNumber = String(value)
      //  fetchDocument(byNumber: docNumber)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
     //       self?.fetchDocuments(in: sequence.dropFirst())
            
            print(value)
            self?.fetchDocumentsq(in: sequence.dropFirst())
            
        }
        
        
    }
    
    
    struct TestIndex {
         var count = 0
         var numberOfFiles = 0
         var downloadState: DownloadState = .idle
        
        mutating func backToIdle(){
             count = 0
             numberOfFiles = 0
             downloadState = .idle
        }
        
        
        
    }
   
    var testIndex = TestIndex()
   
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = WifiFileTransfer()
                copy.counter = counter
                copy.numOfFiles = numOfFiles
                return copy
    }
    
    init() {
        print("WifiFileTransfer initialized")
    }
    
    deinit {
           print("Deinitializing WifiFileTransfer")
       }
    
    @Published var wifiTransferService = WifiTransferService()
    
    // File Manager Data
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    @Published var projectDownloaded = false
    
    @Published var failedProjectLaunch = false
    
    @Published var transferError = false
    
    @Published var stopTransfer = false
    
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
    
    func showFailedButton() {
       
       DispatchQueue.main.async {
           self.downloadState = .failed
           self.testIndex.downloadState = .failed
       }
               
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            self.downloadState = .idle
            self.testIndex.downloadState = .idle
            self.stopTransfer = false
       }
   }

    private weak var wifiDownloadComplete: NSObjectProtocol?
    private weak var didEncounterTransferError: NSObjectProtocol?
    private weak var downloadErrorDidOccur: NSObjectProtocol?
    
     func registerWifiNotification(enabled: Bool) {
        print("\(#function) @Line: \(#line)")
        
        let notificationCenter = NotificationCenter.default
        
        if enabled {
            //    public static let wifiDownloadComplete = Notification.Name(kPrefix+".wifiDownloadComplete")
            
            NotificationCenter.default.addObserver(self, selector: #selector(zipSuccess(_:)), name: .wifiDownloadComplete,object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(displayErrorMessage(_:)), name: .didEncounterTransferError,object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(projectDownloadDidFail(_:)), name: .downloadErrorDidOccur,object: nil)
            
            
        } else {
            print("Else testObserver")
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
        
        projectName = project
        
        DispatchQueue.main.async {
            self.downloadState = .transferring
            self.testIndex.downloadState = .transferring
        }
        
        let nestedFolderURL = directoryPath.appendingPathComponent(project)
        
        if manager.fileExists(atPath: nestedFolderURL.relativePath) {
            print("Exist within testFileExistance")
                        
            removeDirectoryAndFiles()
            startFileTransfer(url: nestedFolderURL)
            
        } else {
            print("Does not exist - downloading \(project)")
            
            downloadModel.trueDownload(useProject: bundleLink, projectName: project)
        }
    }
    
    

    
    
    
    
    
    

    
    func startFileTransfer(url: URL) {
        print("times startFileTransfer was called")
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
      
        print("times newMakeDirectory was called here")
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
        print("removeNonCPDirectories called")
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
        
        if stopTransfer {
            showFailedButton()
            print("Stopped")
            return
        }
        
        print("==============Start=================\n")


        var recursiveArray = removeNonCPDirectories(urls: directoryArray)
        print("directoryArray Count : \(directoryArray.count)")
        printArray(array: directoryArray)
        print("recursiveArray Count : \(recursiveArray.count)")
        printArray(array: recursiveArray)


        if recursiveArray.count == 0 {


            var tempArray = removeNonCPDirectories(urls: regularFilesArray)

            print("TempArray count \(tempArray)")
            
            DispatchQueue.main.async {
                self.numOfFiles = tempArray.count
                self.makeFile(files: tempArray)
             //   self.testIndex.numberOfFiles = self.numOfFiles

            }


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
        
        DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
            
            print("\(#function) @Line: \(#line)")
            downloadState = .complete
            testIndex.downloadState = .complete
            counter = 0
            testIndex.count = 0
            testIndex.numberOfFiles = 0
            numOfFiles = 0
            print("downloadState")
            print(downloadState)
            
          }
        

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            print("\(#function) @Line: \(#line)")
            self.downloadState = .idle
            self.testIndex.backToIdle()
        }
    }
    
    func checkForExistingFilesOnBoard(url: URL) -> String {
        var indexOfCP = 0
        var tempPathComponents = url.pathComponents
        
        print("URL in checkForExistingFilesOnBoard : \(tempPathComponents)")
        
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
        
        //    self.fetchDocumentsq(in: files)
        
        DispatchQueue.main.async {
            self.counter += 1
            self.testIndex.count += 1
            print("Counted.")
        }

        if copiedArray.isEmpty {


            print("Transfer Complete")
            print("Copied Array: \(copiedArray)")
            print("Files Array: \(files)")
            print("Counter: \(counter)")
            print("\(#function) @Line: \(#line)")

            print("Status: \(downloadState)")
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.completedTransfer()
            }


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


                        copiedArray.removeFirst()
                        self.makeFile(files: copiedArray)

                    } else {

                        self.wifiTransferService.sendPutRequest(fileName: self.makeFileString(url: copiedArray.first!), body: data) { result in
                            switch result {

                            case .success(_):
                                print("Successful Write for: \(copiedArray.first!.lastPathComponent)\n")


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
