//
//  SubCellViewModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 4/1/22.
//

import Foundation

class SubCellViewModel: ObservableObject {
    
    @Published var projectDownloaded = false
    @Published var failedProjectLaunch = false
    @Published var isConnectedToInternet = false
    
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var manager = FileManager.default
    
    var networkMonitor = NetworkMonitor()

    init() {
        internetMonitoring()
    }

    func deleteStoredFilesInFM () {
          print("\(#function) @Line: \(#line)")
        do {
            try manager.removeItem(at: directoryPath)
            
        } catch {
            print(error)
        }
    }
    
    func find(projectWith title: String) {
        
        let nestedFolderURL = directoryPath.appendingPathComponent(title)
        
        if manager.fileExists(atPath: nestedFolderURL.relativePath) {
          print("\(title) - Exists")
            projectDownloaded = true
        } else {
            print("\(title) - Does not exist.")
            projectDownloaded = false
        }
    }
    
    func internetMonitoring() {
        
        networkMonitor.startMonitoring()
        networkMonitor.monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Connected to internet.")
                
                DispatchQueue.main.async {
                   // self.showAlert = false
                    self.isConnectedToInternet = true
                }
            } else {
                print("No connection.")
                DispatchQueue.main.async {
                //    self.showAlert = true
                    self.isConnectedToInternet = false
                }
            }
            print("isExpensive: \(path.isExpensive)")
        }
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
    
}
