//
//  OnboardingDataModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 6/30/21.
//

import Foundation

struct OnboardingDataModel {
    var image: String
    var heading: String
    var text: String
}

extension OnboardingDataModel {
 
    static var data: [OnboardingDataModel] = [
    
        OnboardingDataModel(image: "Onboard1", heading: "Welcome", text: "PyLeap is an easy way to get projects from the Adafruit Learn Systems from your mobile device directly to your Adafruit device."),
        OnboardingDataModel(image: "Onboard2", heading: "Round Em'Up!", text: "Gathering Circuit Python project files just got a whole lot easier! We use Bundle Fly to gather Circuit Python files that you'll need for your project."),
        OnboardingDataModel(image: "Onboard3", heading: "Send Em Off!", text: "Effortlessly send over your Circuit Python files to your BLE hardware!")
        
]
    
    
    
}
