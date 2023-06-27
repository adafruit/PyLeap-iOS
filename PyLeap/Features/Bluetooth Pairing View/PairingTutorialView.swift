//
//  PairingTutorialView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 5/16/22.
//

import SwiftUI

struct PairingTutorialView: View {
    var body: some View {
        ScrollView {
            HStack {
                Text("Pairing Tutorial")
                    .font(Font.custom("ReadexPro-Regular", size: 32))
                    .padding(.all, 25)
                
                Spacer()
            }
            
            VStack() {
                // 1
                
                
                
                // 2
                VStack(alignment: .leading, spacing: 12) {
                    Text("How To Start Pairing Mode:")
                    
                    HStack {
                        
                        ZStack {
                            Circle()
                                .foregroundColor(Color("pyleap_purple"))
                                .frame(width: 30, height: 30, alignment: .center)
                                .opacity(0.8)
                            
                            Text("1")
                                .foregroundColor(.white)
                        }
                        
                        Text("Press the RESET button on your board.")
                        
                        Spacer()
                    }
                    
                    HStack {
                        
                        ZStack {
                            Circle()
                                .foregroundColor(Color("pyleap_purple"))
                                .frame(width: 30, height: 30, alignment: .center)
                                .opacity(0.8)
                            
                            Text("2")
                                .foregroundColor(.white)
                        }
                        
                        Text("When the LED(s) quickly flash blue, press RESET one more time.")
                        
                        Spacer()
                    }
                    
                }
                .padding(.top, 20)
                
                VStack(spacing: 12) {
                    
                    Text("Entering Pairing Mode:")
                        .multilineTextAlignment(.leading)
                    
                    GifImage("pairingAnimation")
                        .frame(width: 250, height: 250, alignment: .center)
                    
                    Text("""
                         When done correctly, the LED(s) will flash yellow followed by solid blue.
                        """)
                    
                    
                    Text("Completed Pairing Mode:")
                        
                    GifImage("completedPair")
                        .frame(width: 250, height: 250, alignment: .center)
                    
                    Text("Once this occurs, the board will continuously be in discovery mode.")
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    Text("Troubleshoot")
                        .bold()
                    
                    HStack {
                        
                        ZStack {
                            Circle()
                                .foregroundColor(Color("pyleap_purple"))
                                .frame(width: 30, height: 30, alignment: .center)
                                .opacity(0.8)
                            
                            Text("1")
                                .foregroundColor(.white)
                        }
                        
                        Text("Disconnect your Bluetooth device from your computer, and connect it to a battery or USB wall power.")
                        
                        Spacer()
                    }
                    
                    
                    HStack {
                        
                        ZStack {
                            Circle()
                                .foregroundColor(Color("pyleap_purple"))
                                .frame(width: 30, height: 30, alignment: .center)
                                .opacity(0.8)
                            
                            Text("2")
                                .foregroundColor(.white)
                        }
                        
                        Text("""
    Check your device's firmware.
    Make sure you're using the lastest version of CircuitPython.
    """)
                        
                        Spacer()
                    }
                    


                    
                    Link("Check out the PyLeap learn guide to find out how you can update your board to the lastest version of CircuitPython.", destination: URL(string: "https://learn.adafruit.com/pyleap-app/circuitpython")!)
                        .multilineTextAlignment(.leading)
                        
                }
                .padding(.top, 20)
                .minimumScaleFactor(0.01)
                
                
                
            }
            .minimumScaleFactor(0.1)
            .padding(.horizontal, 20)
            .font(Font.custom("ReadexPro-Regular", size: 18))
            .preferredColorScheme(.light)
            
        }
        
    }
}




/*
 Update your hardware to the latest Circuit Python build from your computer.
 
 Once powered, press the small Reset button in the center of the board. When the blue light flashes, press the reset button again.
 
 When done correctly, the LEDs will flash yellow followed by solid blue. Once this occurs, the board will continuously be in discovery mode.
 
 
 PyLeap requires a Circuit Playground Bluefruit board running the most recent build of Circuit Python 7. If you haven't already, you'll need to download the latest version of CircuitPython from the link below.
 
 Make sure youve updated your hardware to the lastest Circuit Python build.  correct firmware, disconnect your device from your computer and power it via LiPoly or AAA battery pack.
 
 
 */

struct PairingTutorialView_Previews: PreviewProvider {
    static var previews: some View {
        PairingTutorialView()
    }
}
