//
//  PyLeapApp.swift
//  PyLeap
//
//  Created by Trevor Beaton on 6/10/21.
//

import SwiftUI

@main
struct PyLeapApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
