//
//  NetworkManager.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/23/22.
//

import Foundation

class NetworkService: ObservableObject {

    @Published var pdemos : [ResultItem] = []
    
    let baseURL = "https://adafruit.github.io/pyleap.github.io/pyleapProjects.json"
   
    init(){
        fetch()
    }
    
    private var dataTask: URLSessionDataTask?
       
       private lazy var session: URLSession = {
           // Set Cache Memory to 419 MB
           URLCache.shared.memoryCapacity = 400 * 1024 * 1024
           
           // Session Configuration & Caching Policy
           let configuration = URLSessionConfiguration.default
           configuration.requestCachePolicy = .returnCacheDataElseLoad
           
           return URLSession(configuration: configuration)
       }()
    
    func fetch() {
        session.dataTask(with: URL(string: baseURL)!) { (data, _, _) in
            
            guard let data = data else {
                print("No cached data found")
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

}
