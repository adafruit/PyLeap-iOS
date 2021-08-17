//
//  NumbersOnly.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/3/21.
//
import SwiftUI

class NumbersOnly: ObservableObject {
    @Published var value = "" {
        didSet {
            let filtered = value.filter { $0.isNumber }
            
            if value != filtered {
                value = filtered
            }
        }
    }
}
