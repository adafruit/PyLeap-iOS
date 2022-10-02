//
//  SettingsViewModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 9/14/22.
//

import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    
    private let kPrefix = Bundle.main.bundleIdentifier!
    let userDefaults = UserDefaults.standard
    @Published var hostName = ""
    @Published var device = ""
    @Published var ipAddress = ""
    var connectedToDevice = false
    @Published var invalidURL = false
    @Published var confirmDownload = false
    
    init() {
        check()
        registerNotifications(enabled: true)
    }
    
    private weak var errorObserver: NSObjectProtocol?
    private weak var confirmDownloadObserver: NSObjectProtocol?
    private weak var invalidIPObserver: NSObjectProtocol?
    
    
    private func registerNotifications(enabled: Bool) {
        let notificationCenter = NotificationCenter.default
        
        if enabled {
errorObserver = notificationCenter.addObserver(forName: .invalidCustomNetworkRequest, object: nil, queue: .main, using: {[weak self] _ in self?.showError()})
            
       
            confirmDownloadObserver = notificationCenter.addObserver(forName: .didCollectCustomProject, object: nil, queue: .main, using: {[weak self] _ in self?.showConfirmationAlert()})
            
            
        } else {
            if let testObserver = errorObserver {notificationCenter.removeObserver(testObserver)}
            
        }
    }
    
    
    func showError() {
        invalidURL = true
    }
    
    func showConfirmationAlert() {
        confirmDownload = true
    }
    
    func check() {
        print(#function)
       if userDefaults.object(forKey: kPrefix+".storedIP") == nil {
           connectedToDevice = false
       } else {
           print("Stored: \(String(describing: userDefaults.object(forKey: kPrefix+".storedIP"))), @: \(kPrefix+".storedIP")")
           
           connectedToDevice = true
           
           ipAddress = userDefaults.object(forKey: kPrefix+".storeResolvedAddress.ipAddress") as! String
           hostName = userDefaults.object(forKey: kPrefix+".storeResolvedAddress.hostName") as! String
           device = userDefaults.object(forKey: kPrefix+".storeResolvedAddress.device") as! String
       }
   }
    
    func clearKnownIPAddress() {
        userDefaults.set(nil, forKey: kPrefix+".storedIP")
        userDefaults.set(nil, forKey: kPrefix+".storeResolvedAddress.ipAddress" )
        userDefaults.set(nil, forKey: kPrefix+".storeResolvedAddress.hostName" )
        userDefaults.set(nil, forKey: kPrefix+".storeResolvedAddress.device" )
    }
    
}
