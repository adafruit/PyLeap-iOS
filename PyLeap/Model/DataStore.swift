//
//  DataStore.swift
//  PyLeap
//
//  Created by Trevor Beaton on 1/11/23.
//

import Foundation

/**
 /// This is a DataStore class that is used for saving and loading data to/from the file system using the FileManager class.
 */

public class DataStore: ObservableObject {
    
    let fileManager = FileManager.default
    
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    init() {}
    
    /**
     - parameter content: This method takes an array of ResultItem objects.
     
     - returns: completion
     
     /// This method writes it to a file named "StandardPyLeapProjects.json" in the documents directory.
     */
    
    func save(content: [ResultItem], completion: @escaping () -> Void) {
        print(#function)
        let encoder = JSONEncoder()
        if let encodedProjectData = try? encoder.encode(content) {
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("StandardPyLeapProjects.json")
            try? encodedProjectData.write(to: fileURL)
            completion()
        }
    }
    
    /**
     - parameter content: This method takes an array of ResultItem objects.
     
     - returns: completion
     
     /// This method reads the "StandardPyLeapProjects.json" file in the documents directory and decodes it as an array of ResultItem objects, and then appends the customProjects array to it and saves it back to the file.
     */
    
    func save(customProjects: [ResultItem], completion: @escaping () -> Void) {
        
        var temp = customProjects
        
        let fileURL = documentsDirectory.appendingPathComponent("StandardPyLeapProjects.json")
        let savedData = try? Data(contentsOf: fileURL)
        
        if let savedData = savedData,
           let savedProjects = try? JSONDecoder().decode([ResultItem].self, from: savedData) {
            NotificationCenter.default.post(name: .didCollectCustomProject, object: nil, userInfo: nil)
            temp.append(contentsOf: savedProjects)
            
            save(content: temp) {
                self.removeDuplicates(projectList: temp)
            }
            completion()
        }
    }
    
    /**
     /// This method reads the "StandardPyLeapProjects.json" file in the documents directory and decodes it as an array of ResultItem objects, and then calls the loadCustomProjectList(contents:) method with the decoded array as an argument
     */
    
    func loadDefaultProjectList() {
        
        let fileURL = documentsDirectory.appendingPathComponent("StandardPyLeapProjects.json")
        let savedData = try? Data(contentsOf: fileURL)
        
        if let savedData = savedData,
           let savedProjects = try? JSONDecoder().decode([ResultItem].self, from: savedData) {
            loadCustomProjectList(contents: savedProjects)
        }
    }
    
    /**
     ///  This method reads the "StandardPyLeapProjects.json" file in the documents directory, decodes it as an array of ResultItem objects, and returns it.
     */
    
    func loadDefaultList() -> [ResultItem] {
        
        var result = [ResultItem]()
        let fileURL = documentsDirectory.appendingPathComponent("StandardPyLeapProjects.json")
        
        let savedData = try? Data(contentsOf: fileURL)
        
        if let savedData = savedData,
           let savedProjects = try? JSONDecoder().decode([ResultItem].self, from: savedData) {
            result = savedProjects
        }
        return result
    }
    
    /**
     - parameter: This method takes an array of ResultItem objects
     
     - returns: completion
     
     /// This method reads the "CustomProjects.json" file in the documents directory, decodes it as an array of ResultItem objects, appends it to the input array, and then calls
     */
    
    func loadCustomProjectList(contents: [ResultItem]) {
        var temp = contents
        
        let fileURL = documentsDirectory.appendingPathComponent("CustomProjects.json")
        let savedData = try? Data(contentsOf: fileURL)
        
        if let savedData = savedData,
           let savedProjects = try? JSONDecoder().decode([ResultItem].self, from: savedData) {
            temp.append(contentsOf: savedProjects)
            removeDuplicates(projectList: temp)
            
        }
    }
    
    /**
     - parameter: This method takes an array of ResultItem objects
     
     - returns: completion
     
     /// This method uses the reduce(into:_:) method to iterate over the array, and it builds a new array that only contains unique ResultItem objects based on their bundleLink property. It then calls the save(content:completion:) method to save the new array to "StandardPyLeapProjects.json" file.
     */
    
    func removeDuplicates(projectList: [ResultItem]) {
        
        let combinedLists = projectList.reduce(into: [ResultItem]()) { (result, projectList) in
            
            if !result.contains(where: { $0.bundleLink == projectList.bundleLink }) {
                result.append(projectList)
            }
        }
        save(content: combinedLists) {}
    }
    
    func loadThirdPartyProjectsFromFileManager() {
        
        let fileURL = documentsDirectory.appendingPathComponent("CustomProjects.json")
        let savedData = try? Data(contentsOf: fileURL)
        
        if let savedData = savedData,
           let savedProjects = try? JSONDecoder().decode([ResultItem].self, from: savedData) {
            
            for project in savedProjects {
                print("CustomProjects name: \(project.projectName)")
            }
        }
    }
    
    
    
}
