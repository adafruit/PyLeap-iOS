//
//  CPBRainbows.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/11/21.
//

import Foundation

struct Project: Identifiable {

    let id = UUID()
    let index: Int
    var title: String
    let device: String
    var pythonCode: String
    let downloadLink: String
    
    init(index:Int,title: String, device: String, pythonCode: String, downloadLink: String) {
        self.index = index
        self.title = title
        self.device = device
        self.pythonCode = pythonCode
        self.downloadLink = downloadLink
    }
}

struct ProjectData {
    
    static var projects = [inRainbowsSampleProject,blinkCPB,ledGlassesCPB, helloWorld,rainbowClue, blinkClue]
    static let cpbProjects = [inRainbowsSampleProject]
    static let clueProjects = [blinkCPB]
    
    static var inRainbowsSampleProject = Project(
        index:0,
        title: "Glide on over to some Rainbows",
        device: "CPB",
        pythonCode: SamplePythonCode.inRainbows,
        downloadLink: "https://learn.adafruit.com/pages/22555/elements/3098569/download?type=zip")
    
    static var blinkCPB = Project(
        index:1,
        title: "Blink!",
        device: "CPB",
        pythonCode: SamplePythonCode.blinky,
        downloadLink: "https://learn.adafruit.com/pages/22920/elements/3103057/download?type=zip")
    
    static var ledGlassesCPB = Project(
        index:2,
        title: "LED Glasses",
        device: "CPB",
        pythonCode: SamplePythonCode.ledGlasses,
        downloadLink: "https://learn.adafruit.com/pages/22957/elements/3103276/download?type=zip")
    
    static var helloWorld = Project(
        index:3,
        title: "Hello World(Wipe)",
        device: "CPB",
        pythonCode: SamplePythonCode.helloWorld,
        downloadLink: "https://learn.adafruit.com/pages/22555/elements/3098569/download?type=zip")
    
    
    
    static var rainbowClue = Project(
        index:4,
        title: "Glide on over to some Rainbows",
        device: "Adafruit CLUE",
        pythonCode: SamplePythonCode.inRainbows,
        downloadLink: "https://learn.adafruit.com/pages/22555/elements/3098569/download?type=zip")
    
    static var blinkClue = Project(
        index:5,
        title: "Blink!",
        device: "Adafruit CLUE",
        pythonCode: SamplePythonCode.blinky,
        downloadLink: "https://learn.adafruit.com/pages/22920/elements/3103057/download?type=zip")
    
    static var helloWorldClue = Project(
        index:6,
        title: "Hello World(Wipe)",
        device: "Adafruit Clue",
        pythonCode: SamplePythonCode.helloWorld,
        downloadLink: "https://learn.adafruit.com/pages/22555/elements/3098569/download?type=zip")
    
    
    
    
}
