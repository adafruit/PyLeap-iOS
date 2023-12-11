//
//  NetworkManager.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/23/22.
//
/// Single project
// https://trevknows.github.io/testLeap.github.io/testLeap.json

/// Multiple projects - 3
// https://trevknows.github.io/multiple-project-test/multipleProjects.json

import Foundation
import SwiftUI

class NetworkService: ObservableObject {
   
    let dataStore = DataStore()
    
    let thirdPartyBackgroundQueue = DispatchQueue(label: "com.PyLeap.thirdPartyBackgroundQueue", qos: .background, attributes: .concurrent)
    
    private var dataTask: URLSessionDataTask?
    
    private lazy var session: URLSession = {
        // Set Cache Memory to 419 MB
        //   URLCache.shared.memoryCapacity = 400 * 1024 * 1024
        
        // Session Configuration & Caching Policy
        let configuration = URLSessionConfiguration.default
           configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        return URLSession(configuration: configuration)
    }()
    
    
    func fetch(completion: @escaping() -> Void) {
        print("Attempting Network Request")
        let request = URLRequest(url: URL(string: AdafruitInfo.baseURL)!)
        let task = session.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("error: \(error)")
                print("Updating UIList with Cached data...")
                DispatchQueue.main.async {
                    self.dataStore.loadDefaultProjectList()
                    completion()
                }
                return
            }
            
            if let data = data {
                print("Updating storage with new data.")
                do {
                    let projectData = try JSONDecoder().decode(RootResults.self, from: data)
                    dump(projectData.projects)
                    
                    DispatchQueue.main.async {
                        self.dataStore.save(content: projectData.projects, completion: self.dataStore.loadDefaultProjectList)
                        completion()
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
                
            }
        }
        task.resume()
    }

    
    
    func fetchThirdPartyProject(urlString: String?) {

        thirdPartyBackgroundQueue.async {
            
            guard let urlString = urlString else {
                print("\(#function) @Line: \(#line)")
                NotificationCenter.default.post(name: .invalidCustomNetworkRequest, object: nil, userInfo: nil)
                print("Error urlString")
                return
            }
            
            if urlString.contains(" ") {
                NotificationCenter.default.post(name: .invalidCustomNetworkRequest, object: nil, userInfo: nil)
                return
            }
            
            guard let requestURL = URL(string: urlString) else {
                print("\(#function) @Line: \(#line)")
                print("Error requestURL")
                NotificationCenter.default.post(name: .invalidCustomNetworkRequest, object: nil, userInfo: nil)
                return
            }
            
            let request = URLRequest(url: requestURL, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 0.0)
            
            print("Making Network Request for Custom Project.")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let error = error {
                    print("Could not load project. Please check your URL Invalid URL: \(urlString)")
                    
                    NotificationCenter.default.post(name: .invalidCustomNetworkRequest, object: nil, userInfo: nil)
                    
                    return
                }
                
                if let data = data {
                                      
                    let projectData = JSONDecoderHelper.decode(data: data) as RootResults?
                    
                    if let projects = projectData?.projects {
                        
                        DispatchQueue.main.async {
                            self.dataStore.save(customProjects: projects, completion: self.dataStore.loadThirdPartyProjectsFromFileManager)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    



}




extension URLSession {
    // 1
    func dataTask(with url: URL,
                  cachedResponseOnError: Bool,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        return self.dataTask(with: url) { (data, response, error) in
            // 2
            if cachedResponseOnError,
               let error = error,
               let cachedResponse = self.configuration.urlCache?.cachedResponse(for: URLRequest(url: url)) {
                
                completionHandler(cachedResponse.data, cachedResponse.response, error)
                return
            }
            
            // 3
            completionHandler(data, response, error)
        }
    }
}
