//
//  WifiSubViewCellModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 9/1/22.
//

import Foundation

class WifiSubViewCellModel: ObservableObject {
    
    @Published var projectDownloaded = false
    @Published var failedProjectLaunch = false
    
    @Published var usbInUseError = false
    
    init() {
       registerNotification(enabled: true)
    }
    
    private weak var usbInUseErrorNotification: NSObjectProtocol?
    
    private func registerNotification(enabled: Bool) {
        print("\(#function) @Line: \(#line)")
        
        let notificationCenter = NotificationCenter.default
        
        if enabled {
            
//            NotificationCenter.default.addObserver(self, selector: #selector(zipSuccess(_:)), name: .usbInUseErrorNotification,object: nil)
            
            usbInUseErrorNotification = notificationCenter.addObserver(forName: .usbInUseErrorNotification, object: nil, queue: .main, using: {[weak self] _ in self?.zipSuccess()})
            
        } else {
        
        }
    }
    
     func zipSuccess() {
        usbInUseError = true
    }
    
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
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
