//
//  WifiStatusHeaderBarView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 9/8/22.
//

import SwiftUI


struct WifiStatusConnectedView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 8, content: {
        
            Text("")
        
            Button {

            } label: {
                Text("Connect To xxxxxx")
                    .font(Font.custom("ReadexPro-Regular", size: 16))
                Text("xxxx")
                    .font(Font.custom("ReadexPro-Regular", size: 16))
        
            }
        
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
            Button {

            } label: {
                Text("No Device Detected")
                    .font(Font.custom("ReadexPro-Regular", size: 16))

            }
        
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
        
            Text("")
        
            Button {

            } label: {
                Text("Connecting...")
                    .font(Font.custom("ReadexPro-Regular", size: 16))

            }
        
        })
        .padding(.all, 0.0)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 40)
        .background(Color("pyleap_yellow"))
        .foregroundColor(.white)
        
    }
    
}


