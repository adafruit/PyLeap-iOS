//
//  CircuitPythonService.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/24/22.
//

import Foundation

class CircuitPythonService:Equatable{
    
    var netService:NetService
    var ipAddress:String
    
    init(netService:NetService, ipAddress:String) {
        self.netService = netService
        self.ipAddress = ipAddress
    }
    
    func getAddress() -> String {
        return ipAddress
    }
    
    func getPort() -> Int{
        return netService.port
    }
    
    func getName() -> String{
        return netService.name
    }

}

func == (lhs: CircuitPythonService, rhs: CircuitPythonService) -> Bool {
    return (lhs.netService == rhs.netService) && (lhs.ipAddress == rhs.ipAddress)
}
