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
    
}
