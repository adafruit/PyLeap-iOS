//
//  DefaultBackground.swift
//  Glider
//
//  Created by Antonio García on 14/5/21.
//

import SwiftUI

// MARK: - Background
struct DefaultBackgroundView: View {
    
    var body: some View {
        Color("background_default")
            .ignoresSafeArea()
    }
}

// MARK: - Background as modifier
private struct DefaultBackgroundViewModifier: ViewModifier {
    var hidesKeyboardOnTap: Bool
    
    func body(content: Content) -> some View {
        ZStack() {
            DefaultBackgroundView()
                .if(hidesKeyboardOnTap) {
                    $0.onTapGesture {
                        self.hideKeyboard()
                    }
                }
            content
        }
    }
}

extension View {
    func defaultBackground(hidesKeyboardOnTap: Bool = false) -> some View {
        self.modifier(DefaultBackgroundViewModifier(hidesKeyboardOnTap: hidesKeyboardOnTap))
    }
}
