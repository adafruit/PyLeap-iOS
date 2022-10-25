//
//  WifiServiceSelectionView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 10/24/22.
//

import SwiftUI

struct WifiServiceSelectionView: View {
    
    @ObservedObject var wifiServiceViewModel = WifiServiceManager()
    @EnvironmentObject var rootViewModel: RootViewModel
    @StateObject var viewModel = WifiViewModel()
    
    
    let userDefaults = UserDefaults.standard
    private let kPrefix = Bundle.main.bundleIdentifier!
    
    func storeResolvedAddress(service: ResolvedService) {
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
    
    var body: some View {
        
        VStack {
            HStack {
                
                Button {
                    rootViewModel.goToSelection()
                    
                } label: {
                    Image(systemName: "arrow.backward")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                        .offset(y: 15)
                        .foregroundColor(.black)
                }
                .padding()
                
                Spacer()
                
                Button {
                    wifiServiceViewModel.findService()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30, alignment: .center)
                    
                        .foregroundColor(.black)
                }
                .padding()
                
            }
            .padding(.top, 0)
            
            Text("Scanning...")
                .font(.largeTitle)
            
            Text("SELECT PERIPHERAL")
                .font(.subheadline)
            
            Button {
                showValidationPrompt()
            } label: {
                Text("Enter IP address")
                    .font(Font.custom("ReadexPro-Regular", size: 16))
                    .foregroundColor(.white)
                    .background(.indigo)
                    .padding(5)
            }
            
            List($wifiServiceViewModel.resolvedServices) { $service in
                WifiRowView(wifiService: service)
                    .onTapGesture {
                       // print(service.hostName)
                        // Save Cred to User Defaults
                        
                        showConfirmationPrompt(service: service, hostName: service.hostName)
                        
                    }
            }
            .listStyle(PlainListStyle())
        }
        
        .padding(.top, 90)
    }
}
struct WifiServiceSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        WifiServiceSelectionView()
    }
}
