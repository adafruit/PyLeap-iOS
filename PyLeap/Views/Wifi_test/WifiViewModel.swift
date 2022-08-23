//
//  WifiViewModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/9/22.
//

import SwiftUI
import Foundation
import SystemConfiguration.CaptiveNetwork
import CoreLocation
import NetworkExtension

class WifiViewModel: ObservableObject {
    
    var wifiNetworkService = WifiNetworkService()
    
    public let hotspot =  NEHotspotNetwork()
    
    @Published var webDirectoryInfo = [WebDirectoryModel]()
    
//    {
//        guard let url = URL(string: "https://api.lucidtech.ai/v0/receipts"),
//            let payload = "{\"documentId\": \"a50920e1-214b-4c46-9137-2c03f96aad56\"}".data(using: .utf8) else
//        {
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("your_api_key", forHTTPHeaderField: "x-api-key")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = payload
//
//        URLSession.shared.dataTask(with: request) { (data, response, error) in
//            guard error == nil else { print(error!.localizedDescription); return }
//            guard let data = data else { print("Empty data"); return }
//
//            if let str = String(data: data, encoding: .utf8) {
//                print(str)
//            }
//        }.resume()
//    }
    
    

    
    func getInfo() {
        var semaphore = DispatchSemaphore (value: 0)
        
        NEHotspotNetwork.fetchCurrent { hotspotNetwork in
            if let ssid = hotspotNetwork?.ssid {
                           print(ssid)
                       }
        }
        
    }
    
    func getRequest() {
      
        var semaphore = DispatchSemaphore (value: 0)
        
        let username = ""
        let password = "passw0rd"
        let loginString = "\(username):\(password)"

        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()

       // var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/")!,timeoutInterval: Double.infinity)
        var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        print("Print curl:")
        print(request.cURL(pretty: true))
       
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: "Error Found: \(error)"))
            semaphore.signal()
            return
          }
         // print(String(data: data, encoding: .utf8)!)
          semaphore.signal()
            
            do {
                let wifiIncomingData = try JSONDecoder().decode([WebDirectoryModel].self, from: data)
                
                
                
                DispatchQueue.main.async {
                  //  self.pdemos = projectData!.projects
                    self.webDirectoryInfo = wifiIncomingData
                }
            } catch {
                print(error.localizedDescription)
            }
            
            if let str = String(data: data, encoding: .utf8) {
                print(str)
            }
        }
        task.resume()
        semaphore.wait()
    }
    
    func putRequest() {
      
        let parameters = "test raw data"
        let postData = parameters.data(using: .utf8)
        
        
        let username = ""
        let password = "passw0rd"
        let loginString = "\(username):\(password)"

        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()

       // var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/")!,timeoutInterval: Double.infinity)
        var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/testing.txt")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "PUT"
        request.httpBody = postData
        
        
        print("Print curl:")
        print(request.cURL(pretty: true))
       
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
            
            guard let error = error else {
              print(String(describing: error))
              
              return
            }
          
          
            
          print(String(data: data, encoding: .utf8)!)
         
        }

        task.resume()
    }
    
    
    
    /// Carter Adafruit AR
    
//    Enter IP Adress
//    Store ip Address
//    Connect
//    Found CP Board - Confirm
//    Pop in to pyleap window
//
//    Folder called Transports Bluetooth / Wifi
//    IP Address to in status bar
//
//
//    For
}

///MDSN is the IP Address
///"IP Will always work"
///circuit.local


//device.json


extension URLRequest {
    mutating func setBasicAuth(username: String, password: String) {
        let encodedAuthInfo = String(format: "%@:%@", username, password)
            .data(using: String.Encoding.utf8)!
            .base64EncodedString()
        addValue("Basic \(encodedAuthInfo)", forHTTPHeaderField: "Authorization")
    }
}

extension URLRequest {
    public func cURL(pretty: Bool = false) -> String {
        let newLine = pretty ? "\\\n" : ""
        let method = (pretty ? "--request " : "-X ") + "\(self.httpMethod ?? "GET") \(newLine)"
        let url: String = (pretty ? "--url " : "") + "\'\(self.url?.absoluteString ?? "")\' \(newLine)"
        
        var cURL = "curl "
        var header = ""
        var data: String = ""
        
        if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
            for (key,value) in httpHeaders {
                header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
            }
        }
        
        if let bodyData = self.httpBody, let bodyString = String(data: bodyData, encoding: .utf8),  !bodyString.isEmpty {
            data = "--data '\(bodyString)'"
        }
        
        cURL += method + url + header + data
        
        return cURL
    }
}
