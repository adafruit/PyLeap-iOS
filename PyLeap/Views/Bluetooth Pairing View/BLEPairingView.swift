//
//  BLEPairingView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 4/4/22.
//

import SwiftUI

struct BLEPairingView: View {
    let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    @State private var isAnimating = false
    @State private var showProgress = false
    var foreverAnimation: Animation {
        Animation.linear(duration: 2.0)
            .repeatForever(autoreverses: false)
    }
    @State private var userWaitThreshold = false
    @State private var nextText = false
    
    var body: some View {
       
        VStack{
           
            HStack {
                
                Spacer()
                Image("bluetooth")
                    .resizable()
                    
                    .aspectRatio(contentMode: .fit)
                    
                    .frame(width: 30, height: 30, alignment: .center)
                    .padding(35)
                    .onReceive(timer) { _ in
                        userWaitThreshold = true
                        timer.upstream.connect().cancel()
                    }
            }
            
            
            
            Image("pyleapLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)

                .padding(.horizontal, 60)
                .fixedSize(horizontal: false, vertical: true)

           // Spacer()
            
            if userWaitThreshold == false {
                
                
                Text("Searching for your Bluefruit device...")
                    .font(Font.custom("ReadexPro-Regular", size: 36))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    //.padding(.top, 100)
                    .padding(.horizontal, 20)
                
                BlinkaAnimationView()
                    .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0.0))
                
                    .onAppear(){
                        Animation.linear(duration: 1.0)
                            .repeatForever(autoreverses: false)
                        isAnimating = true
                    }
                
                
            } else {
                
                
                if nextText == false {
                    
                    Text("""
        No device found. Let's fix this. First, disconnect your device from USB and connect to a battery.

        """)
                        .font(Font.custom("ReadexPro-Regular", size: 10))
                        .padding(.horizontal, 30)
                        
                        
                        
                    Spacer()
                    
                    Button(action: {
nextText = true
                    }) {
                        
                        Text("Next Step")
                            .font(Font.custom("ReadexPro-Regular", size: 25))
                            .foregroundColor(Color.white)
                            .padding(.horizontal, 60)
                            .frame(height: 50)
                            .background(Color("pyleap_pink"))
                            .clipShape(Capsule())
                    }
                    
                    
                } else {
                    
                    Text("""
                  Press the RESET button on your board, the press it one more time.
                  
                  The LEDs on your board should be flashing blue.
                  """)
                                  .font(Font.custom("ReadexPro-Regular", size: 36))
                                  .multilineTextAlignment(.center)
                                  .padding(.top, 108.7)
                                 .padding(.horizontal, 30)
                    
                    
                    Button(action: {
nextText = false
                    }) {
                        
                        Text("Back")
                            .font(Font.custom("ReadexPro-Regular", size: 25))
                            .foregroundColor(Color.white)
                            .padding(.horizontal, 60)
                            .frame(height: 50)
                            .background(Color("pyleap_pink"))
                            .clipShape(Capsule())
                    }
                    
                    
                }
                

            }
            
            
//            Text("Searching for your Bluefruit device...")
//                .font(Font.custom("ReadexPro-Regular", size: 36))
//                .padding(.top, 108.7)
//                .padding(.horizontal, 20)
            

            
            Spacer()
        }
        
        .edgesIgnoringSafeArea(.all)
        .preferredColorScheme(.light)
        
        
        
    }
}

struct BLEPairingView_Previews: PreviewProvider {
    static var previews: some View {
        BLEPairingView()
            .previewDevice("iPhone SE (2nd generation)")
    }
}
