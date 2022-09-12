//
//  NetworkManager.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/23/22.
//

import Foundation
import UIKit

class NetworkService: ObservableObject {
    
    static let shared = NetworkService()
    
    @Published var pdemos : [ResultItem] = []
    
    let baseURL = "https://adafruit.github.io/pyleap.github.io/pyleapProjects.json"
    
    init(){
        fetch(stringURL: baseURL)
    }
    
    private var dataTask: URLSessionDataTask?
    
    private lazy var session: URLSession = {
        // Set Cache Memory to 419 MB
        URLCache.shared.memoryCapacity = 400 * 1024 * 1024
        
        // Session Configuration & Caching Policy
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .useProtocolCachePolicy
        
        return URLSession(configuration: configuration)
    }()
    
    @Published var projectInfo = Data()
    
    func fetch(stringURL: String) {
        let cache = URLCache.shared
        let request = URLRequest(url: URL(string: stringURL)!, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 60.0)
        
        if let data = cache.cachedResponse(for: request)?.data {
            print("got image from cache")
            //self.projectInfo = data
            let projectData = try? JSONDecoder().decode(RootResults.self, from: data)
            self.pdemos = projectData!.projects
        }
        
        print("fetching...")
        session.dataTask(with: URL(string: baseURL)!) { (data, _, _) in
            
            guard let data = data else {
                print("No data found")
                return }
            
            do {
                let projectData = try? JSONDecoder().decode(RootResults.self, from: data)
                
                
                
                DispatchQueue.main.async {
                    self.pdemos = projectData!.projects
                }
            } catch {
                print(error.localizedDescription)
            }
            
            
            
            
        }.resume()
    }
    
    func fetchThirdParyProject(stringURL: String) {
        print(#function)
        let cache = URLCache.shared
        let request = URLRequest(url: URL(string: stringURL)!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        
        //        if let data = cache.cachedResponse(for: request)?.data {
        //            print("got image from cache")
        //            //self.projectInfo = data
        //            let projectData = try? JSONDecoder().decode(RootResults.self, from: data)
        //            self.pdemos = projectData!.projects
        //        }
        
        print("fetching...")
        session.dataTask(with: URL(string: stringURL)!) { (data, _, error) in
            
            if let error = error {
                print("Invalid URL: \(stringURL)")
                return
            }
            
            guard let data = data else {
                print("No data found")
                return }
            
            do {
                let projectData = try? JSONDecoder().decode(RootResults.self, from: data)
                
                DispatchQueue.main.async {
                    
                    if let projects = projectData?.projects {
                        
                       // self.pdemos.append(contentsOf: projects)
                        print(NetworkService.shared.pdemos)
                        
                        
                        if let data = cache.cachedResponse(for: request)?.data {
                            print("got image from cache")
                            self.projectInfo = data
                            self.pdemos.append(contentsOf: projects)
//                            let projectData = try? JSONDecoder().decode(RootResults.self, from: data)
//                            self.pdemos = projectData!.projects
                        }
                        
                        // https://trevknows.github.io/testLeap.github.io/testLeap.json
                    } else {
                        print("error \(#function) \(#line)")
                    }
                    
                    // self.pdemos = projectData!.projects
                }
            } catch {
                print("Error \(#function) \(#line)")
                print(error.localizedDescription)
            }
            
            
            
        }.resume()
    }
    
}


