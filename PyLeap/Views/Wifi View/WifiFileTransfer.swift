//
//  WifiFileTransfer.swift
//  PyLeap
//
//  Created by Trevor Beaton on 9/13/22.
//

import Foundation
import SwiftUI

class WifiFileTransfer: ObservableObject {
    
    @StateObject var wifiTransferService = WifiTransferService()
    
    // File Manager Data
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    var manager = FileManager.default
    
    
    
    @Published var fileArray: [ContentFile] = []
    @Published var contentList: [URLData] = []
    
    @Published var projectDownloaded = false
    @Published var failedProjectLaunch = false
    
    var projectDirectories: [URL] = []
    var returnedArray = [[String]]()
    
    func removeFileArrayElements() {
        fileArray.removeAll()
    }
    
    func appendFileArrayElements(fileContent: ContentFile) {
        fileArray.append(fileContent)
    }
    
    func searchPathForProject(nameOf project: String) {
        var manager = FileManager.default
        let nestedFolderURL = directoryPath.appendingPathComponent(project)
        
        if manager.fileExists(atPath: nestedFolderURL.relativePath) {
          print("\(project) - Exist")
            projectDownloaded = true
        } else {
            print("Does not exist - \(project)")
           projectDownloaded = false
        }
    }
    
    
    func testFileExistance(for project: String) {
        let nestedFolderURL = directoryPath.appendingPathComponent(project)
        
        if manager.fileExists(atPath: nestedFolderURL.relativePath) {
          print("Exist")
          filesDownloaded(url: <#T##URL#>)
        } else {
            print("Does not exist")
            
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
    
    
    func appendDirectories(_ url: URL) {
        projectDirectories.append(url)
    }
    
    
    func filesDownloaded(url: URL) {
        removeFileArrayElements()
        
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
                            appendFileArrayElements(fileContent: addedFile)
                        }
                        
                        let addedFile = ContentFile(title: fileURL.lastPathComponent, fileSize: 0 )
                        appendFileArrayElements(fileContent: addedFile)
                    }
                    
                } catch { print(error, fileURL) }
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
                        if fileURL.pathComponents.count > 12 {
                            print("File Path component count: \(fileURL.pathComponents.count)")
                            appendDirectories(fileURL)
                        }
                    }
                    
                } else {
                    print("Regular Files: \(fileURL.path)")
                    regularFileUrls.append(fileURL)
                }
            }
        }
        
        
        
        pathManipulation(arrayOfAny: filterOutCPDirectories(fileArray: projectDirectories), fileArray: regularFileUrls)
        
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
            makeDirectory(fileArray: fileArray)
            
        }
        
    }
    
    func makeDirectory(fileArray: [URL]) {
        print(#function)
        
        var tempPath = returnedArray[0]
        let joined = tempPath.joined(separator: "/")
        print("Outgoing path:\(joined)")
        
        wifiTransferService.putDirectory(directoryPath: joined) { result in
            
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
                        
                        wifiTransferService.putRequest(fileName: joined, fileContent: data) { result in
                            switch result {
                                
                            case .success(let content):
                                copiedArray.removeFirst()
                                self.makeFile(files: copiedArray)
                            case .failure(let error):
                                print("Failed write")
                            }
                        }
                        
                    } else {
                        
                        wifiTransferService.sendPutRequest(fileName: joined, body: data) { result in
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
                        
                        wifiTransferService.putRequest(fileName: joined, fileContent: data) { result in
                            switch result {
                                
                            case .success(let content):
                                copiedArray.removeFirst()
                                self.makeFile(files: copiedArray)
                            case .failure(let error):
                                print("Failed write")
                            }
                        }
                        
                    } else {
                        
                        wifiTransferService.sendPutRequest(fileName: joined, body: data) { result in
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
