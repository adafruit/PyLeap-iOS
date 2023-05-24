//
//  DemoSubCellView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/23/22.
//

import SwiftUI
import FileTransferClient

struct DemoSubview: View {
    
    let result: ResultItem
    
    @EnvironmentObject var rootViewModel: RootViewModel
    @StateObject var viewModel = SubCellViewModel()
    //@StateObject var contentTransfer = BleContentTransfer()
    @StateObject var contentTransfer = BleContentTransfer.shared
    
    
    @ObservedObject var connectionManager = FileTransferConnectionManager.shared
    
    @Binding var isConnected : Bool
    @State private var showWebViewPopover: Bool = false
        
    func showAlertMessage() {
        alertMessage(title: """
There's a problem with your internet connection.
Try again later.
""", exitTitle: "Ok") {
        }
    }
    
    func showTransferErrorMessage() {
        alertMessage(title: """
Transfer Failed

Disconnect device from the computer.

Press "Reset" on the device and use a battery source.
""", exitTitle: "Retry") {
            contentTransfer.transferError = false
        }
    }
    
    func showDownloadErrorMessage() {
        alertMessage(title: """
Server Error

This project can not be downloaded at this time

Try again later
""", exitTitle: "Ok") {
            contentTransfer.downloaderror = false
        }
    }
    
    var body: some View {
        
        VStack {
            
            if viewModel.projectDownloaded {
                
//                HStack {
//                    Spacer()
//                    
//                    Text("Downloaded")
//                        .foregroundColor(.green)
//                        .padding(.trailing, -15)
//                    Circle()
//                        .fill(.green)
//                        .frame(width: 15, height: 15)
//                        .padding()
//                }
//                .padding(.vertical, -8)
            }
            
            VStack(alignment: .leading, spacing: 0, content: {
                
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
                if !viewModel.isConnectedToInternet {
                    showAlertMessage()
                } else {
                    showWebViewPopover = true
                    
                }
                
            }) {
                LearnGuideButton()
                    .padding(.top, 20)
            }
            .sheet(isPresented: $showWebViewPopover, content: {
                SwiftUIWebView(webAddress: result.learnGuideLink)
            })
            
            
            
            
            if isConnected {
                

                    if contentTransfer.downloadState == .idle {
                        
                        Button(action: {
                            
                            /// Condition: Connected to the internet
                            ///- If you're not connected to the internet, but you've downloaded the project...
                            /// - If you're not connected to the internet, and you're project is not downloaded...
                            /// *Show Alert*
                            
                            if viewModel.projectDownloaded == false && viewModel.isConnectedToInternet == false {
                                showAlertMessage()
                            } else {
                                contentTransfer.testFileExistance(for: result.projectName, bundleLink: result.bundleLink)
                            }
                            
                        }) {
                            
                            RunItButton()
                                .padding(.top, 20)
                        }
                    }
                    
                    if contentTransfer.downloadState == .failed {
                        FailedButton()
                            .padding(.top, 20)
                    }
                    
                    if contentTransfer.downloadState == .transferring {
                        DownloadingButton()
                            .padding(.top, 20)
                            .disabled(true)
                        
                        VStack(alignment: .center, spacing: 5) {
                            ProgressView("", value: CGFloat(contentTransfer.counter), total: CGFloat(contentTransfer.numOfFiles) )
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
                    
                    if contentTransfer.downloadState == .complete {
                        CompleteButton()
                            .padding(.top, 20)
                    }
                
                
            } else {
                
                Button  {
                    rootViewModel.goToSelection()
                } label: {
                    ConnectButton()
                        .padding(.top, 20)
                }
                
            }
        }
        Spacer()
            .frame(height: 30)
            .ignoresSafeArea(.all)
        
            .onAppear(){
                
                print("On Appear")
                contentTransfer.contentCommands.setup(fileTransferClient: connectionManager.selectedClient)
                }
        
            .onChange(of: contentTransfer.transferError, perform: { newValue in
                if newValue {
                    showTransferErrorMessage()
                }
            })
        
            .onChange(of: contentTransfer.downloaderror, perform: { newValue in
                if newValue {
                    showDownloadErrorMessage()
                }
            })

            .onAppear(perform: {
                
                viewModel.searchPathForProject(nameOf: result.projectName)
              
                if viewModel.projectDownloaded {
                    viewModel.projectDownloaded = true
                } else {
                    viewModel.projectDownloaded = false
                }
                
            }
            
            )
            .padding(.top, 8)
    }
}


