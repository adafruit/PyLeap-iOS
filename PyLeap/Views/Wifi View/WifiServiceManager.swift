//
//  mDNSBrowser.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/24/22.
//

import Foundation
import SwiftUI


protocol ServiceFindDelegate {
   func serviceInfoChanged(index : Int)
   func serviceListResolved()
}

class WifiServiceManager: NSObject, ObservableObject {
   // var discovered: [DiscoveredInstance] = []
   
    @EnvironmentObject var wifiViewModel: WifiViewModel
    
    let serviceManagerBrowser = NetServiceBrowser()
    var isSearching = false
    var discoveredService: NetService?
    var services = [NetService]()
    
    var delegate : ServiceFindDelegate!
    
    @Published var connectionStatus: ConnectionStatus = .noConnection
    
    func numberOfService() -> Int {
       return services.count
    }
    
    func serviceAtIndex(index : Int) -> NetService {
       return services[index]
    }
    
    override init() {
        super.init()
        serviceManagerBrowser.delegate = self
        findService()
    }
    
    func findService() {
        if isSearching == false {
            startDiscovery()
        }
    }
    
    func startDiscovery() {
        connectionStatus = .connecting
        print("Start Scan")
        isSearching = true
        self.serviceManagerBrowser.searchForServices(ofType: CircuitPythonType.serviceType, inDomain: CircuitPythonType.serviceDomain)
    }
    
    func stopDiscoveryScan() {
        if isSearching {
            isSearching = false
            self.serviceManagerBrowser.stop()
        }
        
    }
}
extension WifiServiceManager: NetServiceBrowserDelegate, NetServiceDelegate {
    
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        isSearching = true
        print("netServiceBrowserWillSearch")
    }
    
    func netServiceBrowserDidStopSearch(browser: NetServiceBrowser) {
       isSearching = false
       print("netServiceBrowserDidStopSearch")
    }

    func netServiceBrowser(browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
          print("didNotSearch")
       }

    func netServiceBrowser(browser: NetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
          print("didFindDomain")
       }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print(#function)
        discoveredService = service
        discoveredService?.delegate = self
        discoveredService?.resolve(withTimeout: 5)

        if services.contains(service) {
            print("All ready in service array")
        } else {
            print("Adding \(service.name) to array")
            services.append(service)
        }
        
//        if services.firstIndex(of: service) == nil {
//           services.append(service)
//        }
        
        if service.addresses?.count == 0 {
            service.resolve(withTimeout: 100)
           service.delegate = self
        }
        
        if moreComing == false {
           browser.stop()
         //  delegate.serviceListResolved()
        }
        
        print("Service count: \(services.count)")
    }
    
    func netServiceDidStop(_ sender: NetService) {
        print("Stopped")
    }

    
    func netServiceDidResolveAddress(_ sender: NetService) {
        print(#function)
        
       // print(sender.name)
       // print(sender.hostName)

        for service in services {
         
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                guard let data = service.addresses?.first else { return }
                data.withUnsafeBytes { (pointer:UnsafePointer<sockaddr>) -> Void in
                    guard getnameinfo(pointer, socklen_t(data.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                        return
                    }
                }
            
            let ipAddress = String(cString:hostname)
            
            print("Address: \(service.addresses)")
            print("Host Name: \(service.hostName)")
            print("Name: \(service.name)")
                        
        }
        
        
//        if let index = services.firstIndex(of: sender) {
//
//            print("service info change : \(index)")
//
//           // delegate.serviceInfoChanged(index: index)
//             }
        
        
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
