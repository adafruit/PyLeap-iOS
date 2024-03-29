//
//  mDNSBrowser.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/24/22.
//

import Foundation
import SwiftUI

struct ResolvedService: Identifiable, Equatable {
    var id = UUID()
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
        print("Wifi Module Used")
        serviceManagerBrowser.delegate = self
        findService()
        
    }
    
    deinit {
        print("Wifi Module Removed")
        self.serviceManagerBrowser.stop()
    }

    
    func findService() {
        print("Current state of isSearching: \(isSearching)")
        
        if isSearching == false {
            print("Start Scanning")
            startDiscovery()
        }
    }
    
    func startDiscovery() {
        print("Start Discovery")
        DispatchQueue.main.async {
            self.isSearching = true
        }
        
        
        print("\(#function) @Line: \(#line)")
        print("Current state of isSearching: \(isSearching)")
        self.serviceManagerBrowser.searchForServices(ofType: CircuitPythonType.serviceType, inDomain: CircuitPythonType.serviceDomain)
        
        
        let timer = Timer.scheduledTimer(withTimeInterval: 12, repeats: false) { timer in

            self.stopDiscoveryScan()

        }
        
        
    }
    
    func stopDiscoveryScan() {
        if isSearching {
            isSearching = false
            self.serviceManagerBrowser.stop()
            print(resolvedServices)
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
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        print("netServiceBrowserDidStopSearch")
    }
 
    
    func netServiceWillResolve(_ sender: NetService) {
        print("netServiceWillResolve")
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        "didRemoveDomain"
    }
    
    
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print(#function)
        discoveredService = service
        discoveredService?.delegate = self
        discoveredService?.resolve(withTimeout: 7)

        if services.contains(service) {
            print("All ready in service array")
        } else {
            print("Adding \(service.name) to array")
            services.append(service)
        }
        

        
        if !moreComing {
           serviceManagerBrowser.stop()
           isSearching = false
        }
        
        
        
        print("Service: \(service)")

        print("Service count: \(services.count)")
        self.serviceManagerBrowser.remove(from: .main, forMode: .common)
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
                    
    
        if resolvedServices.contains(where: {$0.ipAddress == resolvedService.ipAddress}) {
           // it exists, do nothing
            print("\(resolvedService.ipAddress) for \(resolvedService.hostName) exists in network")
        } else {
            print("\(resolvedService.ipAddress) for \(resolvedService.hostName) Added to Network List")
            resolvedServices.append(resolvedService)
        }
        
       
        print("resolvedServices count: \(resolvedServices.count)")

        }
    
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("ERROR: \(errorDict)")
    }
    
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
      print("didRemove")
    }
    
}
