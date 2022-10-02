//
//  MainSelectionViewModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 9/29/22.
//

import Foundation
import SwiftUI

class MainSelectionViewModel: ObservableObject {
 
    @ObservedObject var networkModel = NetworkService()

    let userDefaults = UserDefaults.standard
    
    @Published var pdemos : [ResultItem] = []
    
    init() {
      //  load()
       // self.pdemos = load()
    }
    
    func makeNetworkCall(){
        networkModel.fetch()
    }
    
    
    
    func load() -> [ResultItem] {
        if let savedProjects = userDefaults.object(forKey: "SavedProjects") as? Data {
            
            let decoder = JSONDecoder()
            
            if let loadedProjects = try? decoder.decode([ResultItem].self, from: savedProjects) {
                
                print("Load saved projects")
                print(loadedProjects)
               // pdemos = loadedProjects
                return loadedProjects
            }
            
        }
        print("Returned Empty pdemos")
        return []
    }
    
    
    
}
