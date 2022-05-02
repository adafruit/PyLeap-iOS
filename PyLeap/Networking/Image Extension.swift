//
//  Image Extension.swift
//  PyLeap
//
//  Created by Trevor Beaton on 4/22/22.
//

import SwiftUI


extension Image {
    
    func data(url:URL) -> Self {
        
        if let data = try? Data(contentsOf: url) {
            return Image(uiImage: UIImage(data: data)!)
                .resizable()
        }
        return self
        .resizable()
    }
}


