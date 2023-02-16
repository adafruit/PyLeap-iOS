//
//  NetworkPeripheral.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/24/22.
//

import Foundation

open class NetworkPeripheral: NSObject {

    var peripheral: NetService
    
    public init(peripheral: NetService) {
        self.peripheral = peripheral
        
        super.init()
        self.peripheral.delegate = self
    }
    
    open var name: String {
        return peripheral.name
    }
    
    open var hostName: String? {
        return peripheral.hostName
    }
   
    
    
    
    
}
extension NetworkPeripheral: NetServiceDelegate {
    
    
    
}
