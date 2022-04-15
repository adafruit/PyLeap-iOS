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
  @Published var compatibilityString = ""
    
    @Published var counterG = 0
    @Published var numberOfFilesG = 0
    @Published var isSendingG = false
}

struct DemoSubview: View {
    @State var transferInProgress = false
    @State var isDownloaded = false
    
    @EnvironmentObject var globalString : GlobalString
   
    @Binding var bindingString: String
    
    let title: String
    let image: String
    let description: String
    let learnGuideLink: URLRequest
    let downloadLink: String
    let compatibility: [String]
    var setUUID: String
    
    @StateObject var downloadModel = DownloadViewModel()
    @StateObject var viewModel = SubCellViewModel()
    
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
                                .foregroundColor(.black)
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
                                .foregroundColor(.black)
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
            .onAppear {

            }
            
            
            
            if isConnected {
               
                if compatibility.contains(bindingString) {
                    
                   
                    
                    if isDownloaded == true {
                       
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
                        .disabled(globalString.isSendingG)
                        
                        
                        if globalString.isSendingG {
                            ProgressView("", value: CGFloat(globalString.counterG), total: CGFloat(globalString.numberOfFilesG) )
                                .padding(.horizontal, 80)
                                .padding(.top, 3)
                                .padding(.bottom, 10)
                                .accentColor(Color("pyleap_pink"))
                                .foregroundColor(.purple)
                                .cornerRadius(25)
                                .frame(height: 25)
                            
                            
                        }else {
                            
                        }
                     
                    } else {
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
                    }

                    
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
        
        
        
        .onChange(of: downloadModel.isDownloading, perform: { newValue in
            viewModel.getProjectURL(nameOf: title)
        })
        
        .onChange(of: viewModel.projectDownloaded, perform: { newValue in
            print("For project: \(title), project download is \(newValue) ")
            isDownloaded = newValue
        })
        .onAppear(perform: {
            viewModel.getProjectURL(nameOf: title)
        })
        .padding(.top, 8)
        
}
}
