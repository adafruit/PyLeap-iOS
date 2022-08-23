//
//  WebDirectoryModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/23/22.
//

import Foundation

struct WebDirectoryModel: Codable, Identifiable {
    
    enum CodingKeys: CodingKey {
        case name
        case directory
        case modified_ns
        case file_size
    }
    
    var id = UUID()
    let uniqueID = String()
    let name: String
    let directory: Bool
    let modified_ns:Int
    let file_size: Int
}
