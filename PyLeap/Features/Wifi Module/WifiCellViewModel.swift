//
//  WifiCellViewModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 12/2/22.
//

import Foundation
import SwiftUI

class WifiCellViewModel: ObservableObject {
    
    @Published var isExpanded : Bool = false
    
    init() {
        print("Initialized")
        print("\(#function) @Line: \(#line)")
    }
    
    deinit {
        print("Deinitialized")
        print("\(#function) @Line: \(#line)")
    }
    
    @Published var projectBundle = ""

}
