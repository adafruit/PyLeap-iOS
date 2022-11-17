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
    
    static let shared = DownloadViewModel()
    
    var bundleURL = String()
    var bundleTitle = String()
    
    // Alert
    @Published var alertMsg = ""
    @Published var showAlert = false
    
    var manager = FileManager.default
    
    // Show Progress View
    @Published var downloadProgress: CGFloat = 0

    @Published var didDownloadBundle = false
    
    @Published var isDownloading = false
    
    // Saving Download task refernce for cancelling...
   // @Published var downloadtaskSession : URLSessionDownloadTask!
    
    @Published var attemptToSendBunle = false
    
    @Published var state: DownloadState = .idle
    
    private lazy var session: URLSession = {
          let configuration = URLSessionConfiguration.default
          configuration.timeoutIntervalForResource = 5
          return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
      }()
    
    func trueDownload(useProject link: String, projectName: String) {
        
        let CPZipName = directoryPath.appendingPathComponent("\(projectName).zip")
        let request = URLRequest(url: URL(string: link)!)
        
        session.downloadTask(with: request).resume()
        bundleURL = link
        bundleTitle = projectName
    }
        
    // Saving Download task reference for cancelling...
    @Published var downloadTaskSession: URLSessionDownloadTask!
    



    func newZip(projectTitle: String, location: URL) {
        let CPZipName = directoryPath.appendingPathComponent("\(projectTitle).zip")
          print("\(#function) @Line: \(#line)")
        
        print("Location 1: \(location)")
        
        do {
            
            let zipData = try Data(contentsOf: location)
            
            try zipData.write(to: CPZipName)
            
           // let unzipDirectory = try Zip.quickUnzipFile(CPZipName) // Unzip
            
            try FileManager.default.removeItem(at: CPZipName)
            
            
            
            
        } catch {
            print("newZip - Zip ERROR")
            print("Error: \(error)")
            print("Location 2: \(location)")
            self.state = .failed
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.state = .idle
            }
            
        }
        
        
    }
    
    
    

    
    func unzipProjectFile(urlString: String, projectTitle: String) {

        let CPZipName = directoryPath.appendingPathComponent("\(projectTitle).zip")

     //   _ = directoryPath.appendingPathComponent("PyLeap Folder")

        if let zipFileUrl = URL(string: urlString) {
            // Download from this site
            URLSession.shared.downloadTask(with: zipFileUrl) { (tempFileUrl, response, error) in

                if let zipTempFileUrl = tempFileUrl {
                   
                    do {

                        let zipData = try Data(contentsOf: zipTempFileUrl)

                        try zipData.write(to: CPZipName)

                        let unzipDirectory = try Zip.quickUnzipFile(CPZipName) // Unzip

                        try FileManager.default.removeItem(at: CPZipName)

                        
                        var projectResponse =  [String: String]()
                        projectResponse["projectTitle"] = self.bundleTitle
                        projectResponse["projectLink"] = self.bundleURL

                        NotificationCenter.default.post(name: .didCompleteZip, object: nil, userInfo: projectResponse)

                        NotificationCenter.default.post(name: .wifiDownloadComplete, object: nil, userInfo: projectResponse)
                        
                    } catch {
                        print("unzipProjectFile - Zip ERROR")
                        print("Error: \(error)")

                        NotificationCenter.default.post(name: .downloadErrorDidOccur, object: nil, userInfo: nil)
                                   return
                        
                        
                        DispatchQueue.main.async {
                            self.state = .failed
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.state = .idle
                        }

                    }
                    
                    
                } else {

                    self.state = .failed

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.state = .idle
                    }

                }

            }.resume()
        }
    }
    
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//           print("Download succeeded")
//       }
    
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
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error else { return }
        print(error)

        guard let resumeData = (error as NSError).userInfo[NSURLSessionDownloadTaskResumeData] as? Data else {
            print("Download failed")
            return
        }
        session.downloadTask(withResumeData: resumeData).resume()
    }

    /// Tells the delegate that a download task has finished downloading.
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let httpResponse = downloadTask.response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode) else {
                       print ("server error")
            NotificationCenter.default.post(name: .downloadErrorDidOccur, object: nil, userInfo: nil)
                       return
               }
        
        print("Location: \(location)")
        
        guard let url = downloadTask.originalRequest?.url else {
            self.reportError(error: "An error has occurred...")
            return
        }
        
        // Creating a destination for storing files with a destination URL
        let destinationURL = directoryPath.appendingPathComponent(url.lastPathComponent)
        
        //if that file already exists, replace it.
        
        try? FileManager.default.removeItem(at: destinationURL)
        
        print(#function)
        do {
            
            // Copy temp file to directory.
            try FileManager.default.copyItem(at: location, to: destinationURL)
           
            DispatchQueue.main.async {
              
                self.unzipProjectFile(urlString: self.bundleURL, projectTitle: self.bundleTitle)
                
                // If Successful...
//                print("Successful Download")
//                self.isDownloading = false
//                print("Download Location: \(location)")
//                self.downloadProgress = 1.0
//                print("\(self.didDownloadBundle) CURRENT STATE")
//                self.didDownloadBundle = true
//                print("\(self.didDownloadBundle) CURRENT STATE")
                  
                

                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.attemptToSendBunle.toggle()
                }
                
                
                NotificationCenter.default.post(name: .didCompleteTransfer, object: nil, userInfo: nil)
               
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
    
    // MARK:- Download
    func startDownload(urlString: String, projectTitle: String) {
        print("Starting Download...")
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
        
      //  unzipProjectFile(urlString: urlString, projectTitle: projectTitle)
    }
    
    
    func testCallback(completion: ()->()) {
        print("Do something")
        
    }
    
    
    
    
}
extension DownloadViewModel {
    
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
    
}
