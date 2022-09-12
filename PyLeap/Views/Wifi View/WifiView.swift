//
//  WifiView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/9/22.
//

import SwiftUI
import Combine

struct WifiView: View {
    
    let userDefaults = UserDefaults.standard
    
    
    func showIPAddressAlert() {
       
       alertTF(title: "Enter Device IP Address", message: "PyLeap will use this IP address to search for Adafruit devices on your local network", hintText: "IP Address ...", primaryTitle: "Done", secondaryTitle: "Cancel") { text in
           
         //  setIP(ipAddress: text)
           
           
           // Validate IP Address from Services array
           
       } secondaryAction: {
           print("Cancel")
       }
   }
    
    
    func showValidationPrompt() {
       
       alertTF(title: "Enter Device IP Address", message: "PyLeap will use this IP address to search for Adafruit devices on your local network", hintText: "IP Address ...", primaryTitle: "Done", secondaryTitle: "Cancel") { text in
           setIP(ipAddress: text)
           
       } secondaryAction: {
           print("Cancel")
       }
       
   }

    
    func checkIP() {
        
        if viewModel.checkIfIPAddressIsNil() == true {
            print("true")
            print(userDefaults.object(forKey: "ipAddress"))
        } else {
            showIPAddressAlert()
            print(userDefaults.object(forKey: "ipAddress"))
            
        }
        
    }

    func setIP(ipAddress: String) {
        userDefaults.set(ipAddress, forKey: "ipAddress" )
        
    }
    
    @StateObject var viewModel = WifiViewModel()
    
  //  @StateObject var wifiService = WifiServiceManager()
    
    @State private var downloadState = DownloadState.idle
    @State private var scrollViewID = UUID()
    @State private var inConnectedInWifiView = true
    @State private var boardBootInfo = "esp32-s2"
    
    @State private var ipAddressInput: String = ""
    @State private var foundIPAddress: String = ""
    
    @State private var savedIPAddress = false
    
    // My Wifi - 192.168.1.111
    @State var showConfirmation: Bool = true
    @State private var presentAlert = false
    
    var body: some View {

        
        VStack(spacing: 0) {
            WifiHeaderView()
           

            Group{
                switch viewModel.wifiServiceManager.connectionStatus {
                    
                    case .connected:
                        WifiStatusConnectedView()
                    case .noConnection:
                        WifiStatusNoConnectionView()
                    case .connecting:
                        WifiStatusConnectingView()
                    }
                      
            }
            
            
            HStack(alignment: .center, spacing: 12, content: {
            
                Button {
                    viewModel.checkIfIPAddressIsNil()
                } label: {
                    Text("Check IP")
                        .font(Font.custom("ReadexPro-Regular", size: 16))
                }
                
                Button {
                    viewModel.clearKnownIPAddress()
                } label: {
                    Text("clearKnownIPAddress")
                        .font(Font.custom("ReadexPro-Regular", size: 16))
                }
            
                Button {
                    showIPAddressAlert()
                } label: {
                    Text("Show Alert")
                        .font(Font.custom("ReadexPro-Regular", size: 16))
                }
                
                Button {
                    setIP(ipAddress: "")
                } label: {
                    Text("Set IP")
                        .font(Font.custom("ReadexPro-Regular", size: 16))
                }
                
            })
            .padding(.all, 0.0)
            .frame(maxWidth: .infinity)
            .frame(maxHeight: 40)
            .background(Color("pyleap_green"))
            .foregroundColor(.white)
            

            
            ScrollView(.vertical, showsIndicators: true) {
                
                ScrollViewReader { scroll in
                    
                    SubHeaderView()
                      //  .spotlight(enabled: spotlight.counter == 1, title: "1")
                    Button("Real Test") {
                        alertTF(title: "Login test", message: "Message", hintText: "Hint text", primaryTitle: "primaryTitle", secondaryTitle: "secondaryTitle") { text in
                            print(text)
                        } secondaryAction: {
                            print("Cancel")
                        }

                    }
                    //{$0.state == .connected }
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
            
            
         
            
//            List(viewModel.webDirectoryInfo) { post in
//
//                NavigationLink(destination: WifiListDetailView(text: post.name)) {
//                    HStack(){
//
//                        if post.directory == true {
//                            Image(systemName: "folder")
//                        } else {
//                            Image(systemName: "doc")
//                        }
//
//                        Text(post.name)
//
//                        Spacer()
//
//                        if post.file_size > 1000 {
//
//                            Text("\(post.file_size/1000) KB")
//
//                        } else {
//                            Text("\(post.file_size) Bytes")
//                        }
//
//                    }
//                }
//
//
//            }
          //  .frame(height: UIScreen.main.bounds.height)
        }
        
      //  .navigationBarTitle(Text("PyLeap - Wi-Fi"))
            
        .alert("\"\(ipAddressInput)\" was not found", isPresented: $presentAlert) {
                    Button("OK") {
                        // Handle acknowledgement.
                        print("OK")
                        presentAlert = false
                        
                    }
                } message: {
                    Text("""
                         The IP address you've entered was not found.
                         """)
                    .multilineTextAlignment(.leading)
                }
    
        .onAppear(){
           // viewModel.internetMonitoring()
            
           checkIP()
           
        }
    }
       
}
    

struct WifiView_Previews: PreviewProvider {
    static var previews: some View {
        WifiView()
    }
}
