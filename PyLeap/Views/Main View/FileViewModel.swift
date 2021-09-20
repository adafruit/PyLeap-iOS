//
//  FileViewModel.swift
//  SwiftUI File Manager
//
//  Created by Trevor Beaton on 7/11/21.
//

import SwiftUI
import Zip


class FileViewModel: ObservableObject {
    
    private var selectedPeripheral: BlePeripheral?
    
    @Published var fileArray = [ContentFile]()
    @Published var projects = [Project]()
    
    
    
    enum Router {
        
        
        
    }
    
    
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    let cachesPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    
    static func modelPaired(model: BlePeripheral.AdafruitManufacturerData.BoardModel?) -> [Project] {
        guard let model = model else { return [] }

        var projectBundle = [Project]()
        
        switch model {
        case .circuitPlaygroundBluefruit:
            projectBundle = ProjectData.cpbProjects
        case .clue_nRF52840:
            projectBundle = ProjectData.clueProjects
        default:
            projectBundle = []
        }
        
        return projectBundle
    }
    
    func startup(){
        print("Startup")
    
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
