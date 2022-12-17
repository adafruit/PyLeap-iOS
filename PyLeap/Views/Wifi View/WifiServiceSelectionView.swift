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
    
    @State private var scrollViewID = UUID()
    
    // For Blinka spinning animation
    @State private var isAnimating = false
    var foreverAnimation: Animation {
        Animation.linear(duration: 2.0)
            .repeatForever(autoreverses: false)
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
    
    func toggleViewModelIP() {
        viewModel.isInvalidIP.toggle()
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
                .padding(.leading, 30)
                
                Spacer()
            }
            .padding(.top, 15)
            
            
            Image("pyleapLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .minimumScaleFactor(0.1)
                .padding(.top, 50)
                .padding(.horizontal, 60)

            
            
            if wifiServiceViewModel.isSearching && wifiServiceViewModel.resolvedServices.isEmpty  {
                Text("WiFi Connect")
                    .font(Font.custom("ReadexPro-Regular", size: 36))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .padding()
                
                Spacer()
                
                
                BlinkaAnimationView(height: 150, width: 145)
                    .padding(.bottom, 20)
                    .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0.0))
                    .onAppear() {
                        Animation.linear(duration: 1.0)
                            .repeatForever(autoreverses: false)
                        isAnimating = true
                    }
                
                
                
                VStack {
                   
                    Text("""
    Scanning for PyLeap
    compatible devices...
    """)
                    .font(Font.custom("ReadexPro-Regular", size: 24))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.1)
                    .lineLimit(2)
                    
                    Button {
                        rootViewModel.goToWifiPairingTutorial()
                    } label: {
                        Text("Pairing Tutorial")
                            .font(Font.custom("ReadexPro-Regular", size: 25))
                            .foregroundColor(Color.white)
                           .minimumScaleFactor(0.1)
                            .frame(width: 270, height: 50, alignment: .center)
                            .background(Color("pyleap_pink"))
                            .clipShape(Capsule())
                            .padding(5)
                    }
                    
                }
                
                .padding(.horizontal, 30)
                .padding(.bottom, 60)
   
            }
             
            else  {
                Spacer()

                VStack {
                    
                    if !wifiServiceViewModel.resolvedServices.isEmpty {
                        Text("WiFi Devices Found")
                            .font(Font.custom("ReadexPro-Regular", size: 24))
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                        
                    } else {
                        Text("No WiFi Devices Found")
                            .font(Font.custom("ReadexPro-Regular", size: 24))
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                        
                    }

                    
                    Button {
                    } label: {
                        HStack {
                            
                            Image(systemName: "arrow.clockwise")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25, alignment: .center)
                                .foregroundColor(.white)
                            
                            Button  {
                                wifiServiceViewModel.findService()
                            } label: {
                                Text("Rescan")
                            }
                            
                        }
                        
                        .font(Font.custom("ReadexPro-Regular", size: 25))
                        .foregroundColor(Color.white)
                        .frame(width: 146, height: 50, alignment: .center)
                        .background(Color("pyleap_purple"))
                        .clipShape(Capsule())
                        
                    }
                    
                    if wifiServiceViewModel.isSearching {
                        ProgressView()
                    }
                    
                }
                .padding(.vertical, 40)

                    ScrollView(.vertical, showsIndicators: true) {
                        ScrollViewReader { scroll in
                            ForEach(wifiServiceViewModel.resolvedServices) { service in
                                WifiServiceCellView(resolvedService: service, onViewGeometryChanged: {
                                    withAnimation {
                                        scroll.scrollTo(service.id)
                                    }
                                })
                                .onTapGesture {
                                    // Save Cred to User Defaults
                                    showConfirmationPrompt(service: service, hostName: service.hostName)
                                }
                            }
                        }
                        .id(self.scrollViewID)
                    }
                    .foregroundColor(.black)
            }

            if wifiServiceViewModel.resolvedServices.isEmpty && !wifiServiceViewModel.isSearching {
                
                VStack {
                   
                    Text("""
    Unable to find any WiFi
    compatible Adafruit devices
    on your network
    """)
                    .font(Font.custom("ReadexPro-Regular", size: 24))
                    
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.1)
                    .lineLimit(3)
                   
                    
                    Button {
                        rootViewModel.goToWifiPairingTutorial()
                    } label: {
                        Text("Pairing Tutorial")
                            .font(Font.custom("ReadexPro-Regular", size: 25))
                            .foregroundColor(Color.white)
                            .minimumScaleFactor(0.1)
                            .frame(width: 270, height: 50, alignment: .center)
                            .background(Color("pyleap_pink"))
                            .clipShape(Capsule())
                            .padding(5)
                    }
                    
                }
                .padding(.horizontal, 30)
               
            }
           
           
        }
        .padding(.bottom, 60)

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
struct WifiServiceSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        WifiServiceSelectionView()
    }
}
