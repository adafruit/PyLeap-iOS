//
//  DownloadModel.swift
//  SwiftUI File Manager
//
//  Created by Trevor Beaton on 7/12/21.
//

import SwiftUI
import Zip

class DownloadViewModel: NSObject, ObservableObject, URLSessionDownloadDelegate {
    
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let cachesPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    
    
    // Alert
    @Published var alertMsg = ""
    @Published var showAlert = false
    
    // Saving Download task reference for cancelling...
    @Published var downloadTaskSession: URLSessionDownloadTask!
    
    // Show Progress View
    @Published var downloadProgress: CGFloat = 0

    @Published var didDownloadBundle = false
    
    @Published var isDownloading = false
    
    // Saving Download task refernce for cancelling...
    @Published var downloadtaskSession : URLSessionDownloadTask!
    
    // MARK:- Download
    func startDownload(urlString: String, projectTitle: String) {
        isDownloading = true
        // Check for valid URL
        guard let validURL = URL(string: urlString) else {
            self.reportError(error: "Invalid URL!")
            return
        }
        downloadProgress = 0
        
        // Download Task...
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        downloadTaskSession = session.downloadTask(with: validURL)
        downloadTaskSession.resume()
        
        unzipProjectFile(urlString: urlString, projectTitle: projectTitle)
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
    
    func unzipProjectFile(urlString: String, projectTitle: String) {
        
        let CPZipName = directoryPath.appendingPathComponent("\(projectTitle).zip")
        
     //   _ = directoryPath.appendingPathComponent("PyLeap Folder")
        
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
        
        guard manager.urls(
            for: .documentDirectory,
               in: .userDomainMask).first != nil else {return}
        
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
    
    /// Periodically informs the delegate about the download’s progress - Used for progress UI
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // Getting Progress
        let numeralProgress = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        print("Progress: \(numeralProgress)")
        
        // Since URL Session will be running in the background thread
        // UI will be done on the main thread
        DispatchQueue.main.async {

            self.downloadProgress = numeralProgress
            print("Recorded downloadProgress Progress: \(self.downloadProgress)")
            print("Recorded numeralProgress Progress: \(numeralProgress)")
        }
    }
    
    /// Tells the delegate that a download task has finished downloading.
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
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
            
            DispatchQueue.main.async {
                // If Successful...
                print("Successful Download")
                self.isDownloading = false
                print("Download Location: \(location)")
                self.downloadProgress = 1.0
                print("\(self.didDownloadBundle) CURRENT STATE")
                self.didDownloadBundle = true
                print("\(self.didDownloadBundle) CURRENT STATE")
            }
            
        } catch {
            print(error)
            self.reportError(error: "Try again later")
            isDownloading = false
            self.didDownloadBundle = false
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
