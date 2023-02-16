//
//  Buttons.swift
//  PyLeap
//
//  Created by Trevor Beaton on 4/29/22.
//

import SwiftUI

struct RunItButton: View {
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .frame(width: 270, height: 50, alignment: .center)
                .cornerRadius(25)
                .foregroundColor(Color("pyleap_pink"))
            
            Text("Run it!")
                .font(Font.custom("ReadexPro-Regular", size: 25))
                .foregroundColor(Color.white)
                .frame(height: 50)
            
        }
        
    }
}

struct PairingTutorialButton: View {
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .frame(width: 270, height: 50, alignment: .center)
                .cornerRadius(25)
                .foregroundColor(Color("bluetooth_button_color"))

            Text("Pairing Tutorial")
                .font(Font.custom("ReadexPro-Regular", size: 25))
                .foregroundColor(Color.white)
                .frame(height: 50)
            
        }
        
    }
}

struct LearnGuideButton: View {
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .stroke((Color("pyleap_purple")), lineWidth: 3.5)
                .frame(width: 270, height: 50, alignment: .center)
            
            Text("Learn Guide")
                .font(.custom("ReadexPro-Regular", size: 25))
                .foregroundColor(Color("pyleap_purple"))
        }
    }
}


struct ConnectButton: View {
    var body: some View {
        
        ZStack {
            ZStack {
                Rectangle()
                    .frame(width: 270, height: 50, alignment: .center)
                    .cornerRadius(25)
                    .foregroundColor(Color("adafruit_blue"))
                
                Text("Connect")
                    .font(Font.custom("ReadexPro-Regular", size: 25))
                    .foregroundColor(Color.white)
                    .frame(height: 50)
                
            }
        }

    }
}

struct DownloadingButton: View {
    var body: some View {
        
        ZStack {
            ZStack {
                Rectangle()
                    .frame(width: 270, height: 50, alignment: .center)
                    .cornerRadius(25)
                    .foregroundColor(Color(.gray))
                
                Text("Downloading...")
                    .font(Font.custom("ReadexPro-Regular", size: 25))
                    .foregroundColor(Color.white)
                    .frame(height: 50)
                
            }
        }

    }
}

struct CompleteButton: View {
    var body: some View {
        
        ZStack {
            
            Rectangle()
                .frame(width: 270, height: 50, alignment: .center)
                .cornerRadius(25)
                .foregroundColor(Color("pyleap_green"))
            
            Image("check")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
        }
        

    }
}

struct FailedButton: View {
    var body: some View {
        
        ZStack {
            Rectangle()
                .frame(width: 270, height: 50, alignment: .center)
                .cornerRadius(25)
                .foregroundColor(Color("pyleap_burg"))
            
            Image(systemName: "xmark")
                .resizable()
                .foregroundColor(.white)
                .scaledToFit()
                .frame(width: 30, height: 30)
        }
    }
}

struct Buttons_Previews: PreviewProvider {
    static var previews: some View {
        ConnectButton()
        RunItButton()
        DownloadingButton()
        CompleteButton()
        FailedButton()
    }
}
