//
//  RootViewController.swift
//  PyLeap
//
//  Created by Trevor Beaton for Adafruit Industries on 4/5/21.
//

import UIKit

class RootViewController: UINavigationController {
    
    // Make sure the status bar is light in the app.
    // The default is set to black, as this one is used in the Launch Screen.
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navigationBar.standardAppearance = navBarAppearance
            navigationBar.scrollEdgeAppearance = navBarAppearance
        } else {
            // Fallback on earlier versions
        }
    }
}
