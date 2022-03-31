//
//  DemoSubCellView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/23/22.
//

import SwiftUI
import FileTransferClient

class GlobalString: ObservableObject {
  @Published var projectString = ""
}

struct DemoSubview: View {
    
    @EnvironmentObject var globalString : GlobalString
   
    
    let title: String
    let image: String
    let description: String
    let learnGuideLink: URLRequest
    let downloadLink: String
    let compatibility: [String]
    var setUUID: String
    
    
    @StateObject var downloadModel = DownloadViewModel()
    
    
    @Binding var isConnected : Bool
    @State private var showWebViewPopover: Bool = false
    
    
    
    var body: some View {
        VStack {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .cornerRadius(14)
                .padding(.leading, 30)
                .padding(.trailing, 30)
            
            //           GifImage("test")
            //               .frame(width: 300, height: 300, alignment: .center)
            //               .scaledToFit()
            //               .cornerRadius(35)
            
            VStack(alignment: .leading, spacing: 10) {
                Text(description)
                    .font(Font.custom("ReadexPro-Regular", size: 18))
                    .fontWeight(.regular)
                    .multilineTextAlignment(.leading)
                Text("Compatible with:")
                    .font(Font.custom("ReadexPro-SemiBold", size: 18))
                
                ForEach(compatibility, id: \.self) { string in
                    if string == "circuitplayground_bluefruit" {
                        
                        HStack {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 25, height: 22, alignment: .center)
                                .foregroundColor(.green)
                            Text("Circuit Playground Bluefruit")
                                .font(Font.custom("ReadexPro-Regular", size: 18))
                        }
                    }
                    if string  == "clue_nrf52840_express" {
                        
                        HStack {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 25, height: 22, alignment: .center)
                                .foregroundColor(.green)
                            Text("Adafruit CLUE")
                                .font(Font.custom("ReadexPro-Regular", size: 18))
                            Spacer()
                        }
                    }
                }
            }
            .padding(.top, 10)
            .padding(.horizontal, 20)
            
            Button(action: {
                showWebViewPopover = true

            }) {
                Text("Learn Guide")
                    .font(.custom("ReadexPro-Regular", size: 25))
                    .foregroundColor(Color("pyleap_purple"))
                    .padding(.leading, 60)
                    .padding(.trailing, 60)
                    .frame(height: 50)
                    .popover(
                        isPresented: self.$showWebViewPopover,
                        arrowEdge: .bottom
                    ) {
                        VStack{
                            WebView(URLRequest(url: learnGuideLink.url!))
                        }
                        .padding(0)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke((Color("pyleap_purple")), lineWidth: 3.5))
            }
            
           
            
            if isConnected {
                Button(action: {
                    print("Download Button Pressed!")
                    downloadModel.startDownload(urlString: downloadLink, projectTitle: title)
                    
                }) {
                    
                    Text("Download")
                        .font(Font.custom("ReadexPro-Regular", size: 25))
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 60)
                        .frame(height: 50)
                        .background(Color("pyleap_pink"))
                        .clipShape(Capsule())
                }
                
                Button(action: {
                   print("Project Selected: \(title) - DemoSubView")
                 // viewModel.filesDownloaded(projectName: title)
                    globalString.projectString = title
                    print("\(globalString.projectString) - DemoSubView")
                }) {
                    
                    Text("Transfer")
                        .font(Font.custom("ReadexPro-Regular", size: 25))
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 60)
                        .frame(height: 50)
                        .background(Color("pyleap_pink"))
                        .clipShape(Capsule())
                }
                
                
            } else {
                
                NavigationLink(destination: RootView(), label: {
                    Text("Connect")
                        .font(Font.custom("ReadexPro-Regular", size: 25))
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 60)
                        .frame(height: 50)
                        .background(Color("adafruit_blue"))
                        .clipShape(Capsule())
                    
                })
            }
        }
        .padding(.top, 8)
        
}
}
