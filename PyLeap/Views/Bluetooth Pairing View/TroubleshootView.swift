//
//  TroubleshootView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 5/16/22.
//

import SwiftUI

struct TroubleshootView: View {
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Circle()
                    .frame(width: 200, height: 200, alignment: .center)
                    .foregroundColor(Color("pyleap_purple"))
                    
                Image("warning_icon")
                    .resizable()
                    .frame(width: 75, height: 75, alignment: .center)
            }
            
            Spacer()
            
            VStack (alignment: .leading, spacing: 12) {
                Text("Hmm...")
                    .bold()
                
                Text("""
    We’re having trouble connecting to your device.
    """)
                
                .minimumScaleFactor(0.8)
                
                HStack {
                    ZStack {
                        
                        Circle()
                            .foregroundColor(Color("pyleap_purple"))
                            .frame(width: 30, height: 30, alignment: .center)
                            
                        Text("1")
                            .foregroundColor(.white)
                    }
                    
                    Text("Go to your iOS device's Bluetooth settings.")
                        .minimumScaleFactor(0.8)
            }
            
                HStack {
                    ZStack {
                        
                        Circle()
                            .foregroundColor(Color("pyleap_purple"))
                            .frame(width: 30, height: 30, alignment: .center)
                            
                        Text("2")
                            .foregroundColor(.white)
                    }
                    
                    Text(#"Tap the information icon for your CIRCUITPY device and select "Forget This Device"."#)
                        
                        .minimumScaleFactor(0.8)
            }
                
                HStack {
                    ZStack {
                        
                        Circle()
                            .foregroundColor(Color("pyleap_purple"))
                            .frame(width: 30, height: 30, alignment: .center)
                            
                        Text("3")
                            .foregroundColor(.white)
                    }
                    
                    Text("Return to PyLeap to continue.")
                        
                        .minimumScaleFactor(0.8)
            }

            }
            
            
            
            Button {
                
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            } label: {
                
                ZStack {
                    Rectangle()
                        .frame(width: 270, height: 50, alignment: .center)
                        .cornerRadius(25)
                        .foregroundColor(Color("pyleap_pink"))
                    
                    Text("Go To Settings")
                        .font(Font.custom("ReadexPro-Regular", size: 25))
                        .foregroundColor(Color.white)
                        .frame(height: 50)
                    
                }
            }
            .padding(.top, 30)
            Spacer()
                .frame(height: 40)
            
        }
        .font(Font.custom("ReadexPro-Regular", size: 16))
        .padding(.horizontal, 30)
        .preferredColorScheme(.light)
    }
        
}


struct TroubleshootView_Previews: PreviewProvider {
    static var previews: some View {
        TroubleshootView()
    }
}
