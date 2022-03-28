//
//  ProjectsModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/24/22.
//


import Foundation

struct RootResults: Decodable {
    let projects: [ResultItem]
}

struct ResultItem: Codable, Identifiable {
    enum CodingKeys: CodingKey {
        case projectName
        case projectImage
        case description
        case bundleLink
        case learnGuideLink
        case compatibility
    }
    
    var id = UUID()
    let uniqueID = String()
    let projectName: String
    let projectImage: String
    let description: String
    let bundleLink: String
    let learnGuideLink: String
    let compatibility: [String]
}
