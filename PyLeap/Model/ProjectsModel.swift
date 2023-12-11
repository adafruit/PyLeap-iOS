//
//  ProjectsModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/24/22.
//


import Foundation


struct RootResults: Codable {
    let formatVersion: Int
    let fileVersion: Int
    let projects: [PyProject]
}

struct PyProject: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    let projectName: String
    let projectImage: String
    let description: String
    let bundleLink: String
    let learnGuideLink: String
    let compatibility: [String]
    let bluetoothCompatible: Bool
    let wifiCompatible: Bool

    enum CodingKeys: CodingKey {
        case projectName
        case projectImage
        case description
        case bundleLink
        case learnGuideLink
        case compatibility
        case bluetoothCompatible
        case wifiCompatible
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.projectName = try container.decode(String.self, forKey: .projectName)
        self.projectImage = try container.decode(String.self, forKey: .projectImage)
        self.description = try container.decode(String.self, forKey: .description)
        self.bundleLink = try container.decode(String.self, forKey: .bundleLink)
        self.learnGuideLink = try container.decode(String.self, forKey: .learnGuideLink)
        self.compatibility = try container.decode([String].self, forKey: .compatibility)
        self.bluetoothCompatible = try container.decode(Bool.self, forKey: .bluetoothCompatible)
        self.wifiCompatible = try container.decode(Bool.self, forKey: .wifiCompatible)
    }
}


