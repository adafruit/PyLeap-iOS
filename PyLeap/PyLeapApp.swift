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
    @Environment(\.scenePhase) var scenePhase
    var body: some Scene {
        WindowGroup {
            RootView()
                // Manage logging persistence
//                .onChange(of: scenePhase) { scenePhase in
//                    switch scenePhase {
//                    case .background:
//                        LogManager.shared.save()
//                    case .inactive:
//                        LogManager.shared.save()
//                    case .active:
//                        LogManager.shared.load()
//                    @unknown default:
//                        break
//                    }
//                }
        }
    }
}
