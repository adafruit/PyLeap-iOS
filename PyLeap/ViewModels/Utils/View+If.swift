//
//  View+If.swift
// 
//
//  Created by Antonio García on 5/5/21.
//

import SwiftUI

// from: https://blog.kaltoun.cz/conditionally-applying-view-modifiers-in-swiftui/
// from: https://www.avanderlee.com/swiftui/conditional-view-modifier/#:~:text=Conditional%20View%20Modifier%20creation%20in,different%20configurations%20to%20your%20views.
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        }
        else {
            self
        }
    }
    
    
    @ViewBuilder
    func ifelse<Content: View>(_ condition: Bool, ifContent: (Self) -> Content, elseContent: (Self) -> Content) -> some View {
        if condition {
            ifContent(self)
        }
        else {
            elseContent(self)
        }
    }
    
    
}
