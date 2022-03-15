//
//  Model.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/14/22.
//

import Foundation

struct RootResults: Decodable {
    let projects: [ResultItem]
}

struct ResultItem: Codable, Identifiable {
    enum CodingKeys: CodingKey {

        case project_name
        case project_image
        case description
        case bundle_link
        case learn_guide_link
        case compatibility
    }
    
    var id = UUID()

    let project_name: String
    let project_image: String
    let description: String
    let bundle_link: String
    let learn_guide_link: String
    let compatibility: [String]
}
