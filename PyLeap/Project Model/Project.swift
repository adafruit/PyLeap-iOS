//
//  CPBRainbows.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/11/21.
//

import Foundation

struct Project: Identifiable {
    let id = UUID()
    let title: String
    let device: String
    var pythonCode: String
    let downloadLink: String
    
    init(title: String, device: String, pythonCode: String, downloadLink: String) {
        self.title = title
        self.device = device
        self.pythonCode = pythonCode
        self.downloadLink = downloadLink
    }
    
}

struct ProjectData {
    
    static let projects = [inRainbowsSampleProject, blinky, helloWorld]
    static let cpbProjects = [inRainbowsSampleProject]
    static let clueProjects = [blinky]
    
    
    static var inRainbowsSampleProject = Project(
        title: "Glide on over to some Rainbows",
        device: "Circuit Playground Bluefruit",
        pythonCode: SamplePythonCode.inRainbows, downloadLink: "https://learn.adafruit.com/pages/22555/elements/3098569/download?type=zip" )
    
    static var blinky = Project(
        title: "Blinky",
        device: "CPB",
        pythonCode: SamplePythonCode.blinky, downloadLink: "https://learn.adafruit.com/pages/22920/elements/3103057/download?type=zip")
    
    static var helloWorld = Project(
        title: "Hello World(Wipe)",
        device: "CPB",
        pythonCode: SamplePythonCode.helloWorld, downloadLink: "https://learn.adafruit.com/pages/22555/elements/3098569/download?type=zip")
    
}
