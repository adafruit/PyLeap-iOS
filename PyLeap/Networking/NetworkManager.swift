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
    
    static let shared = NetworkService()
        
    @Published var pdemos = [ResultItem]()
    @State var storedURL = ""
    
    let userDefaults = UserDefaults.standard
    
    init(){
        fetch()
//        load()
//        loadCustProjects()
    }
    
    func loadCustProjects() {
        
        if let savedProjects = userDefaults.object(forKey: "CustomProjects") as? Data {
            
            let decoder = JSONDecoder()
            
            if let loadedProjects = try? decoder.decode([ResultItem].self, from: savedProjects) {
                
                print("++++Custom Projects++++")
                for i in loadedProjects {
                    print("\(i.projectName)")
                }
            }
        }
    }
    
    
    func save(content: [ResultItem]) {
        print("Saving JSON response...")
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(content) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "SavedProjects")
        }
        
    }
    
    func save(customProjects: [ResultItem]) {
        
        NotificationCenter.default.post(name: .didCollectCustomProject, object: nil, userInfo: nil)
        
        let encoder = JSONEncoder()
        
        if let encoded = try? encoder.encode(customProjects) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "CustomProjects")
        }
        
        saveCustomProjects(content: customProjects)
        
    }
    
    func saveCustomProjects(content: [ResultItem]) {
        print("\(#function) @Line: \(#line)")
        NotificationCenter.default.post(name: .didCollectCustomProject, object: nil, userInfo: nil)
        //  if let newIncoming = content.contains()
        
        var customList: [ResultItem] = []
        
        if let savedProjects = userDefaults.object(forKey: "CustomProjects") as? Data {
            
            print("if let savedProjects = userDefaults.object(forKey: CustomProjects) as? Data")
            
            let decoder = JSONDecoder()
            
            if let loadedProjects = try? decoder.decode([ResultItem].self, from: savedProjects) {
                print("Loading previous list")
                
                
                print("\(#function) @Line: \(#line)")
                for i in loadedProjects {
                    
                    print("\(i.projectName)")
                }
                
                customList = loadedProjects
                print("Appending new content")
                
                customList.append(contentsOf: content)
                
                for i in customList {
                    print("\(i.projectName)")
                }
                
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(customList) {
                    let defaults = UserDefaults.standard
                    print("Saved new custom list.")
                    defaults.set(encoded, forKey: "CustomProjects")
                }
                
                
            }
        } else {
            print("Saving Error")
        }
        
    }
    
    func verifyIncomingProject(json response: [ResultItem]){
        
        if let savedProjects = userDefaults.object(forKey: "CustomProjects") as? Data {
            
            let decoder = JSONDecoder()
            
            if let loadedProjects = try? decoder.decode([ResultItem].self, from: savedProjects) {
                /// Does incoming project exist already?
                /// Check with object's property URL
                
                
                if loadedProjects.contains(where: { $0.bundleLink == response[0].bundleLink
                }) {
                    print("does exist")
                    
                } else {
                    
                    print("does not exist")
                }
                
                print(loadedProjects)
                
            }
            
        }
        
    }
    
    func loadCustomProjects() -> [ResultItem]{
        print("\(#function) is called twice to run. Ignore this method.")
        var customList: [ResultItem] = []
        if let savedProjects = userDefaults.object(forKey: "CustomProjects") as? Data {
            
            let decoder = JSONDecoder()
            
            if let loadedProjects = try? decoder.decode([ResultItem].self, from: savedProjects) {
                
                print("Load custom projectsxo")
                // print(loadedProjects)
                
                for i in loadedProjects {
                    print("\(i.projectName)")
                }
                
                customList = loadedProjects
                
            }
        }
        return customList
    }
    
    func mergeProjects() {
        print(#function)
        
        var standardList: [ResultItem] = []
        var customList: [ResultItem] = []
        
        if let savedProjects = userDefaults.object(forKey: "SavedProjects") as? Data {
            
            let decoder = JSONDecoder()
            
            if let loadedProjects = try? decoder.decode([ResultItem].self, from: savedProjects) {
                
                print("Load saved projects")
                
                // let check = loadedProjects.map { $0.bundleLink == "" }
                
                pdemos = loadedProjects
                
                print(loadedProjects)
                
            }
        }
        
        
        if let savedProjects = userDefaults.object(forKey: "CustomProjects") as? Data {
            
            let decoder = JSONDecoder()
            
            if let loadedProjects = try? decoder.decode([ResultItem].self, from: savedProjects) {
                
                print("Load saved projects")
                
                print(loadedProjects)
                
            }
        }
    }
    
    func load() {
        
        if let savedProjects = userDefaults.object(forKey: "SavedProjects") as? Data {
            
            let decoder = JSONDecoder()
            
            if let loadedProjects = try? decoder.decode([ResultItem].self, from: savedProjects) {
                
                
                let mergedList = loadedProjects + loadCustomProjects()
                
                // save(content: <#T##[ResultItem]#>)
                
                pdemos = mergedList
                
                
           //     print("----Standard Projects----")
                for i in loadedProjects {
                  //  print("\(i.projectName)")
                }
                
           //     print("++++Custom Projects++++")
                for i in loadCustomProjects() {
                 //   print("\(i.projectName)")
                }
                
                
                
            }
            
        }
        
        
    }
    
    private var dataTask: URLSessionDataTask?
    
    private lazy var session: URLSession = {
        // Set Cache Memory to 419 MB
        //   URLCache.shared.memoryCapacity = 400 * 1024 * 1024
        
        // Session Configuration & Caching Policy
        let configuration = URLSessionConfiguration.default
        //        configuration.requestCachePolicy = .useProtocolCachePolicy
        
        return URLSession(configuration: configuration)
    }()
    
    @Published var projectInfo = Data()
    
    func fetch() {
        
        let cache = URLCache.shared
        
        let requestForCache = URLRequest(url: URL(string: AdafruitInfo.baseURL)!)
        
        let request = URLRequest(url: URL(string: AdafruitInfo.baseURL)!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        
        print("Making Network Request")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("error: \(error)")
            }
            
            if let data = data {
                
                print("Updating UIList with new data...")
                if let projectData = try? JSONDecoder().decode(RootResults.self, from: data) {
                    
                    DispatchQueue.main.async {
                        
//                        for i in projectData.projects {
//                            print("\(i.projectName)")
//                        }
                        
                        self.save(content: projectData.projects)
                        self.load()
                    }
                    
                    
                } else {
                    print("No data found")
                }
                
            } else {
                
                print("Updating UIList with Cached data...")
                DispatchQueue.main.async {
                    self.load()
                }
            }
        }
        task.resume()
    }
    
    func fetchThirdParyProject(urlString: String?) {
        let cache = URLCache.shared
        
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
        
        
        let request = URLRequest(url: requestURL, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        
        
        print("Making Network Request for Custom Project.")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Could not load project. Please check your URL Invalid URL: \(urlString)")
                
                NotificationCenter.default.post(name: .invalidCustomNetworkRequest, object: nil, userInfo: nil)
                
                return
            }
            
            if let data = data {
                
                print("Updating UIList with new data...")
                let projectData = try? JSONDecoder().decode(RootResults.self, from: data)
                
                if let projects = projectData?.projects {
                    
                    DispatchQueue.main.async {
                        print(#function)
                        for i in projects {
                            print("\(i.projectName)")
                        }
                        //  self.pdemos.append(contentsOf: projects)
                       // self.saveCustomProjects(content: projects)
                        self.save(customProjects: projects)
                        
                    }
                    
                }
                
            }
            
        }
        task.resume()
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
