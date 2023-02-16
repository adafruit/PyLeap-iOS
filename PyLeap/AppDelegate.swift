//
//  AppDelegate.swift
//  Glider
//
//  Created by Antonio García on 14/5/21.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // UI
        setupAppearances()
        
        return true
    }
    
    private func setupAppearances() {
         // Alerts
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .blue
    }
}
