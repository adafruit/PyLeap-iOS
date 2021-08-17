//
//  SamplePythonCode.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/16/21.
//

import Foundation


struct SamplePythonCode {
    
    static var inRainbows = """
        import time
        import board
        import neopixel

        pixels = neopixel.NeoPixel(board.NEOPIXEL, 10, brightness=0.2, auto_write=False)
        rainbow_cycle_demo = 1

        def wheel(pos):
                    if pos < 0 or pos > 255:
                        return (0, 0, 0)
                    if pos < 85:
                        return (255 - pos * 3, pos * 3, 0)
                    if pos < 170:
                        pos -= 85
                        return (0, 255 - pos * 3, pos * 3)
                    pos -= 170
                    return (pos * 3, 0, 255 - pos * 3)

        def rainbow_cycle(wait):
                    for j in range(255):
                        for i in range(10):
                            rc_index = (i * 256 // 10) + j * 5
                            pixels[i] = wheel(rc_index & 255)
                        pixels.show()
                        time.sleep(wait)

        while True:
                    if rainbow_cycle_demo:
                        rainbow_cycle(0.05)

        """
    
    static var blinky: String = """
        import board
        import neopixel
        import time

        pixels = neopixel.NeoPixel(board.NEOPIXEL, 10, brightness=0.2, auto_write=False)
        PURPLE = (10, 0, 25)
        PINK = (25, 0, 10)
        OFF = (0,0,0)

        while True:
            pixels.fill(PURPLE)
            pixels.show()
            time.sleep(0.5)
            pixels.fill(OFF)
            pixels.show()
            time.sleep(0.5)
            pixels.fill(PINK)
            pixels.show()
            time.sleep(0.5)
            pixels.fill(OFF)
            pixels.show()
            time.sleep(0.5)
        
        """
    
    static var helloWorld: String = """
        print("Hello World!")
        """
    
}
