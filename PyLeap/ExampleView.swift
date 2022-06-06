//
//  ExampleView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 4/16/22.
//

import SwiftUI

struct ExampleView: View {
    @Binding var shouldShowOnboarding: Bool
    
        var body: some View {
       
        TabView {
//            PageView(title: "Welcome", subtitle: "PyLeap allows you to send complete projects from the Adafruit Learn System to your PyLeap compatible  device.", imageName: "Onboard2", showDismissButton: false, shouldShowOnboarding: $shouldShowOnboarding)
//
//            PageView(title: "Connect", subtitle: "Pair to your PyLeap enabled device.", imageName: "Onboard2", showDismissButton: false, shouldShowOnboarding: $shouldShowOnboarding)
//
//            PageView(title: "Choose your Adventure!", subtitle: "Choose a project you would like to send over to your PyLeap compatible device.", imageName: "slide3", showDismissButton: false, shouldShowOnboarding: $shouldShowOnboarding)
//
            PageView(title: "Send projects directly from the Adafruit Learning System to your Bluefruit Compatible Device...", subtitle: "...without opening a code editor or connecting to a computer.", imageName: "slide4", showDismissButton: true, shouldShowOnboarding: $shouldShowOnboarding)
        }
        .tabViewStyle(PageTabViewStyle())
    }
}

struct PageView: View {
    let title: String
    let subtitle: String
    let imageName: String
    let showDismissButton: Bool
    @Binding var shouldShowOnboarding: Bool
    
    
    var body: some View {
        VStack {
            Image("pyleapLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 60)
            
            Text(title)
                .font(Font.custom( "ReadexPro-Regular", size: 24))
                .foregroundColor(Color("pyleap_gray"))
                .padding(.horizontal, 30)
                .minimumScaleFactor(0.1)
            
            Image("cpb")
                .resizable()
                .frame(width: 300, height: 300, alignment: .center)
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 95)
            
            Text(subtitle)
                .font(Font.custom( "ReadexPro-Regular", size: 24))
                .foregroundColor(Color("pyleap_gray"))
                .padding(.horizontal, 30)
                .minimumScaleFactor(0.1)
            if showDismissButton {
                Button {
                    shouldShowOnboarding.toggle()
                } label: {
                    ZStack {
                        Rectangle()
                            .frame(width: 270, height: 50, alignment: .center)
                            .cornerRadius(25)
                            .foregroundColor(Color("pyleap_pink"))
                        
                        Text("Get Started")
                            .minimumScaleFactor(0.1)
                            .font(Font.custom("ReadexPro-Regular", size: 25))
                            .foregroundColor(Color.white)
                            .frame(height: 50)
                        
                    }
                }
            }
        }
    }
}

struct ExampleView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleView(shouldShowOnboarding: .constant(true))
    }
}
