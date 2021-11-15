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
    let image: String
    let device: String
    let description: String
    var pythonCode: String
    let downloadLink: String
    var downloadedContents: Bool
    let filePath: URL
    
    init(index:Int,title: String,image: String, device: String, pythonCode: String, description: String, downloadLink: String,downloadedContents: Bool, filePath: URL) {
        self.index = index
        self.title = title
        self.device = device
        self.image = image
        self.pythonCode = pythonCode
        self.description = description
        self.downloadLink = downloadLink
        self.downloadedContents = downloadedContents
        self.filePath = filePath
    }
}

struct ProjectData {
    
    static var projects = [rainbowCPB,blinkCPB,ledGlassesCPB,soundCPB]
    static let cpbProjects = [rainbowCPB, blinkCPB,ledGlassesCPB]
    static let clueProjects = [rainbowClue,blinkClue, helloWorldClue]
    static let ledGlasses = [ledGlassesCPB]
    
    
    
    static var rainbowCPB = Project(
        index:0,
        title: "Glide on over to some Rainbows",
        image: "rainbow-cpb",
        device: "Circuit Playground Bluefruit",
        pythonCode: SamplePythonCode.inRainbows,
        description: """
PyLeap will list the device enabled guides, including this one. Our first stop is using Glider (wireless file transfer) inside of PyLeap to work with BundlFly on the Adafruit Learning System to bundle up and send the files on over! The files include code.py and the libraries.

For this proof-of-concept we're going to toss a rainbow on over to a Circuit Playground Bluefruit Express.
""",
        downloadLink: "https://learn.adafruit.com/pages/22555/elements/3105809/download?type=zip",
        downloadedContents: false,
        filePath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo").appendingPathComponent("CircuitPython 7.x"))
    
 
    
    static var blinkCPB = Project(
        index:1,
        title: "Blink!",
        image: "rainbow-cpb",
        device: "Circuit Playground Bluefruit",
        pythonCode: SamplePythonCode.blinky,
        description: """
A simple example code that flashes the 10 Neopixel LEDs Purple and Pink!
""",
        downloadLink: "https://learn.adafruit.com/pages/22920/elements/3105810/download?type=zip",
        downloadedContents: false,
        filePath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_Blinky_demo"))
    
    static var ledGlassesCPB = Project(
        index:2,
        title: "LED Glasses",
        image: "led-glasses",
        device: "Circuit Playground Bluefruit",
        pythonCode: SamplePythonCode.ledGlasses,
        description: """
Let's send over some rainbows to our Adafruit LED Glasses! This example requires 10 library files to be sent.
""",
        downloadLink: "https://learn.adafruit.com/pages/22957/elements/3105811/download?type=zip",
        downloadedContents: false,
        filePath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("examples"))
    
    static var soundCPB = Project(
        index:3,
        title: "Sound?",
        image: "rainbow-cpb",
        device: "Circuit Playground Bluefruit",
        pythonCode: SamplePythonCode.helloWorld, description: "Sound test",
        downloadLink: "https://learn.adafruit.com/pages/23248/elements/3106070/download?type=zip", downloadedContents: false, filePath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Tone_Piano"))
    
    
    
    static var rainbowClue = Project(
        index:4,
        title: "Glide on over to some Rainbows",
        image: "rainbow-cpb",
        device: "Adafruit CLUE",
        pythonCode: SamplePythonCode.inRainbows,
        description: """
PyLeap will list the device enabled guides, including this one. Our first stop is using Glider (wireless file transfer) inside of PyLeap to work with BundlFly on the Adafruit Learning System to bundle up and send the files on over! The files include code.py and the libraries.

For this proof-of-concept we're going to toss a rainbow on over to the Adafruit CLUE.
""",
        downloadLink: "https://learn.adafruit.com/pages/22555/elements/3098569/download?type=zip", downloadedContents: false, filePath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo"))
    
    static var blinkClue = Project(
        index:5,
        title: "Blink!",
        image: "rainbow-cpb",
        device: "Adafruit CLUE",
        pythonCode: SamplePythonCode.blinky,
        description: "A simple example code that flashes a single Neopixel LED Purple and Pink!",
        downloadLink: "https://learn.adafruit.com/pages/22920/elements/3103057/download?type=zip", downloadedContents: false, filePath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo"))
    
    static var helloWorldClue = Project(
        index:6,
        title: "Hello World(Wipe)",
        image: "rainbow-cpb",
        device: "Adafruit CLUE",
        pythonCode: SamplePythonCode.helloWorld,
        description: "Prints 'Hello World' on the CLUE's TFT display",
        downloadLink: "https://learn.adafruit.com/pages/22555/elements/3098569/download?type=zip", downloadedContents: false, filePath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo"))
    
    
    
    
}
