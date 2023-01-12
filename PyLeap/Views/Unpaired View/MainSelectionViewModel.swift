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
    
    let fileManager = FileManager.default
    
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    let dataStore = DataStore()
    
    @Published var pdemos : [ResultItem] = []
    
    init() {
        let fileURL = documentsDirectory.appendingPathComponent("StandardPyLeapProjects.json")
        
        if fileManager.fileExists(atPath: fileURL.relativePath) {
            print("Loading cached remote data.")
            self.pdemos = self.dataStore.loadDefaultList()
            
        } else {
            print("Cached data not found. Fetching default list.")
            networkModel.fetch {
                self.pdemos = self.dataStore.loadDefaultList()
                
            }
        }
        
        
    }
    
    
}
