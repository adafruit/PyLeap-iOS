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
        print("Set Appearance")
        // Navigation bar title
      //  UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    //    UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Navigation bar background
      //  UINavigationBar.appearance().barTintColor = .clear
     //   UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        // List background
//        UITableView.appearance().backgroundColor = UIColor.clear
//        UITableView.appearance().separatorStyle = .none
//        UITableViewCell.appearance().backgroundColor = .clear
//
        // Alerts
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .blue
    }
}
