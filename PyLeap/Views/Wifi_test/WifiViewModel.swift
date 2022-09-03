//
//  WifiViewModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/9/22.
//


import SwiftUI
import Foundation
import CoreLocation
import Network

class WifiViewModel: ObservableObject {
    
    var networkMonitor = NetworkMonitor()
    var wifiService = WifiNetworkService()
    let bonjour = Bonjour()
    
    @Published var webDirectoryInfo = [WebDirectoryModel]()
    
    // File Manager Data
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    @Published var fileArray: [ContentFile] = []
    @Published var contentList: [URLData] = []
    var projectDirectories: [URL] = []
    
    
    func projectValidation(nameOf project: String) {
        print("getProjectURL called")
        // counter = 0
        // state = .transferring
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
                        // print("\(state)")
                        //   state = .idle
                        
                    }
                    
                }
            }
            
        }
        
    }
    
    func directorySort(url: URL) {
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
        
    }
    
    func fileFilter(Project path: URL) {
        
        var files = [URL]()
        fileArray.removeAll()
        
        if let enumerator = FileManager.default.enumerator(at: path, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
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
                            fileArray.append(addedFile)
                        }
                        
                        let addedFile = ContentFile(title: fileURL.lastPathComponent, fileSize: 0 )
                        fileArray.append(addedFile)
                    }
                    
                } catch { print(error, fileURL) }
                
            }
            
        }
        
    }
    
    func filesDownloaded(url: URL) {
        fileArray.removeAll()
        
        var files = [URL]()
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
                        
                        print("FILTERED INCOMING FILE: \(fileURL.path)")
                        contentList.append(.init(urlTitle: fileURL))
                        if fileAttributes.isRegularFile! {
                            
                            files.append(fileURL)
                            
                            let resources = try fileURL.resourceValues(forKeys:[.fileSizeKey])
                            let fileSize = resources.fileSize!
                            
                            let addedFile = ContentFile(title: fileURL.lastPathComponent, fileSize: fileSize)
                            fileArray.append(addedFile)
                        }
                        
                        let addedFile = ContentFile(title: fileURL.lastPathComponent, fileSize: 0 )
                        fileArray.append(addedFile)
                    }
                    
                } catch { print(error, fileURL) }
            }
            
            
            
            //  numOfFiles = files.count
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
        
        //        print("List of Directories")
        //        for i in projectDirectories {
        //            print("Directory: \(i.path)")
        //        }
        //        print("List of Files")
        //        for i in fileURLs {
        //            print("Files: \(i.path)")
        //        }
        //
        //        DispatchQueue.main.async {
        //            self.sendingBundle = true
        //        }
        
        //  print("Current projectDirectories: \(projectDirectories[0])")
        
        // sortDirectory(dirList: projectDirectories, filesUrls: fileURLs)
        
        // ***Working Transfer***
        
        //        print("First file in project array")
        //        print(fileURLs[0].lastPathComponent)
        //
        //        let file = fileURLs[0].lastPathComponent //this is the file. we will write to and read from it
        //
        //        var text = "some text" //just a text
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
        
        print("List of Directories \n")
        for i in projectDirectories {
            print("Directory: \(i.path)")
        }
        print("List of Files \n")
        for i in fileURLs {
            print("Files: \(i.path)")
        }
        
        DispatchQueue.main.async {
        }
        
        
        print("Current projectDirectories: \(projectDirectories[0])")
        
        
        // sortDirectory(directoryArray: projectDirectories, fileArray: fileURLs)
        pathManipulation(arrayOfAny: filterOutCPDirectories(fileArray: projectDirectories), fileArray: fileURLs)
        
    }
    
    func intakeArray(path: URL) {
        
        var indexOfCP = 0
        //path.pathComponents.removeSubrange(0...indexOfCP)
    }
    
    func filterOutCPDirectories(fileArray: [URL]) -> [URL] {
        
        let test = fileArray.filter {
            $0.lastPathComponent != ("CircuitPython 8.x")
        }
        
        let test2 = test.filter {
            $0.lastPathComponent != ("CircuitPython 7.x")
        }
        
        return test2
        
    }
    
    func exit() {
        
    }
    
    var returnedArray = [[String]]()
    
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
    
    //    func sortDirectory(directoryArray: [URL], fileArray: [URL]) {
    //        print(#function)
    //
    //        var sortedDirectoryArray = directoryArray.sorted(by: { $1.pathComponents.count > $0.pathComponents.count} )
    //        var sortedFileArray = fileArray.sorted(by: { $1.pathComponents.count > $0.pathComponents.count} )
    //        validateDirectory(directoryArray: sortedDirectoryArray, fileArray: sortedFileArray)
    //    }
    
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
            
            makeDirectory(fileArray: fileArray)
            
        }
        
    }
    
    func makeDirectory(fileArray: [URL]) {
        print(#function)
        
        
        
        
        var tempPath = returnedArray[0]
        let joined = tempPath.joined(separator: "/")
        print("Outgoing path:\(joined)")
        
        putDirectory(directoryPath: joined) { result in
            
            switch result {
                
            case .success(let consent):
                print("Successful")
                self.returnedArray.removeFirst()
                self.validateDirectory(directoryArray: self.returnedArray, fileArray: fileArray)
                
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        
    }
    
    func makeFile(files: [URL]) {
        print(#function)
        var copiedArray = files
        
        if files.isEmpty {
            print("Transfer Complete")
        } else {
            
            
            // let file = files[0].pathComponents.removeFirst(12) //this is the file. we will write to and read from it
            
            
            if copiedArray.first?.lastPathComponent == "README.txt" {
                print("Removing README")
                copiedArray.removeFirst()
                makeFile(files: copiedArray)
                
            } else {
                
                //                print("copiedArray[0] \(copiedArray[0].pathComponents)")
                //                var tempURL = copiedArray[0].pathComponents
                //                tempURL.removeFirst(12)
                //                let joined = tempURL.joined(separator: "/")
                //                print("Joined \(joined)")
                
                
                
                
                
                
                // var text = "some text" //just a text
                
                guard let data = try? Data(contentsOf: URL(fileURLWithPath: copiedArray[0].path, relativeTo: copiedArray[0])) else {
                    print("File not found")
                    return
                }
                
                
                var tempPath = copiedArray[0].pathComponents
                print("PRINT INCOMING: \(tempPath)")
                
                if copiedArray[0].pathComponents.contains("CircuitPython 7.x") {
                    print("Found CircuitPython 7.x")
                    
                    var indexOfCP = 0
                    
                    indexOfCP = copiedArray[0].pathComponents.firstIndex(of: "CircuitPython 7.x")!
                    
                    tempPath.removeSubrange(0...indexOfCP)
                    
                    let joined = tempPath.joined(separator: "/")
                    
                    
                    
                    if (copiedArray[0].pathExtension == "py") || (copiedArray[0].pathExtension == "txt") {
                        
                        putRequest(fileName: joined, fileContent: data) { result in
                            switch result {
                                
                            case .success(let content):
                                copiedArray.removeFirst()
                                self.makeFile(files: copiedArray)
                            case .failure(let error):
                                print("Failed write")
                            }
                        }
                        
                    } else {
                        
                        sendPutRequest(fileName: joined, body: data) { result in
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
                    
                    
                    
                }
                
                
                
                if copiedArray[0].pathComponents.contains("CircuitPython 8.x") {
                    print("Found CircuitPython 8.x")
                    var tempPath = copiedArray[0].pathComponents
                    
                    var indexOfCP = Int()
                    
                    indexOfCP = copiedArray[0].pathComponents.firstIndex(of: "CircuitPython 8.x")!
                    
                    tempPath.removeSubrange(0...indexOfCP)
                    let joined = tempPath.joined(separator: "/")
                    print("joined : \(joined)")
                    
                    if (copiedArray[0].pathExtension == "py") || (copiedArray[0].pathExtension == "txt") {
                        
                        putRequest(fileName: joined, fileContent: data) { result in
                            switch result {
                                
                            case .success(let content):
                                copiedArray.removeFirst()
                                self.makeFile(files: copiedArray)
                            case .failure(let error):
                                print("Failed write")
                            }
                        }
                        
                    } else {
                        
                        sendPutRequest(fileName: joined, body: data) { result in
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
                    
                    
                }
                
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
    
    
    
    func sendPutRequest(fileName: String,
                        body: Data,
                        then handler: @escaping(Result<Data, Error>) -> Void) {
        
        var urlSession = URLSession.shared
        
        print(#function)
        let parameters = body
        let postData = parameters
        
        postData.base64EncodedData(options: []).description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let username = ""
        let password = "passw0rd"
        let loginString = "\(username):\(password)"
        
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        // var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/")!,timeoutInterval: Double.infinity)
        var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/\(fileName)")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "PUT"
        request.httpBody = postData
        
        print("Print curl:")
        print(request.cURL(pretty: true))
        
        let task = urlSession.dataTask(
            with: request,
            completionHandler: { data, response, error in
                // Validate response and call handler
                
                if let error = error  {
                    print("File write error")
                    
                    handler(.failure(error))
                    
                }
                
                if let data = data {
                    print("File write success!")
                    handler(.success(data))
                }
                
            }
        )
        
        task.resume()
        
    }
    
    
    
    
    func test() {
        bonjour.startDiscovery()
    }
    
    public func internetMonitoring() {
        
        // networkMonitor.startMonitoring()
        networkMonitor.monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Connected to internet.")
                
                print(self.networkMonitor.monitor.currentPath.debugDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.networkMonitor.getConnectionType(path)
                    
                }
            } else {
                print("No connection.")
                DispatchQueue.main.async {
                }
            }
            print("isExpensive: \(path.isExpensive)")
        }
    }
    
    
    
    func getRequest() {
        
        let username = ""
        let password = "passw0rd"
        let loginString = "\(username):\(password)"
        
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        // var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/")!,timeoutInterval: Double.infinity)
        var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        print("Print curl:")
        print(request.cURL(pretty: true))
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: "Error Found: \(error)"))
                return
            }
            // print(String(data: data, encoding: .utf8)!)
            
            do {
                let wifiIncomingData = try JSONDecoder().decode([WebDirectoryModel].self, from: data)
                
                DispatchQueue.main.async {
                    self.webDirectoryInfo = wifiIncomingData
                }
            } catch {
                print(error.localizedDescription)
            }
            
            if let str = String(data: data, encoding: .utf8) {
                print(str)
            }
        }
        task.resume()
    }
    
    func getRequest(incoming: String) -> String {
        
        var semaphore = DispatchSemaphore (value: 0)
        
        let username = ""
        let password = "passw0rd"
        let loginString = "\(username):\(password)"
        
        var outgoingString = String()
        
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return "Error"
        }
        let base64LoginString = loginData.base64EncodedString()
        
        // var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/")!,timeoutInterval: Double.infinity)
        var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/\(incoming)")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        print("Print curl:")
        print(request.cURL(pretty: true))
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: "Error Found: \(error)"))
                semaphore.signal()
                return
            }
            // print(String(data: data, encoding: .utf8)!)
            semaphore.signal()
            
            do {
                let wifiIncomingData = try JSONDecoder().decode([WebDirectoryModel].self, from: data)
                
                DispatchQueue.main.async {
                    self.webDirectoryInfo = wifiIncomingData
                }
            } catch {
                print(error.localizedDescription)
            }
            
            if let str = String(data: data, encoding: .utf8) {
                print(str)
                outgoingString = str
            }
        }
        task.resume()
        semaphore.wait()
        return outgoingString
    }
    //  func putDirectory(directoryPath: String, completion: @escaping (Result<Data?, Error>) -> Void) {
    
    func putRequest(fileName: String, fileContent: Data, completion: @escaping (Result<Data?, Error>) -> Void) {
        print("Test Transfer")
        let parameters = fileContent
        let postData = parameters
        
        let username = ""
        let password = "passw0rd"
        let loginString = "\(username):\(password)"
        
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        // var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/")!,timeoutInterval: Double.infinity)
        var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/\(fileName)")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "PUT"
        request.httpBody = postData
        
        print("Print curl:")
        print(request.cURL(pretty: true))
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error  {
                print("File write error")
                
                completion(.failure(error))
                
            }
            
            if let data = data {
                print("File write success!")
                completion(.success(data))
            }
            
            // print(String(data: data, encoding: .utf8)!)
            
        }
        task.resume()
    }
    
    // Make
    func putDirectory(directoryPath: String, completion: @escaping (Result<Data?, Error>) -> Void) {
        
        let username = ""
        let password = "passw0rd"
        let loginString = "\(username):\(password)"
        
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/\(directoryPath)/")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        
        print("Print curl:")
        print(request.cURL(pretty: true))
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            
            if let error = error  {
                completion(.failure(error))
                
            }
            
            if let data = data {
                completion(.success(data))
            }
            
        }
        
        task.resume()
    }
    
    func putRequest() {
        
        let parameters = "test raw data"
        let postData = parameters.data(using: .utf8)
        
        
        let username = ""
        let password = "passw0rd"
        let loginString = "\(username):\(password)"
        
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        // var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/")!,timeoutInterval: Double.infinity)
        var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/testing.txt")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "PUT"
        request.httpBody = postData
        
        print("Print curl:")
        print(request.cURL(pretty: true))
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            
            guard let error = error else {
                print(String(describing: error))
                
                return
            }
            
            print(String(data: data, encoding: .utf8)!)
            
        }
        task.resume()
    }
    
    func deleteRequest() {
        
        let username = ""
        let password = "passw0rd"
        let loginString = "\(username):\(password)"
        
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        // var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/")!,timeoutInterval: Double.infinity)
        var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/testing.txt")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "DELETE"
        
        print("Print curl:")
        print(request.cURL(pretty: true))
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            
            guard let error = error else {
                print(String(describing: error))
                
                return
            }
            
            //  print(String(data: data, encoding: .utf8)!)
            
        }
        task.resume()
    }
    
    @Published var projectDownloaded = false
    @Published var failedProjectLaunch = false
    
    
    
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
    
    
    //    Enter IP Adress
    //    Store ip Address
    //    Connect
    //    Found CP Board - Confirm
    //    Pop in to pyleap window
    //
    //    Folder called Transports Bluetooth / Wifi
    //    IP Address to in status bar
    //
    //
    //    For
}

///MDSN is the IP Address
///"IP Will always work"
///circuit.local


//device.json


extension URLRequest {
    mutating func setBasicAuth(username: String, password: String) {
        let encodedAuthInfo = String(format: "%@:%@", username, password)
            .data(using: String.Encoding.utf8)!
            .base64EncodedString()
        addValue("Basic \(encodedAuthInfo)", forHTTPHeaderField: "Authorization")
    }
}

extension URLRequest {
    public func cURL(pretty: Bool = false) -> String {
        let newLine = pretty ? "\\\n" : ""
        let method = (pretty ? "--request " : "-X ") + "\(self.httpMethod ?? "GET") \(newLine)"
        let url: String = (pretty ? "--url " : "") + "\'\(self.url?.absoluteString ?? "")\' \(newLine)"
        
        var cURL = "curl "
        var header = ""
        var data: String = ""
        
        if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
            for (key,value) in httpHeaders {
                header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
            }
        }
        
        if let bodyData = self.httpBody, let bodyString = String(data: bodyData, encoding: .utf8),  !bodyString.isEmpty {
            data = "--data '\(bodyString)'"
        }
        
        cURL += method + url + header + data
        
        return cURL
    }
}
