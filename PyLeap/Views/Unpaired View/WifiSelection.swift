//
//  WifiSelection.swift
//  PyLeap
//
//  Created by Trevor Beaton on 11/7/22.
//

import SwiftUI

struct WifiSelection: View {
    @ObservedObject var wifiServiceViewModel = WifiServiceManager()
    @EnvironmentObject var rootViewModel: RootViewModel
    @StateObject var viewModel = WifiViewModel()

    let userDefaults = UserDefaults.standard
    private let kPrefix = Bundle.main.bundleIdentifier!

    func toggleViewModelIP() {
        viewModel.isInvalidIP.toggle()
    }
    
    func storeResolvedAddress(service: ResolvedService) {
        print("Storing resolved address")
        userDefaults.set(service.ipAddress, forKey: kPrefix+".storeResolvedAddress.ipAddress" )
        userDefaults.set(service.hostName, forKey: kPrefix+".storeResolvedAddress.hostName" )
        userDefaults.set(service.device, forKey: kPrefix+".storeResolvedAddress.device" )

        print("Stored UserDefaults")
        
        print(userDefaults.object(forKey: kPrefix+".storeResolvedAddress.ipAddress"))
        print(userDefaults.object(forKey: kPrefix+".storeResolvedAddress.hostName"))
        print(userDefaults.object(forKey: kPrefix+".storeResolvedAddress.device"))
    }

    
    func showConfirmationPrompt(service: ResolvedService, hostName: String) {
        comfirmationAlertMessage(title: "Would you like to connect to \(hostName)?", exitTitle: "Cancel", primaryTitle: "Connect") {
            storeResolvedAddress(service: service)
            viewModel.printStoredInfo()
            rootViewModel.goToWifiView()
        } cancel: {
            
        }
    }
    
    func showValidationPrompt() {
        alertTF(title: "Enter Device IP Address",
                message: "PyLeap will use this IP address to search for Adafruit devices on your local network",
                hintText: "IP Address...",
                primaryTitle: "Done",
                secondaryTitle: "Cancel") { text in
               viewModel.checkServices(ip: text)
           
       } secondaryAction: {
           print("Cancel")
       }
   }
    
    func showAlertMessage() {
        alertMessage(title: "IP address Not Found", exitTitle: "Ok") {
            showValidationPrompt()
        }
    }
    
    var body: some View {
        
        VStack {
            
            HStack {
                Button {
                    rootViewModel.goToSelection()
                    
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
           // .border(.indigo, width: 2)
            
            Image("pyleapLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.top, 100)
                .padding(.horizontal, 60)
            
            Text("How do you want to connect to your WiFi enabled device?")
                .font(Font.custom("ReadexPro-Regular", size: 36))
                .minimumScaleFactor(0.01)
                .multilineTextAlignment(.center)
                .padding(.top, 100)
                .padding(.horizontal, 30)
            
            Spacer()
            
            VStack {
                
                Button {
                    rootViewModel.goToWiFiServiceSelection()
                } label: {
                    Text("Scan for a Device")
                        .font(Font.custom("ReadexPro-Regular", size: 25))
                        .foregroundColor(Color.white)
                        .frame(width: 270, height: 50, alignment: .center)
                        .background(Color("pyleap_pink"))
                        .clipShape(Capsule())
                        .padding(5)
                }
                
                
                
                Button {
                    showValidationPrompt()
                } label: {
                    Text("Manually Connect")
                        .font(Font.custom("ReadexPro-Regular", size: 25))
                        .foregroundColor(Color.white)
                    
                        .frame(width: 270, height: 50, alignment: .center)
                        .background(Color("pyleap_purple"))
                        .clipShape(Capsule())
                        .padding(5)
                }
                
                Link("Learn More", destination: URL(string: "https://learn.adafruit.com/pyleap-app")!)
                    .font(Font.custom("ReadexPro-Regular", size: 25))
                    .foregroundColor(Color.white)
                   .minimumScaleFactor(0.1)
                    .frame(width: 270, height: 50, alignment: .center)
                    .background(Color.gray)
                    .clipShape(Capsule())
                    .padding(5)
                
                
                
                
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
        
        .onChange(of: viewModel.ipInputValidation, perform: { newValue in
            if newValue {
                rootViewModel.goToWifiView()
                viewModel.ipInputValidation.toggle()
            }
            
        })
        
        
        .onChange(of: viewModel.isInvalidIP, perform: { newValue in
            print("viewModel.isInvalidIP .onChange")
            if newValue {
                showAlertMessage()
                toggleViewModelIP()
            }
            
        })
        
    }
}

struct WifiSelection_Previews: PreviewProvider {
    static var previews: some View {
        WifiSelection()
    }
}
