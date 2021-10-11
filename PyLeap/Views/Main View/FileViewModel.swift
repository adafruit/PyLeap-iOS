//
//  FileViewModel.swift
//  SwiftUI File Manager
//
//  Created by Trevor Beaton on 7/11/21.
//

import SwiftUI
import Zip


class FileViewModel: ObservableObject {
    
    @Published var fileArray: [ContentFile] = []
    @Published var projects: [Project] = []
    
    
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    let cachesPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    
    func startup(){
        print("Directory Path: \(directoryPath.path)")
        print("Caches Directory Path: \(cachesPath.path)")

        
        do {
            
            let contents = try FileManager.default.contentsOfDirectory(at: directoryPath, includingPropertiesForKeys: nil,options: [.skipsHiddenFiles])
            
            for file in contents {
                print("File Content: \(file.lastPathComponent)")
              //  print("File Size: \(fileSize)")
                
               let addedFile = ContentFile(title: file.lastPathComponent)
                self.fileArray.append(addedFile)
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    //MARK:- Copied From Glider App
    
    // Published

   
    
}
