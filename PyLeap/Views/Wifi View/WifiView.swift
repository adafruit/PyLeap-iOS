//
//  WifiView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/9/22.
//

// My IP Address - 192.168.1.111

import SwiftUI
import Combine

struct WifiView: View {

    @StateObject var viewModel = WifiViewModel()
    private let kPrefix = Bundle.main.bundleIdentifier!
    @StateObject var wifiviewModel = WifiServiceManager()
    // User Defaults
    let userDefaults = UserDefaults.standard
    
    @State private var downloadState = DownloadState.idle
    @State private var scrollViewID = UUID()
    @State private var inConnectedInWifiView = true
    @State private var boardBootInfo = "esp32-s2"
    @State var hostName = ""
    
    func showValidationPrompt() {
        alertTF(title: "Enter Device IP Address", message: "PyLeap will use this IP address to search for Adafruit devices on your local network", hintText: "IP Address ...", primaryTitle: "Done", secondaryTitle: "Cancel") { text in
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
    
    func initialIPStoreCheck() {
        if userDefaults.object(forKey: kPrefix+".storedIP") == nil {
            print("No IP address found.")
            showValidationPrompt()
        } else {
            viewModel.connectionStatus = .connected
            print("Stored: \(String(describing: userDefaults.object(forKey: kPrefix+".storedIP"))), @: \(kPrefix+".storedIP")")
            
        }
    }
    
    var body: some View {

        VStack(spacing: 0) {
            WifiHeaderView()
           
            if wifiviewModel.isSearching {
                NetworkConnectionBanner()
            } else {
                
            }
            
            
            Group{
                switch viewModel.connectionStatus {
                    case .connected:
                    WifiStatusConnectedView(hostName: $hostName)
                    case .noConnection:
                        WifiStatusNoConnectionView()
                    case .connecting:
                        WifiStatusConnectingView()
                    }
            }

            if !viewModel.ipAddressStored {
                HStack(alignment: .center, content: {
                
                    Button {
                        showValidationPrompt()
                       
                    } label: {
                        Text("Enter IP address")
                            .font(Font.custom("ReadexPro-Regular", size: 16))
                    }
                    
                    Button {
                        wifiviewModel.findService()
                    } label: {
                        Text("-Scan Network-")
                    }

                    
                })
                .padding(.all, 0.0)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 40)
                .background(Color.clear)
                .foregroundColor(.black)
            } else {
                
            }
            
           
            ScrollView(.vertical, showsIndicators: true) {
                
                ScrollViewReader { scroll in
                    
                    SubHeaderView()

                    let check =  NetworkService.shared.pdemos.filter {
                        $0.compatibility.contains(boardBootInfo)
                    }
                    
                    ForEach(check) { demo in
                        
                        WifiCell(result: demo, isConnected: $inConnectedInWifiView, bootOne: $boardBootInfo, stateBinder: $downloadState, onViewGeometryChanged: {
                            withAnimation {
                                scroll.scrollTo(demo.id)
                            }
                        })
                       
                        
                    }
                    
                }
                
                .id(self.scrollViewID)
            }
            .foregroundColor(.black)
        }
        
        .onChange(of: viewModel.connectionStatus, perform: { newValue in
            if newValue == .connected {
                hostName = userDefaults.object(forKey: kPrefix+".storeResolvedAddress.hostName") as! String
            }
        })
        
        .onChange(of: viewModel.isInvalidIP, perform: { newValue in
            print("viewModel.isInvalidIP .onChange")
            if newValue {
                showAlertMessage()
                viewModel.isInvalidIP.toggle()
            }
                
        })
        
        .onAppear(){
            
          //  viewModel.checkStoredIP()
            initialIPStoreCheck()
            
            if userDefaults.object(forKey: kPrefix+".storeResolvedAddress.hostName") == nil {
                print("Nothing stored.")
            } else {
                hostName = userDefaults.object(forKey: kPrefix+".storeResolvedAddress.hostName") as! String
            }
            
        }
    }
       
}
    

struct WifiView_Previews: PreviewProvider {
    static var previews: some View {
        WifiView()
    }
}

extension Notification.Name {
    private static let kPrefix = Bundle.main.bundleIdentifier!
    public static let didUpdateState = Notification.Name(kPrefix+".test")
    public static let invalidIPNotif = Notification.Name(kPrefix+".invalidIPNotif")
}
