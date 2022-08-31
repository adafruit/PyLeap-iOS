//
//  mDNSBrowser.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/24/22.
//

import Foundation

class Bonjour: NSObject {
   // var discovered: [DiscoveredInstance] = []
    let bonjourBrowser = NetServiceBrowser()
    var discoveredService: NetService?
    override init() {
        super.init()
        bonjourBrowser.delegate = self
        startDiscovery()
    }
    func startDiscovery() {
        print("Start Scan")
        self.bonjourBrowser.searchForServices(ofType: "_circuitpython._tcp.", inDomain: "local")
    }
    
    func stopDiscoveryScan() {
        self.bonjourBrowser.stop()
    }
}
extension Bonjour: NetServiceBrowserDelegate, NetServiceDelegate {
    
    
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print(#function)
        discoveredService = service
        discoveredService?.delegate = self
        discoveredService?.resolve(withTimeout: 5)
        print("++++++++++++++++++++++")
        print(discoveredService?.name)
        print(discoveredService?.hostName)
        print("++++++++++++++++++++++")
        
    }
    
    func netServiceDidStop(_ sender: NetService) {
        print("Stopped")
    }

    
    func netServiceDidResolveAddress(_ sender: NetService) {
            let hostName = sender.hostName!
            let port = sender.port
           // self.stop(with: .success((hostName, port)))
        
        print("\(hostName):\(port)")
        }
    
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("ERROR: \(errorDict)")
    }
    
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
      
        //self.discovered.removeAll { $0.name == service.name }
    }
    
    
//    func netServiceDidResolveAddress(_ sender: NetService) {
//        print("netServiceDidResolveAddress")
//        if let data = sender.txtRecordData() {
//            let dict = NetService.dictionary(fromTXTRecord: data)
//            /// do stuff with txtRecord dict here and then add to discovered array.
//           // discoveredService = nil
//        }
//    }
}
