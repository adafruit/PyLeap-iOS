//
//  MainSelectionViewModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 9/29/22.
//

import Foundation
import SwiftUI
import Network
import Combine

class InternetConnectionManager: ObservableObject {
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "InternetConnectionMonitor")
    @Published var isConnected = false
    
    init() {
       
        startMonitoring(completion: {
            monitor.pathUpdateHandler = { path in
                
                DispatchQueue.main.async {
                    let newIsConnected = path.status == .satisfied
                                      if self.isConnected != newIsConnected {
                                          self.isConnected = newIsConnected
                                          print("net: \(path.status) \(self.isConnected)")
                                      }
                }
            }
        })
    }
    
    func startMonitoring(completion:()->Void) {
       print("Start Monitoring Network")
        monitor.start(queue: queue)
        completion()
        
    }
    
    deinit {
        print("Network Deinit")
        monitor.cancel()
    }
}

class MainSelectionViewModel: ObservableObject {
    
    @ObservedObject var networkModel = NetworkService()
    @ObservedObject var networkMonitor = InternetConnectionManager()
    
    
    let fileManager = FileManager.default
    
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    let dataStore = DataStore()
    
    @Published var pdemos : [ResultItem] = []
    var networkMonitorCancellable: AnyCancellable?
    
    init() {
        let fileURL = documentsDirectory.appendingPathComponent("StandardPyLeapProjects.json")
        

        networkMonitorCancellable = networkMonitor.$isConnected.sink { isConnected in
                    if isConnected {
                        print("The device is currently connected to the internet.")
                        // Perform some action when the device is connected to the internet.
                        self.networkModel.fetch {
                            self.pdemos = self.dataStore.loadDefaultList()
                        }
                        
                    } else {
                        print("The device is not currently connected to the internet.")
                        // Perform some action when the device is not connected to the internet.
                        print("Loading cached remote data.")
                        self.pdemos = self.dataStore.loadDefaultList()
                        
                        
                    }
                }
        
    }
    
    
}
