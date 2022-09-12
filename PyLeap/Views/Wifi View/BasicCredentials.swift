//
//  BasicCredentials.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/22/22.
//

import Foundation

public struct BasicCredentials: Hashable, Codable {
    public let username: String
    public let password: String

    public init(username: String, password: String) {
        self.username = ""
        self.password = "passw0rd"
    }
}

