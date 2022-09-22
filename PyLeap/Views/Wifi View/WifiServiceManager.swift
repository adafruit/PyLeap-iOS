//
//  mDNSBrowser.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/24/22.
//

import Foundation
import SwiftUI

struct ResolvedService {
    var ipAddress: String
    var hostName: String
    var device: String
}

class WifiServiceManager: NSObject, ObservableObject {
   
    @EnvironmentObject var wifiViewModel: WifiViewModel
    @Published var connectionStatus: ConnectionStatus = .noConnection
    @Published var isSearching = false
    
    let serviceManagerBrowser = NetServiceBrowser()
    var discoveredService: NetService?
    
    var services = [NetService]()
    var resolvedServices = [ResolvedService]()
    
    
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
        print("Start Scan")
     //   self.serviceManagerBrowser.searchForServices(ofType: CircuitPythonType.serviceType, inDomain: CircuitPythonType.serviceDomain)
        resolvedServices.removeAll()
        
        print("Current state of isSearching: \(isSearching)")
        
        if isSearching == false {
            startDiscovery()
        }
    }
    
    func startDiscovery() {
        connectionStatus = .connected
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
        discoveredService?.resolve(withTimeout: 10)

        if services.contains(service) {
            print("All ready in service array")
        } else {
            print("Adding \(service.name) to array")
            services.append(service)
        }
        
        if moreComing == false {
           browser.stop()
        }
        
        print("Service count: \(services.count)")
    }
    
    func netServiceDidStop(_ sender: NetService) {
        isSearching = false
        print("isSearching: \(isSearching)")
    }

    
    func netServiceDidResolveAddress(_ sender: NetService) {
        print(#function)

        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            guard let data = sender.addresses?.first else { return }
            data.withUnsafeBytes { (pointer:UnsafePointer<sockaddr>) -> Void in
                guard getnameinfo(pointer, socklen_t(data.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                    return
                }
            }
        
        let ipAddress = String(cString:hostname)
        print("IP address: \(ipAddress)")
        
        //print("Host Name: \(service.hostName?.replacingOccurrences(of: ".local", with: ""))")
        let removeLocalFromSubString = sender.hostName?.replacingOccurrences(of: ".local", with: "")
        let updatedHostName = removeLocalFromSubString?.replacingOccurrences(of: ".", with: "")
        print("Host Name: \(updatedHostName)")
        print("Name: \(sender.name)")
        
        let resolvedService = ResolvedService(ipAddress: ipAddress, hostName: updatedHostName ?? "Unknown", device: sender.name)
                    
        resolvedServices.append(resolvedService)
        print("resolvedServices count: \(resolvedServices.count)")

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
