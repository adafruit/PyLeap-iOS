//
//  WifiSubViewCellModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 9/1/22.
//

import Foundation


class WifiSubViewCellModel: ObservableObject {
    
    @Published var wifiTransferService =  WifiTransferService()
    
    @Published var projectDownloaded = false
    @Published var failedProjectLaunch = false
    
    @Published var usbInUse = false
    @Published var showUsbInUseError = false
    
    
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
            
            
            
            
            //            if success.contains("GET, OPTIONS, PUT, DELETE, MOVE") {
            //
            //                print("USB not in use.")
            //                DispatchQueue.main.async {
            //                    self.usbInUse = false
            //                }
            //
            //                //                 DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            //                //                     if wifiFileTransfer.projectDownloaded {
            //                //
            //                //                         wifiFileTransfer.testFileExistance(for: result.projectName, bundleLink: result.bundleLink)
            //                //
            //                //                     } else {
            //                //                         downloadModel.trueDownload(useProject: result.bundleLink, projectName: result.projectName)
            //                //                     }
            //                //                 }
            //
            //            } else {
            //                DispatchQueue.main.async {
            //                    self.usbInUse = true
            //                }
            //                print("USB in use - files cannot be tranferred or moved while USB is in use. Show Error")
            //            }
            
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
