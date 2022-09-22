//
//  WifiStatusHeaderBarView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 9/8/22.
//

import SwiftUI
import Foundation

struct WifiStatusConnectedView: View {
    
    let userDefaults = UserDefaults.standard
    private let kPrefix = Bundle.main.bundleIdentifier!

    @Binding var hostName: String

    var body: some View {
        HStack(alignment: .center, spacing: 8, content: {
 
            Text("Connected To \(hostName)")
                .font(Font.custom("ReadexPro-Regular", size: 16))
        })
        .padding(.all, 0.0)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 40)
        .background(Color("pyleap_green"))
        .foregroundColor(.white)
    }
}

struct WifiStatusNoConnectionView: View {
    var body: some View {

        HStack(alignment: .center, spacing: 8, content: {
            Text("No Device Detected")
                .font(Font.custom("ReadexPro-Regular", size: 16))
        
        })
        .padding(.all, 0.0)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 40)
        .background(Color("pyleap_burg"))
        .foregroundColor(.white)
        
    }
}

struct WifiStatusConnectingView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 8, content: {
            Text("Searching for Adafruit Devices...")
                .font(Font.custom("ReadexPro-Regular", size: 16))
        })
        .padding(.all, 0.0)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 40)
        .background(Color("pyleap_yellow"))
        .foregroundColor(.white)
        
    }
    
}

struct NetworkConnectionBanner: View {
    @State var spin = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 8, content: {
            Text("Searching local network...")
                .font(Font.custom("ReadexPro-Regular", size: 16))
            
       //     ProgressView()
                //.resizable()
            //    .frame(width: 40, height: 40, alignment: .center)
           //     .rotationEffect(.degrees(spin ? 360: 0))
//                .animation(Animation.linear(duration: 0.8, curve:.linear).repeatForever(autoreverses: false))
         //   .animation(Animation.linear.repeatForever(autoreverses: false))
//                .onAppear(){
//                    spin = true
//                }
                
        })
        .padding(.all, 0.0)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 40)
        .background(Color("pyleap_yellow"))
        .foregroundColor(.white)
        
    }
    
}
