//
//  WifiView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/9/22.
//


import SwiftUI
import Combine

struct WifiView: View {

    @StateObject var viewModel = WifiViewModel()
    private let kPrefix = Bundle.main.bundleIdentifier!
   
    // User Defaults
    let userDefaults = UserDefaults.standard
    
    @EnvironmentObject var rootViewModel: RootViewModel
    @ObservedObject var networkModel = NetworkService()
    
    @State private var downloadState = DownloadState.idle
    @State private var scrollViewID = UUID()
    @State private var inConnectedInWifiView = true
    @State private var boardBootInfo = "esp32-s2"
    @State var hostName = ""
    
    
    
    @EnvironmentObject var test : ExpandedState
    
    
    
    @State var falseTog = false
    
    @State var trueTog = true
    
    @State private var showPopover: Bool = false
    
    func toggleViewModelIP() {
        viewModel.isInvalidIP.toggle()
    }
    
    func fetch() {
        //  viewModel.networkModel.fetch()
    }
    
    func scanNetworkWifi() {
        viewModel.wifiServiceManager.findService()
    }
    
    func printArray(array: [Any]) {
        
        for i in array {
            print("\(i)")
        }
    }
    
    func checkForStoredIPAddress() {
        if userDefaults.object(forKey: kPrefix+".storeResolvedAddress.hostName") == nil {
            print("storeResolvedAddress - not stored")
            
        } else {
            hostName = userDefaults.object(forKey: kPrefix+".storeResolvedAddress.hostName") as! String
            viewModel.ipAddressStored = true
            print("storeResolvedAddress - is stored")
            viewModel.connectionStatus = .connected
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
        
        VStack(spacing: 0) {
            WifiHeaderView()
            
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
            
            
            ScrollView(.vertical, showsIndicators: false) {
                
                ScrollViewReader { scroll in
                    
                    SubHeaderView()
                    
                    
                    let check = networkModel.pdemos.filter {
                        $0.compatibility.contains(boardBootInfo)
                    }
                    
                    ForEach(check) { demo in
                        
                        if demo.bundleLink == test.currentCell {
                            WifiCell(result: demo,isExpanded: trueTog, isConnected: $inConnectedInWifiView, bootOne: $boardBootInfo, stateBinder: $downloadState, onViewGeometryChanged: {
                                
                                
                            })
                            .onAppear(){
                                
                                withAnimation {
                                    scroll.scrollTo(demo.id)
                                }
                                
                            }
                          
                            
                            
                        } else {
                            
                            WifiCell(result: demo, isExpanded: falseTog, isConnected: $inConnectedInWifiView, bootOne: $boardBootInfo, stateBinder: $downloadState, onViewGeometryChanged: {
                                withAnimation {
                                    //    scroll.scrollTo(demo.id)
                                }
                            })
                            
                            
                        }
                    }
                    
                }
                
                .id(self.scrollViewID)
            }
            .foregroundColor(.black)
            .environmentObject(test)
        }
        
        
        
        .onChange(of: viewModel.connectionStatus, perform: { newValue in
            if newValue == .connected {
                hostName = userDefaults.object(forKey: kPrefix+".storeResolvedAddress.hostName") as! String
            }
        })
        
        
        .onChange(of: viewModel.wifiServiceManager.resolvedServices, perform: { newValue in
            print("Credential Check!")
            print(newValue)
            
            if newValue.contains(where: { result in
                result.hostName == userDefaults.object(forKey: kPrefix+".storeResolvedAddress.hostName") as! String
            }) {
                print("Matched")
                
            } else {
                print("Un-Matched")
            }
            
        })
        
        .onChange(of: viewModel.isInvalidIP, perform: { newValue in
            print("viewModel.isInvalidIP .onChange")
            if newValue {
                showAlertMessage()
                toggleViewModelIP()
            }
            
        })
        
        
        .onAppear(){
            checkForStoredIPAddress()
            viewModel.printStoredInfo()
            viewModel.read()
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
    public static let testNotificationName = Notification.Name(kPrefix+".testNotificationName")
    public static let didUpdateState = Notification.Name(kPrefix+".test")
    public static let invalidIPNotif = Notification.Name(kPrefix+".invalidIPNotif")
    public static let invalidCustomNetworkRequest = Notification.Name(kPrefix+".invalidCustomNetworkRequest")
    public static let didCollectCustomProject = Notification.Name(kPrefix+".didCollectCustomProject")
    public static let didEncounterZipError = Notification.Name(kPrefix+".didEncounterZipError")
    public static let didCompleteZip = Notification.Name(kPrefix+".didCompleteZip")
    public static let wifiDownloadComplete = Notification.Name(kPrefix+".wifiDownloadComplete")
    public static let didCompleteTransfer = Notification.Name(kPrefix+".didCompleteTransfer")
    public static let didEncounterTransferError = Notification.Name(kPrefix+".didEncounterTransferError")
    public static let downloadErrorDidOccur = Notification.Name(kPrefix+".downloadErrorDidOccur")
    public static let usbInUseErrorNotification = Notification.Name(kPrefix+".usbInUseErrorNotification")
    
}
