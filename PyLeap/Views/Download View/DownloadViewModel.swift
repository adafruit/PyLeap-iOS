//
//  DownloadModel.swift
//  SwiftUI File Manager
//
//  Created by Trevor Beaton on 7/12/21.
//

import SwiftUI
import Zip

class DownloadViewModel: NSObject, ObservableObject, URLSessionDownloadDelegate {
    
    //private let fileTransferClient: FileTransferClient?
    
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let cachesPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    
    
    // Alert
    @Published var alertMsg = ""
    @Published var showAlert = false
    
    // Saving Download task reference for cancelling...
    @Published var downloadTaskSession: URLSessionDownloadTask!
    
    // Show Progress View
    @Published var downloadProgress: CGFloat = 0
    @Published var showDownloadProgress = false
    
    // Saving Download task refernce for cancelling...
    @Published var downloadtaskSession : URLSessionDownloadTask!
    
    // MARK:- Download
    func startDownload(urlString: String) {
        
        // Check for valid URL
        guard let validURL = URL(string: urlString) else {
            self.reportError(error: "Invalid URL!")
            return
        }
        downloadProgress = 0
        withAnimation{showDownloadProgress = true}
        
        // Download Task...
        // Since were going to get the progress as well as location of the File, I'm going to use a delegate...
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        downloadTaskSession = session.downloadTask(with: validURL)
        downloadTaskSession.resume()
    }
    
    func makeFileDirectory() {
        // Creating a File Manager Object
       
        // Creating a folder
        let pyleapProjectFolderURL = directoryPath.appendingPathComponent("PyLeap Project Folder")
        
        do {
            
            try FileManager.default.createDirectory(at: pyleapProjectFolderURL,
                                        withIntermediateDirectories: true,
                                        attributes: [:])
        } catch {
            print(error)
        }
    }
    
    func unzipProjectFile() {

        let CPZipName = directoryPath.appendingPathComponent("RainbowBundle.zip")
        
        let pyleapProjectFile = directoryPath.appendingPathComponent("PyLeap Folder")
        
        // Download Site...
        let urlString = "https://learn.adafruit.com/pages/22555/elements/3098569/download?type=zip"
        
        
        if let zipFileUrl = URL(string: urlString) {
            // Download from this site
            URLSession.shared.downloadTask(with: zipFileUrl) { (tempFileUrl, response, error) in
                
                /*
                 if let...
                 if you can let the new variable name equal the non-optional version of optionalName, do the following with it"
                 */
                
                if let zipTempFileUrl = tempFileUrl {
                    do {
                        
                        let zipData = try Data(contentsOf: zipTempFileUrl)
                        
                        try zipData.write(to: CPZipName)
                        
                        let unzipDirectory = try Zip.quickUnzipFile(CPZipName) // Unzip
                        
                        try FileManager.default.removeItem(at: CPZipName)
                        
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }.resume()
        }
    }
    
    
    func createNewTextFile() {
        
        // Creating a File Manager Object
        let manager = FileManager.default
        
        // Creating a path to make a document directory path
        guard let url = manager.urls(
                for: .documentDirectory,
                in: .userDomainMask).first else {return}
        
        // Creating a folder
        let newFolderURL = url.appendingPathComponent("PyLeap Folder")
        
        let textFile = newFolderURL.appendingPathComponent("testLog.py")
        
        let data = "Hey! This is a test!".data(using: .utf8)
        
        manager.createFile(atPath: textFile.path,
                           contents: data,
                           attributes: [FileAttributeKey.creationDate:Date()])
        
    }
    
    
    func deleteTextFile() {
        
        // Creating a File Manager Object
        let manager = FileManager.default
        
        guard let url = manager.urls(
                for: .documentDirectory,
                in: .userDomainMask).first else {return}
        
        
        
        let deleteFile = directoryPath.appendingPathComponent("PyLeap Project Folder")
       
        
        if manager.fileExists(atPath: deleteFile.path) {
            print("File to be deleted :\(deleteFile)")
            
            do {
                try manager.removeItem(at: deleteFile)

            } catch {
                print(error)
            }
        }
    }
    
    
    
    /// Tells the delegate that a download task has finished downloading.
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Download Location: \(location)")
        
        guard let url = downloadTask.originalRequest?.url else {
            self.reportError(error: "An error has occurred...")
            return
        }
        
        
        
        // Creating a destination for storing files with a destination URL
        let destinationURL = directoryPath.appendingPathComponent(url.lastPathComponent)
        
        //if that file already exists, replace it.
        
        try? FileManager.default.removeItem(at: destinationURL)
        
        do {
            
            // Copy temp file to directory.
            try FileManager.default.copyItem(at: location, to: destinationURL)
            
            // If Success
            print("Successful Download")
            
            // Closing Progress View
            DispatchQueue.main.async {
                withAnimation{self.showDownloadProgress = false}
            }
            
            
        } catch {
            print(error)
            self.reportError(error: "Try again later")
        }
        
    }
   
    
    @Published var fileArray: [ContentFile] = []

    func startup(){
        
        print("Directory Path: \(directoryPath.path)")
        print("Caches Directory Path: \(cachesPath.path)")

        
        do {
            
            let contents = try FileManager.default.contentsOfDirectory(at: directoryPath, includingPropertiesForKeys: nil,options: [.skipsHiddenFiles])
            
            for file in contents {
                print("File Content: \(file.lastPathComponent)")
              //  print("File Size: \(fileSize)")
                
               let addedFile = ContentFile(title: file.lastPathComponent)
                self.fileArray.append(addedFile)
            }
        } catch {
            print("Error: \(error)")
        }
        
//        
//        
//        if let enumerator =
//            FileManager.default.enumerator(atPath: directoryPath.path)
//        {
//            for case let path as String in enumerator {
//                // Skip entries with '_' prefix, for example
//                if path.hasPrefix("_") {
//                    
//                    print("Path : \(path)")
//                    enumerator.skipDescendants()
//                    
//                }
//            }
//        }
//        
//        
//        print("Directory Path: \(directoryPath.path)")
    }
    
   
    


    
    
    /// Periodically informs the delegate about the download’s progress - Used for progress UI
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // Getting Progress
        let numeralProgress = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        print("Progress: \(numeralProgress)")
        
        // Since URL Session will be running in the background thread
        // UI will be done on the main thread
        DispatchQueue.main.async {
            self.downloadProgress = numeralProgress
        }
    }
    
    // Report Error Function...
    func reportError(error: String){
        alertMsg = error
        showAlert.toggle()
    }
   
    
    // cancel Task...
    func cancelTask(){
        if let task = downloadtaskSession,task.state == .running{
            // cancelling...
            downloadtaskSession.cancel()
            // closing view...
         //   withAnimation{self.showDownlodProgress = false}
        }
    }
    
    
}
