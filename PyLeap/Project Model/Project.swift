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
    let description: String
    var pythonCode: String
    let downloadLink: String
    
    init(index:Int,title: String, device: String, pythonCode: String, description: String, downloadLink: String) {
        self.index = index
        self.title = title
        self.device = device
        self.pythonCode = pythonCode
        self.description = description
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
        device: "Circuit Playground Bluefruit",
        pythonCode: SamplePythonCode.inRainbows,
        description: """
PyLeap will list the device enabled guides, including this one. Our first stop is using Glider (wireless file transfer) inside of PyLeap to work with BundlFly on the Adafruit Learning System to bundle up and send the files on over! The files include code.py and the libraries.

For this proof-of-concept we're going to toss a rainbow on over to a Circuit Playground Bluefruit Express.
""",
        downloadLink: "https://learn.adafruit.com/pages/22555/elements/3098569/download?type=zip")
    
    static var blinkCPB = Project(
        index:1,
        title: "Blink!",
        device: "Circuit Playground Bluefruit",
        pythonCode: SamplePythonCode.blinky,
        description: """
A simple example code that flashes the 10 Neopixel LEDs Purple and Pink!
""",
        downloadLink: "https://learn.adafruit.com/pages/22920/elements/3103057/download?type=zip")
    
    static var ledGlassesCPB = Project(
        index:2,
        title: "LED Glasses",
        device: "Circuit Playground Bluefruit",
        pythonCode: SamplePythonCode.ledGlasses,
        description: """
Let's send over some rainbows to our Adafruit LED Glasses! This example requires 10 library files to be sent.
""",
        downloadLink: "https://learn.adafruit.com/pages/22957/elements/3103276/download?type=zip")
    
    static var helloWorld = Project(
        index:3,
        title: "Hello World(Wipe)",
        device: "Circuit Playground Bluefruit",
        pythonCode: SamplePythonCode.helloWorld, description: "Wipe",
        downloadLink: "https://learn.adafruit.com/pages/22555/elements/3098569/download?type=zip")
    
    
    
    static var rainbowClue = Project(
        index:4,
        title: "Glide on over to some Rainbows",
        device: "Adafruit CLUE",
        pythonCode: SamplePythonCode.inRainbows,
        description: "Coming Soon!",
        downloadLink: "https://learn.adafruit.com/pages/22555/elements/3098569/download?type=zip")
    
    static var blinkClue = Project(
        index:5,
        title: "Blink!",
        device: "Adafruit CLUE",
        pythonCode: SamplePythonCode.blinky,
        description: "Coming Soon!",
        downloadLink: "https://learn.adafruit.com/pages/22920/elements/3103057/download?type=zip")
    
    static var helloWorldClue = Project(
        index:6,
        title: "Hello World(Wipe)",
        device: "Adafruit Clue",
        pythonCode: SamplePythonCode.helloWorld,
        description: "Coming Soon!",
        downloadLink: "https://learn.adafruit.com/pages/22555/elements/3098569/download?type=zip")
    
    
    
    
}
