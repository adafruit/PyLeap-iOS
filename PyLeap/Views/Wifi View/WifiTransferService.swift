//
//  WifiTransferService.swift
//  PyLeap
//
//  Created by Trevor Beaton on 9/13/22.
//

import Foundation
import SwiftUI

protocol WifiTransferServiceDelegate: AnyObject {
    func startup()
    
   func sendPutRequest(fileName: String,body: Data,then handler: @escaping(Result<Data, Error>) -> Void)
}

class WifiTransferService: ObservableObject {

    weak var delegate: WifiTransferServiceDelegate?
    
    let userDefaults = UserDefaults.standard
    private let kPrefix = Bundle.main.bundleIdentifier!
    
    @Published var counter = 0
    
    @Published var webDirectoryInfo = [WebDirectoryModel]()
    
    @Published var hostName = ""
    
    func startup() {
          print("\(#function) @Line: \(#line)")
        if (userDefaults.object(forKey: kPrefix+".storeResolvedAddress.hostName")) != nil {
            print(userDefaults.object(forKey: kPrefix+".storeResolvedAddress.hostName") as! String)
            
            hostName = userDefaults.object(forKey: kPrefix+".storeResolvedAddress.hostName") as! String
            print("\(#line) \(hostName)")
        }
            
    
    }
    
    init() {
        startup()
    }
    
    func sendPutRequest(fileName: String,
                        body: Data,
                        then handler: @escaping(Result<Data, Error>) -> Void) {
        
        var urlSession = URLSession.shared
        
        print(#function)
        let parameters = body
        let postData = parameters
        
        postData.base64EncodedData(options: []).description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let username = ""
        let password = "passw0rd"
        let loginString = "\(username):\(password)"
        
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        // var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/")!,timeoutInterval: Double.infinity)
        var request = URLRequest(url: URL(string: "http://\(hostName).local/fs/\(fileName)")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "PUT"
        request.httpBody = postData
        
        print("Print curl:")
        print(request.cURL(pretty: true))
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          
            if let error = error  {
                print("File write error")
                
                handler(.failure(error))
                
            }
            
            if let data = data {
                print("File write success!")
                handler(.success(data))
            }
        }
        
        task.resume()
        
    }
    
    func optionRequest(handler: @escaping(Result<String, Error>) -> Void) {
        
        print("HOST | \(hostName)")
        let username = ""
        let password = "passw0rd"
        let loginString = "\(username):\(password)"
        
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
       
        var request = URLRequest(url: URL(string: "http://\(hostName).local/fs/")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "OPTIONS"
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: [:], options: [])
        
        print("Print curl:")
        
        print(request.cURL(pretty: true))
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          
            if let response = response as? HTTPURLResponse {
                 
                print("Response HTTP Status code: \(response.statusCode)")
                
                print("Specific header: \(response.value(forHTTPHeaderField: "Access-Control-Allow-Methods") ?? "Header Not found")")
                handler(.success(response.value(forHTTPHeaderField: "Access-Control-Allow-Methods") ?? "Header Not found"))
              }
            
            if let error = error  {
                print("File write error")
                
                handler(.failure(error))
                
            }
            
            
            
            guard let data = data else {
                print(String(describing: "Error Found: \(String(describing: error))"))
                print("Failed! Option Request")
                return
            }

            if let str = String(data: data, encoding: .utf8) {
                print("Output:")
                print(str)
            }
        }
        
        task.resume()
        
    }
    
    
    func getRequest() {
       
        print("HOST | \(hostName)")
        let username = ""
        let password = "passw0rd"
        let loginString = "\(username):\(password)"
        
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
       
        // var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/")!,timeoutInterval: Double.infinity)
        var request = URLRequest(url: URL(string: "http://\(hostName).local/fs/")!,timeoutInterval: Double.infinity)
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = "GET"
        
        print("Print curl:")
        print(request.cURL(pretty: true))
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: "Error Found: \(error)"))
                return
            }
            
            do {
                let wifiIncomingData = try JSONDecoder().decode([WebDirectoryModel].self, from: data)
                
                DispatchQueue.main.async {
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
    }
    
    //completion: @escaping (Bool) -> Void
    
    typealias CompletionHandler = (_ success:String) -> Void

    
    func getRequest(read: String, completionHandler: @escaping CompletionHandler){
        
        var semaphore = DispatchSemaphore (value: 0)
        
        let username = ""
        let password = "passw0rd"
        let loginString = "\(username):\(password)"
        
        var outgoingString = String()
        
        let loginData = loginString.data(using: String.Encoding.utf8)
           
        
        let base64LoginString = loginData!.base64EncodedString()
        
        print("Host Name: \(hostName)")
        
        var request = URLRequest(url: URL(string: "http://\(hostName).local/fs/\(read)")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        print("Print curl:")
        print(request.cURL(pretty: true))
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: "Error Found: \(error)"))
                return
            }
            // print(String(data: data, encoding: .utf8)!)
            
            do {
                let wifiIncomingData = try JSONDecoder().decode([WebDirectoryModel].self, from: data)
                
                DispatchQueue.main.async {
                    self.webDirectoryInfo = wifiIncomingData
                }
            } catch {
                print(error.localizedDescription)
            }
            
            if let str = String(data: data, encoding: .utf8) {
                print(str)
                outgoingString = str
                print("\(#function) @Line: \(#line)")
                completionHandler(outgoingString)
                
            } else {
                print("\(#function) @Line: \(#line)")
                print("Error")
            }
            
        }
        task.resume()
    }
    
    typealias CompletionHandlerForCheck = (_ success: [WebDirectoryModel]) -> Void

    
    func getRequestForFileCheck(read: String, completionHandler: @escaping CompletionHandlerForCheck){
        
        print("Incoming Read String: \(read)")
        var semaphore = DispatchSemaphore (value: 0)
        
        let username = ""
        let password = "passw0rd"
        let loginString = "\(username):\(password)"
        
        var outgoingString = String()
        
        let loginData = loginString.data(using: String.Encoding.utf8)
           
        
        let base64LoginString = loginData!.base64EncodedString()
        
        print("Host Name: \(hostName)")
        
        var request = URLRequest(url: URL(string: "http://\(hostName).local/fs/\(read)")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        print("GET Request: \(String(describing: request.url?.absoluteURL))\n")
        
        print("Print curl:")
        print(request.cURL(pretty: true))
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: "Error Found: \(error)"))
                return
            }
            // print(String(data: data, encoding: .utf8)!)
            
            do {
                let wifiIncomingData = try JSONDecoder().decode([WebDirectoryModel].self, from: data)
                
                DispatchQueue.main.async {
                    self.webDirectoryInfo = wifiIncomingData
                    completionHandler(self.webDirectoryInfo)
                    print("On completion \(self.webDirectoryInfo)")
                }
            } catch {
                print(error.localizedDescription)
            }
            
            if let str = String(data: data, encoding: .utf8) {
                print(str)
                outgoingString = str
                print("\(#function) @Line: \(#line)")
                
            } else {
                print("\(#function) @Line: \(#line)")
                print("Error")
            }
            
        }
        task.resume()
    }
    
    
    //  func putDirectory(directoryPath: String, completion: @escaping (Result<Data?, Error>) -> Void) {
    
    func putRequest(fileName: String, fileContent: Data, completion: @escaping (Result<Data?, Error>) -> Void) {
        print("Test Transfer")
        let parameters = fileContent
        let postData = parameters
        
        let username = ""
        let password = "passw0rd"
        let loginString = "\(username):\(password)"
        
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        // var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/")!,timeoutInterval: Double.infinity)
        var request = URLRequest(url: URL(string: "http://\(hostName).local/fs/\(fileName)")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "PUT"
        request.httpBody = postData
        
        print("Print curl:")
        print(request.cURL(pretty: true))
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error  {
                print("File write error")
                
                completion(.failure(error))
                
            }
            
            if let data = data {
                print("File write success!")
                completion(.success(data))
            }
            
            // print(String(data: data, encoding: .utf8)!)
            
        }
        task.resume()
    }
    
    // Make
    func putDirectory(directoryPath: String, completion: @escaping (Result<Data?, Error>) -> Void) {
        print("\(#function) @Line: \(#line)")
      
        let username = ""
        let password = "passw0rd"
        let loginString = "\(username):\(password)"
        
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        var request = URLRequest(url: URL(string: "http://\(hostName).local/fs/\(directoryPath)/")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        
        print("Print curl:")
        print(request.cURL(pretty: true))
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            
            if let response = response as? HTTPURLResponse {
                
                print("Response HTTP Status code: \(response.statusCode)")
                
            }
            
            if let error = error  {
                completion(.failure(error))
                
            }
            
            if let data = data {
                completion(.success(data))
            }
            
        }
        
        task.resume()
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
        var request = URLRequest(url: URL(string: "http://\(hostName).local/fs/testing.txt")!,timeoutInterval: Double.infinity)
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
    
    func deleteRequest() {
        
        let username = ""
        let password = "passw0rd"
        let loginString = "\(username):\(password)"
        
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        // var request = URLRequest(url: URL(string: "http://cpy-9cbe10.local/fs/")!,timeoutInterval: Double.infinity)
        var request = URLRequest(url: URL(string: "http://\(hostName).local/fs/testing.txt")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "DELETE"
        
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
            
            //  print(String(data: data, encoding: .utf8)!)
            
        }
        task.resume()
    }
    
    
    
}
