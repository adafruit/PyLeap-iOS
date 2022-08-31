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
    @State private var presentAlert = false
    
    var body: some View {
        NavigationView {
        
        VStack(alignment: .center, spacing: 12, content: {
          
            TextField("Enter your IP Address:", text: $ipAddressInput)
                .frame(width: 200, height: 50, alignment: .center)
                
                .foregroundColor(.black)
            
            Button("Make Directory") {
              //  viewModel.putDirectory()
            }
            
            Button("GET Request") {
                viewModel.getRequest()
            }
            
            Button("PUT Request") {
                viewModel.putRequest()
            }
            
            Button("DELETE Request") { viewModel.deleteRequest() }
            
            Button("Single IP Addr.") { print(viewModel.wifiService.getIPAddress()) }
            
            Button("IP Addr. List") { print(viewModel.wifiService.getIFAddresses()) }
           
            Button("Get Project") {
                viewModel.projectValidation(nameOf: "ESP32-S2 NeoPixel LED")
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
    }
        .onAppear(){
           // viewModel.internetMonitoring()
            
        }
    }
       
}
    

struct WifiView_Previews: PreviewProvider {
    static var previews: some View {
        WifiView()
    }
}
