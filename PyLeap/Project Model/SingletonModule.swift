//
//  ProjectState.swift
//  PyLeap
//
//  Created by Trevor Beaton on 10/12/21.
//

import Foundation

class ProjectState: ObservableObject {
    // Singleton
    static let shared = ProjectState()
    
    // Published
    @Published var projectSingleton: Project? = nil
    
}


class ConnectionState: ObservableObject {
    static let shared = ProjectState()
    
    @Published var connectionSingleton: Bool? = false
}
