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
    
}
