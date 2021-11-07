//
//  BundleDownloadVModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 11/2/21.
//

import SwiftUI

class BundleDownloadVModel: NSObject, ObservableObject {
    
    @Published var fileArray: [ContentFile] = []
    
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let cachesPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    
    func startup() {
        print("Directory Path: \(directoryPath.path)")
        print("Caches Directory Path: \(cachesPath.path)")

        
        do {
            
            let contents = try FileManager.default.contentsOfDirectory(at: directoryPath, includingPropertiesForKeys: nil,options: [.skipsHiddenFiles])
           
            for file in contents {
                print("File Content: \(file.lastPathComponent)")

                
               let addedFile = ContentFile(title: file.lastPathComponent)
                self.fileArray.append(addedFile)
            }
            
            //MARK:- CircuitPython7
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo").appendingPathComponent("CircuitPython 7.x")
            
            let fileURLs = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            
            for i in fileURLs {
                print("Folder: \(i.lastPathComponent)")
            }
            
            let libPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
           
            let subFileURLs = try FileManager.default.contentsOfDirectory(at: libPath, includingPropertiesForKeys: nil)
           
            for i in subFileURLs {
                print("Sub: \(i.lastPathComponent)")
                
            }
            
            
            let neopixelPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("code.py")
           
            let neopixelURL = try FileManager.default.contentsOfDirectory(at: neopixelPath, includingPropertiesForKeys: nil)
            
            let text2 = try String(contentsOf: neopixelPath)
            
            print("CONTENT: \(text2)")
            

        } catch {
            print("Error: \(error)")
        }
        
    }
    
}
