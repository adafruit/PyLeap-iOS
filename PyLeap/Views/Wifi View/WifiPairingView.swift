//
//  WifiPairingView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 11/8/22.
//

import SwiftUI

struct WifiPairingView: View {
    
    @EnvironmentObject var rootViewModel: RootViewModel
    @State private var showModal = false
    
   
    @State private var showProgress = false

    @State private var userWaitThreshold = false
    @State private var nextText = 0
    @State var showSheetView = false
    @State var showConnectionErrorView = false
    
    var body: some View {
        
        VStack{
            
            HStack {
                
                Button {
                                           
                    self.rootViewModel.goToWiFiSelection()
                } label: {
                    Image(systemName: "arrow.backward")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25, alignment: .center)
                        .foregroundColor(Color("pyleap_gray"))
                }
                
                
                
                
                Spacer()
                Image(systemName: "wifi")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25, alignment: .center)
                    .offset(y: -5)
                

            }
            .padding(.top, 50)
            .padding(.horizontal, 30)
            
            
            
            Image("pyleapLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.top, 50)
                .padding(.horizontal, 60)
            
              
            if nextText == 0 {
                
                
                
                Text("""
        PyLeap’s WiFi mode requires EPS32 devices to have WiFi credentials in an ./env file.
        
        If you’re having trouble connecting, check this documentation:
        
        https://docs.circuitpython.org/en/latest/docs/workflows.html#web
        
        """)
                .font(Font.custom("ReadexPro-Regular", size: 24))
                .minimumScaleFactor(0.01)
                .multilineTextAlignment(.leading)
                .padding(.top, 100)
                .padding(.horizontal, 30)
                .padding(.bottom, 69)
                
                
                Spacer()
                
                Button(action: {
                    rootViewModel.goToWiFiSelection()
                }) {
                    
                    Text("Back")
                        .font(Font.custom("ReadexPro-Regular", size: 25))
                        .foregroundColor(Color.white)
                    
                        .padding()
                        .padding(.horizontal, 60)
                    
                        .frame(height: 50)
                        .background(Color("pyleap_purple"))
                        .clipShape(Capsule())
                    
                }
                Spacer()
                    .frame(height: 60)
                
            }
            
        }
        .edgesIgnoringSafeArea(.all)
        

    }
}

struct WifiPairingView_Previews: PreviewProvider {
    static var previews: some View {
        WifiPairingView()
    }
}
