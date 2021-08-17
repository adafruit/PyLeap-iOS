//
//  FileDownloadViewModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 6/29/21.
//

import Foundation


class FileDownloadViewModel: NSObject,ObservableObject, URLSessionDownloadDelegate {
   
   
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
       //
    }
    
   // @Published var fileTransferClient: FileTransferClient?
    
    private static var url = URL(string: "https://learn.adafruit.com/pages/22555/elements/3098569/download?type=zip")!
    
    static var progressLabel = String()
    
    func downloader() {
        let downloadTask = URLSession.shared.downloadTask(with: FileDownloadViewModel.url) {
            urlOrNil, responseOrNil, errorOrNil in
            // check for and handle errors:
            // * errorOrNil should be nil
            // * responseOrNil should be an HTTPURLResponse with statusCode in 200..<299
            
            guard let fileURL = urlOrNil else { return }
            do {
                let documentsURL = try
                    FileManager.default.url(for: .documentDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: false)
                let savedURL = documentsURL.appendingPathComponent(fileURL.lastPathComponent)
                try FileManager.default.moveItem(at: fileURL, to: savedURL)
            } catch {
                print ("file error: \(error)")
            }
        }
        downloadTask.resume()

    }
    



}
