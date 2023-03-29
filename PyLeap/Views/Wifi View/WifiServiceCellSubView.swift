//
//  WifiServiceCellSubView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/29/23.
//

import SwiftUI
import Foundation

struct WifiServiceCellSubView: View {
    let resolvedService: ResolvedService
    
    @EnvironmentObject var rootViewModel: RootViewModel

    let userDefaults = UserDefaults.standard
    private let kPrefix = Bundle.main.bundleIdentifier!
    
    
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
            rootViewModel.goToWifiView()
        } cancel: {
            
        }
    }
    
    
    var body: some View {
       
        VStack {
            
            
                
            HStack {
                VStack {

                    Text("Device ID: \(resolvedService.hostName)")
                        .font(Font.custom("ReadexPro-Regular", size: 18))
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.1)
                    
                    Text("Device IP: \(resolvedService.ipAddress)")
                        .font(Font.custom("ReadexPro-Regular", size: 18))
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.1)
                }
                Spacer()
            }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 30)
                
                    HStack (
                        alignment: .center,
                        spacing: 0
                    ) {
                        Spacer()
                        Button {
                            showConfirmationPrompt(service: resolvedService, hostName: resolvedService.hostName)

                        } label: {
                            Text("Connect")
                                .font(Font.custom("ReadexPro-Regular", size: 25))
                                .foregroundColor(Color.white)
                                .frame(width: 270, height: 50, alignment: .center)
                                .background(Color("pyleap_pink"))
                                .clipShape(Capsule())
                                .padding(.bottom, 30)
                        }
                        Spacer()
                    
                    
                
            }
            
            
                   }
    }
}

//struct WifiServiceCellSubView_Previews: PreviewProvider {
//    static var previews: some View {
//        WifiServiceCellSubView(resolvedService: .con)
//    }
//}
