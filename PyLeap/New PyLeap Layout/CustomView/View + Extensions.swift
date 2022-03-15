//
//  View + Extensions.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/14/22.
//
import SwiftUI
import Foundation

extension View {
    
    func navigationBarColor(_ backgroundColor: UIColor?) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor))
    }
    
}
