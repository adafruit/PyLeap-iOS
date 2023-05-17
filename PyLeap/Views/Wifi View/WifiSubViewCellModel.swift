//
//  WifiSubViewCellModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 9/1/22.
//

import Foundation
import SwiftUI

class WifiSubViewCellModel: ObservableObject {
    
    @ObservedObject var wifiTransferService =  WifiTransferService()
    
    @ObservedObject var wifiFileTransfer =  WifiFileTransfer()
    
    @Published var downloadState: DownloadState = .idle
    
    @Published var projectDownloaded = false
    @Published var failedProjectLaunch = false
    
    @Published var usbInUse = false
    @Published var showUsbInUseError = false
    
    
    init() {
        registerForUSBInUseErrorNotification(enabled: true)
    }
    
    private weak var usbInUseErrorNotification: NSObjectProtocol?
    
    private func registerForUSBInUseErrorNotification(enabled: Bool) {
        print("\(#function) @Line: \(#line)")
        
        let notificationCenter = NotificationCenter.default
        
        if enabled {
            
            // NotificationCenter.default.addObserver(self, selector: #selector(zipSuccess(_:)), name: .usbInUseErrorNotification,object: nil)
            
            usbInUseErrorNotification = notificationCenter.addObserver(forName: .usbInUseErrorNotification, object: nil, queue: .main, using: {[weak self] _ in self?.zipSuccess()})
            
        } else {
            
        }
    }
    
    
    
    
    func zipSuccess() {
        showUsbInUseError = true
    }
    
    func checkIfUSBInUse() {
        
        wifiTransferService.optionRequest(handler: { result in
            switch result {
           
            case .success:
                print("Success")
                
                self.wifiTransferService.getRequest(read: "boot_out.txt") { result in
                    print(result)
                }
                
                
            case .failure:
                print("Failure")
            }
            

            
        })
        
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
