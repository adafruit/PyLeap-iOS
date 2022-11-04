//
//  WifiSubViewCell.swift
//  PyLeap
//
//  Created by Trevor Beaton on 9/1/22.
//

import SwiftUI

struct WifiSubViewCell: View {
    @State var transferInProgress = false
    @State var isDownloaded = false
        
    @StateObject var wifiFileTransfer = WifiFileTransfer()
    let result : ResultItem
    
    
    @Binding var bindingString: String
    
    @Binding var downloadStateBinder: DownloadState
    
    @State private var toggleView: Bool = false

    @EnvironmentObject var rootViewModel: RootViewModel
    @StateObject var downloadModel = DownloadViewModel()
    @StateObject var viewModel = WifiSubViewCellModel()

    @Binding var isConnected : Bool
    
    @State private var showWebViewPopover: Bool = false
    @State var errorOccured = false
    @State private var presentAlert = false
    
    @State var offlineWithoutProject = false
    
    
    
    var body: some View {
        
        VStack {
            
            VStack(alignment: .leading, spacing: 0, content: {
                
                if viewModel.projectDownloaded {
                    
                    HStack {
                        Spacer()
                        
                        Text("Downloaded")
                            .foregroundColor(.green)
                            .padding(.trailing, -15)
                        Circle()
                            .fill(.green)
                            .frame(width: 15, height: 15)
                            .padding()
                    }
                    .padding(.vertical, -8)
                }

                
                ImageWithURL(result.projectImage)
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(14)
                    .padding(.top, 30)

                
                Text(result.description)
                    .font(Font.custom("ReadexPro-Regular", size: 18))
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.1)
                    .padding(.top, 20)
                Text("Compatible with:")
                    .font(Font.custom("ReadexPro-Bold", size: 18))
                    .padding(.top, 5)
             
                HStack {
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 25, height: 22, alignment: .center)
                        .foregroundColor(.green)
                    Text("ESP32-S2")
                        .font(Font.custom("ReadexPro-Regular", size: 18))
                        .foregroundColor(.black)
                }
                .padding(.top, 10)
                
                ForEach(result.compatibility, id: \.self) { string in
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
                        .padding(.top, 10)
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
                        }
                        .padding(.top, 10)
                    }
                }
            })
            .ignoresSafeArea(.all)
            .padding(.horizontal, 30)
            
            Button(action: {
                showWebViewPopover = true
                
            }) {
                LearnGuideButton()
                    .padding(.top, 20)
            }
            .sheet(isPresented: $showWebViewPopover, content: {
                WebView(URLRequest(url: URL(fileURLWithPath: result.learnGuideLink)))
            })
            
            
            
            
            if isConnected {
                
                if result.compatibility.contains(bindingString) {
                                       
                    
                    if wifiFileTransfer.downloadState == .idle {
                        
                        
                        Button {
                            
                            if wifiFileTransfer.projectDownloaded {
                                
                                wifiFileTransfer.testFileExistance(for: result.projectName, bundleLink: result.bundleLink)
                                
                            } else {
                                downloadModel.trueDownload(useProject: result.bundleLink, projectName: result.projectName)
                            }
                            
                        } label: {
                            RunItButton()
                                .padding(.top, 20)
                        }
                        
                    }
                    
                    if wifiFileTransfer.downloadState == .transferring {
                        DownloadingButton()
                            .padding(.top, 20)
                            .disabled(true)
                        
                        VStack(alignment: .center, spacing: 5) {
                            ProgressView("", value: CGFloat(wifiFileTransfer.counter), total: CGFloat(wifiFileTransfer.numOfFiles) )
                                .padding(.horizontal, 90)
                                .padding(.top, -8)
                                .padding(.bottom, 10)
                                .accentColor(Color.gray)
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                                .cornerRadius(10)
                                .frame(height: 10)
                            
                            ProgressView()
                        }
                    }
                    
                    if wifiFileTransfer.downloadState == .complete {
                        CompleteButton()
                            .padding(.top, 20)
                            .disabled(true)
                    }
                    
                    
                    
                    }
                    
            } else {
                
                Button  {
                    rootViewModel.goTobluetoothPairing()
                } label: {
                    ConnectButton()
                        .padding(.top, 20)
                }
                
            }
        }
        Spacer()
            .frame(height: 30)
        .ignoresSafeArea(.all)
        
//        .onChange(of: downloadModel.didDownloadBundle, perform: { newValue in
//            print("For project: \(title), project download is \(newValue)")
//
//            if newValue {
//                DispatchQueue.main.async {
//                    print("Getting project from Subclass \(title)")
//                   // viewModel.getProjectForSubClass(nameOf: title)
//                    wifiFileTransfer.projectValidation(nameOf: title)
//
//                    isDownloaded = true
//                }
//            }else {
//                print("Is not downloaded")
//                isDownloaded = false
//            }
//
//        })
        .onAppear(perform: {
            
            viewModel.searchPathForProject(nameOf: result.projectName)
            
          //  wifiFileTransfer.getProjectForSubClass(nameOf: title)
            
            if viewModel.projectDownloaded {
                isDownloaded = true
            } else {
                isDownloaded = false
            }
            print("is downloaded? \(viewModel.projectDownloaded)")
        })
        .padding(.top, 8)
        
    }
}


