//
//  PyLeapCatagoryHeader.swift
//  PyLeap
//
//  Created by Trevor Beaton on 2/22/22.
//

import Foundation

enum PyLeapCatagoryHeader: String, CaseIterable {
    
    case circuitPlaygroundBluefruit
    case clue
    
    var name: String {
        self.rawValue.capitalized
    }
}
