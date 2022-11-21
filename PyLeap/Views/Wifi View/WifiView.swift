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
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = WifiViewModel()
    private let kPrefix = Bundle.main.bundleIdentifier!
    // User Defaults
    let userDefaults = UserDefaults.standard

    @EnvironmentObject var rootViewModel: RootViewModel
    @ObservedObject var networkModel = NetworkService()

    @ObservedObject var wifiServiceViewModel = WifiServiceManager()
    
    @State private var downloadState = DownloadState.idle
    @State private var scrollViewID = UUID()
    @State private var inConnectedInWifiView = true
    @State private var boardBootInfo = "esp32-s2"
    @State var hostName = ""
    
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

//            if viewModel.ipAddressStored {
//                HStack(alignment: .center, content: {
//                
//                    Button {
//                        showValidationPrompt()
//                    } label: {
//                        Text("Enter IP address")
//                            .font(Font.custom("ReadexPro-Regular", size: 16))
//                            .foregroundColor(.white)
//                            .background(.indigo)
//                            .padding(5)
//                    }
//                    
//                    Button {
//                        viewModel.wifiTransferService.getRequestForFileCheck(read: "lib/") { success in
//                            printArray(array: success)
//                        }
//                    } label: {
//                        Text("List all files")
//                            .foregroundColor(.white)
//                            .background(.indigo)
//                            .padding(5)
//                    }
//                    
//                    Button {
//                        scanNetworkWifi()
//                    } label: {
//                        Text("Scan Network")
//                            .foregroundColor(.white)
//                            .background(.indigo)
//                            .padding(5)
//                    }
//                    
//                    Button {
//                        rootViewModel.goTobluetoothPairing()
//                    } label: {
//                        Text("BLE Mode")
//                            .foregroundColor(.white)
//                            .background(.indigo)
//                            .padding(5)
//                    }
//
//                })
//                .padding(.all, 0.0)
//                .frame(maxWidth: .infinity)
//                .frame(maxHeight: 40)
//                .background(Color.clear)
//                .foregroundColor(.black)
//            }
            
           

           
            ScrollView(.vertical, showsIndicators: true) {
                
                ScrollViewReader { scroll in
                    
                    SubHeaderView()

                    let check = networkModel.pdemos.filter {
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
        .onDisappear() {
            print("On Disappear")
        
            dismiss()
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
