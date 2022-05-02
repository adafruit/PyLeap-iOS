//
//  CPBView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 5/2/22.
//

import SwiftUI

struct CPBView: View {
    
    
    @State private var ledColor = Color.gray
    @State private var ledColorSeqOne = 4
    @State private var ledColorSeqTwo = 8
    
    @State private var blinkDuration = 1.2
    @State private var blinkSpeed = 5
    
    @State var timeRemaining = 10
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    @State private var enabled = false
    // Yellow (Animation.linear(duration: 1.2).repeatForever().speed(5))
    // Blue   (Animation.linear(duration: 0.5).repeatForever().speed(1))
    var body: some View {
        
        
        ZStack {
            Image("cpb")
                .resizable()
                .frame(width: 250, height: 250)
            // Left
            Group {
                Circle()
                    .frame(width: 15, height: 15, alignment: .center)
                    .position(CGPoint(x: 85, y: 199))
                    .foregroundColor(ledColor)
                    .opacity(1)
                
                Circle()
                    .frame(width: 15, height: 15, alignment: .center)
                    .position(CGPoint(x: 52, y: 168))
                    .foregroundColor(ledColor)
                    .opacity(1)
                
                Circle()
                    .frame(width: 15, height: 15, alignment: .center)
                    .position(CGPoint(x: 41, y: 125))
                    .foregroundColor(ledColor)
                    .opacity(1)
                
                Circle()
                    .frame(width: 15, height: 15, alignment: .center)
                    .position(CGPoint(x: 52, y: 84))
                    .foregroundColor(ledColor)
                    .opacity(1)
                
                Circle()
                    .frame(width: 15, height: 15, alignment: .center)
                    .position(CGPoint(x: 82, y: 52))
                    .foregroundColor(ledColor)
                    .opacity(1)
                
            }
            
            // Right
            
            Group {
                
                Circle()
                    .frame(width: 15, height: 15, alignment: .center)
                    .position(CGPoint(x: 167, y: 198))
                    .foregroundColor(ledColor)
                    .opacity(1)
                
                Circle()
                    .frame(width: 15, height: 15, alignment: .center)
                    .position(CGPoint(x: 198, y: 165))
                    .foregroundColor(ledColor)
                    .opacity(1)
                
                Circle()
                    .frame(width: 15, height: 15, alignment: .center)
                    .position(CGPoint(x: 208, y: 126))
                    .foregroundColor(ledColor)
                    .opacity(1)
                
                Circle()
                    .frame(width: 15, height: 15, alignment: .center)
                    .position(CGPoint(x: 198, y: 85))
                    .foregroundColor(ledColor)
                    .opacity(1)
                
                Circle()
                    .frame(width: 15, height: 15, alignment: .center)
                    .position(CGPoint(x: 166, y: 53))
                    .foregroundColor(enabled ? .yellow : .gray)
                    .animation(.default, value: enabled)
                    .opacity(1)
                Text("\(timeRemaining)")
            }
        }
        
        .frame(width: 250, height: 250)
        .border(.yellow)
//        .animation(Animation.linear(duration: 1).repeatForever().speed(5))
//        .task {
//            ledColor = .yellow
//        }
        
        
        .onReceive(timer) { _ in
            print("Hey")
            enabled.toggle()
            
//            if timeRemaining == 0 {
//                timeRemaining = 10
//                print("Reset")
//            }
//
//            if timeRemaining > 5 {
//                timeRemaining -= 1
//                ledColor = .yellow
//                print("This")
//            } else {
//                print("That")
//                timeRemaining -= 1
//                ledColor = .cyan
//            }
            
        }
    }
}


struct CPBView_Previews: PreviewProvider {
    static var previews: some View {
        CPBView()
    }
}
