//
//  WifiView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/9/22.
//

import SwiftUI

struct WifiView: View {
    @StateObject var viewModel = WifiViewModel()
    @State private var ipAddressInput: String = ""
    @State private var foundIPAddress: String = ""
    // My Wifi - 192.168.1.111
    @State var showConfirmation: Bool = true
    @ObservedObject var link = WifiViewModel()
    @State private var presentAlert = false
    
    var body: some View {
        NavigationView {
        
        VStack(alignment: .center, spacing: 12, content: {
          
            TextField("Enter your IP Address:", text: $ipAddressInput)
                .frame(width: 200, height: 50, alignment: .center)
                
                .foregroundColor(.black)
            
            Button("Check Wifi") {
                // Handle acknowledgement.
                if let addr = viewModel.wifiNetworkService.getIPAddress() {
                 //   print(addr)
                    print(foundIPAddress)
                    print(ipAddressInput)

                    foundIPAddress = addr
                } else {
                    print("No WiFi address")
                }
                
                if ipAddressInput != foundIPAddress {
                    //Show alert
                    print("No match")
                    presentAlert = true
                } else {
                    print("Matches")
                    showConfirmation.toggle()
                }
            }
            
            Button("Test curl address") {
                viewModel.getRequest()
            }
            
            Button("Test file creation") {
                viewModel.putRequest()
            }
            
            Button("NWBrowser test") {
                viewModel.test()
            }
            
            ZStack {
                Circle()
                    .foregroundColor(Color("pyleap_green"))
                    .frame(width: 60, height: 60, alignment: .center)
                    .opacity(0.8)
                    
                Image(systemName: "checkmark")
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30, alignment: .center)
                }
            .isHidden(showConfirmation)
            
            List(viewModel.webDirectoryInfo) { post in
               
                NavigationLink(destination: WifiListDetailView(text: post.name)) {
                    HStack(){
                        
                        if post.directory == true {
                            Image(systemName: "folder")
                        } else {
                            Image(systemName: "doc")
                        }
                        
                        Text(post.name)
                        
                        Spacer()
                        
                        if post.file_size > 1000 {
                            
                            Text("\(post.file_size/1000) KB")
                            
                        } else {
                            Text("\(post.file_size) Bytes")
                        }
                        
                    }
                }

                
            }
            .frame(height: UIScreen.main.bounds.height/2)
        })
        
        .navigationBarTitle(Text("PyLeap - Wi-Fi"))
            
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
    }
    }
}

struct WifiView_Previews: PreviewProvider {
    static var previews: some View {
        WifiView()
    }
}
