//
//  CPBRainbows.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/11/21.
//

import Foundation

struct Project: Identifiable, Equatable {

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

struct CPBProjects {
    
    static var projects = [cpbInRainbowsProj,cpbBlinkProj,cpbLedGlassesProj,cpbWavPlaybackProj,cpbLightMeterProj, cpbTouchNeoPixelProj, cpbControlledNeoPixelProj,cpbPianoNeoPixelProj,cpbSoundMeterProj,cpbPlayMP3Proj]
    static let cpbProjects = [cpbInRainbowsProj, cpbBlinkProj,cpbLedGlassesProj]
    static let clueProjects = [rainbowClue,blinkClue, helloWorldClue]
    static let ledGlasses = [cpbLedGlassesProj]
    
    
    
    static var cpbInRainbowsProj = Project(
        index:0,
        title: "NeoPixel Rainbows",
        image: "cpb",
        device: "Circuit Playground Bluefruit",
        pythonCode: SamplePythonCode.inRainbows,
        description: """
For this project we're going to toss a rainbow on over to a Circuit Playground Bluefruit.
""",
        downloadLink: "https://learn.adafruit.com/pages/22555/elements/3105809/download?type=zip",
        downloadedContents: false,
        filePath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo").appendingPathComponent("CircuitPython 7.x"))
    
 
    
    static var cpbBlinkProj = Project(
        index:1,
        title: "Blink!",
        image: "cpb",
        device: "Circuit Playground Bluefruit",
        pythonCode: SamplePythonCode.blinky,
        description: """
A simple project code flashes 10 Neopixel LEDs purple and pink.
""",
        downloadLink: "https://learn.adafruit.com/pages/22920/elements/3105810/download?type=zip",
        downloadedContents: false,
        filePath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_CPB_NeoPixel_Blinky_demo").appendingPathComponent("CircuitPython 7.x"))
    
    static var cpbLedGlassesProj = Project(
        index:2,
        title: "EyeLights LED Glasses",
        image: "cpb",
        device: "Circuit Playground Bluefruit",
        pythonCode: SamplePythonCode.ledGlasses,
        description: """
Let's send over some rainbows to our EyeLights LED Glasses!

There's also six mounting holes for attaching to a glasses frame of your choosing - we recommend getting some 'fashion frames' from the mall or a street vendor, they're all the style and will provide a great mechanical support.
""",
        downloadLink: "https://learn.adafruit.com/pages/22957/elements/3105811/download?type=zip",
        downloadedContents: false,
        filePath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_CPB_EyeLights_LED_Glasses_RainbowSwirl").appendingPathComponent("CircuitPython 7.x"))
    
    static var cpbWavPlaybackProj = Project(
        index:3,
        title: "WAV Playback",
        image: "cpb",
        device: "Circuit Playground Bluefruit",
        pythonCode: SamplePythonCode.helloWorld, description: """
This project plays a different WAV for each button pressed. Be aware, the speaker is small, so you will not get high quality WAV playback using the built-in speaker.
""",
        downloadLink: "https://learn.adafruit.com/pages/23250/elements/3106074/download?type=zip", downloadedContents: false, filePath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_WAV").appendingPathComponent("CircuitPython 7.x"))
    
    
    static var cpbLightMeterProj = Project(
        index:4,
        title: "Light Meter",
        image: "cpb",
        device: "Circuit Playground Bluefruit",
        pythonCode: SamplePythonCode.helloWorld, description: """
This project uses the ten LEDs to indicate light level from the light sensor.
""",
        downloadLink: "https://learn.adafruit.com/pages/23270/elements/3106247/download?type=zip", downloadedContents: false, filePath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Light_Meter").appendingPathComponent("CircuitPython 7.x"))
    
    static var cpbTouchNeoPixelProj = Project(
        index:5,
        title: "Touch NeoPixel Rainbow",
        image: "cpb",
        device: "Circuit Playground Bluefruit",
        pythonCode: SamplePythonCode.helloWorld, description: """
This project uses the touch pads to light up the LEDs in rainbow colors.
""",
        downloadLink: "https://learn.adafruit.com/pages/23272/elements/3106255/download?type=zip", downloadedContents: false, filePath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Touch_NeoPixel_Rainbow").appendingPathComponent("CircuitPython 7.x"))
    

    static var cpbControlledNeoPixelProj = Project(
        index:6,
        title: "Button Controlled NeoPixels",
        image: "cpb",
        device: "Circuit Playground Bluefruit",
        pythonCode: SamplePythonCode.helloWorld, description: """
This project lights up half of the NeoPixel LEDs for each button when pressed.

""",
        downloadLink: "https://learn.adafruit.com/pages/23269/elements/3106245/download?type=zip", downloadedContents: false, filePath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Button_Half_NeoPixel_Control").appendingPathComponent("CircuitPython 7.x"))
    
    
    
    static var cpbPianoNeoPixelProj = Project(
        index:7,
        title: "Touch Tone Piano",
        image: "cpb",
        device: "Circuit Playground Bluefruit",
        pythonCode: SamplePythonCode.helloWorld, description: """
This project plays a different tone and lights up the NeoPixels a different color for each touch pad touched.
""",
        downloadLink: "https://learn.adafruit.com/pages/23248/elements/3106070/download?type=zip", downloadedContents: false, filePath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Tone_Piano").appendingPathComponent("CircuitPython 7.x"))
    
    
    
    
    
    
    static var cpbSoundMeterProj = Project(
        index:8,
        title: "Sound Meter",
        image: "cpb",
        device: "Circuit Playground Bluefruit",
        pythonCode: SamplePythonCode.helloWorld, description: """
This project uses the ten LEDs to indicate sound level from the sensor.
""",
        downloadLink: "https://learn.adafruit.com/pages/23271/elements/3106249/download?type=zip", downloadedContents: false, filePath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Sound_Meter").appendingPathComponent("CircuitPython 7.x"))
    
    
    
    
    static var cpbPlayMP3Proj = Project(
        index:9,
        title: "MP3 Playback",
        image: "cpb",
        device: "Circuit Playground Bluefruit",
        pythonCode: SamplePythonCode.helloWorld, description: """
This project plays a different MP3 for each button pressed.
""",
        downloadLink: "https://learn.adafruit.com/pages/23249/elements/3106072/download?type=zip", downloadedContents: false, filePath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_MP3").appendingPathComponent("CircuitPython 7.x"))
    
    
    
    
    
    static var rainbowClue = Project(
        index:0,
        title: "NeoPixel Rainbows",
        image: "clue",
        device: "Adafruit CLUE",
        pythonCode: SamplePythonCode.inRainbows,
        description: """
PyLeap will list the device enabled guides, including this one. Our first stop is using Glider (wireless file transfer) inside of PyLeap to work with BundlFly on the Adafruit Learning System to bundle up and send the files on over! The files include code.py and the libraries.

For this proof-of-concept we're going to toss a rainbow on over to the Adafruit CLUE.
""",
        downloadLink: "https://learn.adafruit.com/pages/22555/elements/3105809/download?type=zip", downloadedContents: false, filePath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo"))
    
    static var blinkClue = Project(
        index:1,
        title: "Blink!",
        image: "clue",
        device: "Adafruit CLUE",
        pythonCode: SamplePythonCode.blinky,
        description: "A simple example code that flashes a single Neopixel LED Purple and Pink!",
        downloadLink: "https://learn.adafruit.com/pages/22920/elements/3105810/download?type=zip", downloadedContents: false, filePath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_CPB_NeoPixel_Blinky_demo").appendingPathComponent("CircuitPython 7.x"))
    
    static var helloWorldClue = Project(
        index:2,
        title: "Hello World(Wipe)",
        image: "clue",
        device: "Adafruit CLUE",
        pythonCode: SamplePythonCode.helloWorld,
        description: "Prints 'Hello World' on the CLUE's TFT display",
        downloadLink: "https://learn.adafruit.com/pages/22555/elements/3098569/download?type=zip", downloadedContents: false, filePath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo"))
    
    
    
    
}
