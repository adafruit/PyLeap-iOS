//
//  KeyboardUtils.swift
//  Glider
//
//  Created by Antonio García on 26/5/21.
//

import SwiftUI
import Combine

/*
class KeyboardHandler {
    @State private var keyboardIsShown = false
    @State private var keyboardHideMonitor: AnyCancellable? = nil
    @State private var keyboardShownMonitor: AnyCancellable? = nil
    
    func setupKeyboardMonitors() {
         keyboardShownMonitor = NotificationCenter.default
             .publisher(for: UIWindow.keyboardWillShowNotification)
            .sink { _ in if !self.keyboardIsShown { keyboardIsShown = true } }
         
         keyboardHideMonitor = NotificationCenter.default
             .publisher(for: UIWindow.keyboardWillHideNotification)
            .sink { _ in if self.keyboardIsShown { keyboardIsShown = false } }
     }
     
     func dismantleKeyboarMonitors() {
         keyboardHideMonitor?.cancel()
         keyboardShownMonitor?.cancel()
     }

}
*/
