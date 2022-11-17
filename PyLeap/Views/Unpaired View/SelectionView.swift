//
//  SelectionView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 10/24/22.
//

import SwiftUI

struct SelectionView: View {
    @EnvironmentObject var rootViewModel: RootViewModel

    var body: some View {
        
        VStack {
            
            HStack {
                Button {
                    rootViewModel.goToMain()
                    
                } label: {
                    Image(systemName: "arrow.backward")
                        .resizable()
                        .frame(width: 25, height: 25, alignment: .center)
                        .offset(y: 15)
                        .foregroundColor(.black)
                }
                .padding()
                                
                Spacer()
            }
            .padding(.top, 15)
            
            Image("pyleapLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.top, 100)
                .padding(.horizontal, 60)
            
            Text("What type of device do you want to connect to?")
                .font(Font.custom("ReadexPro-Regular", size: 36))
                .minimumScaleFactor(0.01)
                .multilineTextAlignment(.center)
                .padding(.top, 100)
                .padding(.horizontal, 30)
            
            Spacer()
            VStack {
                
                Button {
                    rootViewModel.goToWiFiSelection()
                } label: {
                    Text("Wifi")
                        .font(Font.custom("ReadexPro-Regular", size: 25))
                        .foregroundColor(Color.white)
                        .frame(width: 270, height: 50, alignment: .center)
                        .background(Color("pyleap_pink"))
                        .clipShape(Capsule())
                        .padding(5)
                }
                
                
                
                Button {
                    rootViewModel.goTobluetoothPairing()
                } label: {
                    Text("Bluetooth")
                        .font(Font.custom("ReadexPro-Regular", size: 25))
                        .foregroundColor(Color.white)
                        .frame(width: 270, height: 50, alignment: .center)
                        .background(Color("bluetooth_button_color"))
                        .clipShape(Capsule())
                        .padding(5)
                }
                
                
                
                Button {
                    rootViewModel.goToMainSelection()
                } label: {
                    Text("I Don't Know")
                        .font(Font.custom("ReadexPro-Regular", size: 25))
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 60)
                        .minimumScaleFactor(0.1)
                        .frame(width: 270, height: 50, alignment: .center)
                        .background(Color.gray)
                        .clipShape(Capsule())
                        .padding(5)
                }
                
                
                
                Button {
                    rootViewModel.goTobluetoothPairing()
                } label: {
                    Text("Reconnect to a device")
                        .font(Font.custom("ReadexPro-Regular", size: 25))
                        .frame(width: 270, height: 50, alignment: .center)
                        .foregroundColor(.blue)
                }

                
                
            }
            
            Spacer()
        }
        
        
    }
}

struct SelectionView_Previews: PreviewProvider {
    static var previews: some View {
        SelectionView()
    }
}
