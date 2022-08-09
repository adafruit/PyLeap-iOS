//
//  WrappedStruct.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/1/22.
//

import Foundation
import SwiftUI

class WrappedStruct<T>: ObservableObject {
    @Published var item: T
    
    init(withItem item:T) {
        self.item = item
    }
}
