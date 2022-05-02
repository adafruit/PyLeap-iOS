//
//  SubCellViewModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 4/1/22.
//

import Foundation

class SubCellViewModel: ObservableObject {
    
    @Published var projectDownloaded = false
    
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    func getProjectForSubClass(nameOf project: String) {
        
        if let enumerator = FileManager.default.enumerator(at: directoryPath, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
           // for case condition: Only process URLs
            for case let fileURL as URL in enumerator {
            
                    if fileURL.lastPathComponent == project {
                        
                        projectDownloaded = true
                        print("Searching for... \(project)")
                        print("URL Path: \(fileURL.path)")
                        print("URL : \(fileURL)")
                       
                    return
                        
                    } else {
                        projectDownloaded = false
                        print("Project was not found...")
                    }
                    
                
            }
            
        }
        
    }
    
}
