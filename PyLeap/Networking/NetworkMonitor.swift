//
//  NetworkMonitor.swift
//  PyLeap
//
//  Created by Trevor Beaton on 11/29/21.
//

import Foundation
import Network

class NetworkMonitor {
    
    let queue = DispatchQueue(label: "Monitor")
    let monitor: NWPathMonitor
    
    public private(set) var isConnected: Bool = false

    public private(set) var connectionType: ConnectionType = .unknown
    
    enum ConnectionType{
        case wifi
        case cellular
        case unknown
    }
    
    init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }
    
    public func startMonitoring(){
        print("Start Internet monitoring")
        monitor.start(queue: queue)
    }
    
    public func stopMonitoring(){
        monitor.cancel()
    }
    
    
    public func getConnectionType(_ path: NWPath){
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
            print("Wifi")
        }
        else if path.usesInterfaceType(.cellular){
            connectionType = .cellular
            print("cellular")
        }
    }
    
}
