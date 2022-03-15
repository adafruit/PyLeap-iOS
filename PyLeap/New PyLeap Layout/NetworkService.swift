//
//  NetworkService.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/14/22.
//

import Foundation

class NetworkService: ObservableObject {

    @Published var pdemos : [ResultItem] = []
    let baseURL = "https://adafruit.github.io/pyleap.github.io/PyLeapProjects.json"
   
    init(){
        fetch()
    }
    
    func fetch() {
        print("Fetching data...")
        let session = URLSession(configuration: .default)
        session.dataTask(with: URL(string: baseURL)!) { (data, _, _) in
            
            do {
                let projectData = try? JSONDecoder().decode(RootResults.self, from: data!)
                
                DispatchQueue.main.async {
                    self.pdemos = projectData!.projects
                    print(projectData)
                }
            } catch {
                print(error.localizedDescription)
            }
            
        }.resume()
    }

  
}
