//
//  WifiSubViewCellModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 9/1/22.
//

import Foundation

class WifiSubViewCellModel: ObservableObject {
    
    @Published var projectDownloaded = false
    @Published var failedProjectLaunch = false
    
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    func searchPathForProject(nameOf project: String) {
        var manager = FileManager.default

        let nestedFolderURL = directoryPath.appendingPathComponent(project)
        
        if manager.fileExists(atPath: nestedFolderURL.relativePath) {
          print("\(project) - Exist")
            projectDownloaded = true
        } else {
            print("Does not exist - \(project)")
           projectDownloaded = false
        }
    }
    
    

    
}
