//
//  ProjectsModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/24/22.
//


import Foundation

public struct RootResults: Decodable {
    let projects: [ResultItem]
}

public struct ResultItem: Codable, Identifiable {
    enum CodingKeys: CodingKey {
        case projectName
        case projectImage
        case description
        case bundleLink
        case learnGuideLink
        case compatibility
    }
    
    public var id = UUID()
    let uniqueID = String()
    let projectName: String
    let projectImage: String
    let description: String
    let bundleLink: String
    let learnGuideLink: String
    let compatibility: [String]
}

extension ResultItem: Equatable {}

public func == (lhs: ResultItem, rhs: ResultItem) -> Bool {
  return lhs.id == rhs.id
}
