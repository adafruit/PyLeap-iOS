//
//  DemoSubCellView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/23/22.
//

import SwiftUI
import FileTransferClient

struct DemoSubview: View {
    
    @Binding var bindingString: String
    
    let title: String
    let image: String
    let description: String
    let learnGuideLink: URLRequest
    let downloadLink: String
    let compatibility: [String]
    
    @EnvironmentObject var rootViewModel: RootViewModel
    @StateObject var downloadModel = DownloadViewModel()
    @StateObject var viewModel = SubCellViewModel()
    @StateObject var selectionModel = BleModuleViewModel()
    @StateObject var contentTransfer = BleContentTransfer()
    
    @ObservedObject var connectionManager = FileTransferConnectionManager.shared
    
    
    @Binding var isConnected : Bool
    
    @State private var showWebViewPopover: Bool = false
    @State var errorOccured = false
    @State private var presentAlert = false
    
    @State var offlineWithoutProject = false
    
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

Disconnect from the computer.

Press "Reset" on the device.
""", exitTitle: "Retry") {
            contentTransfer.transferError = false
        }
    }
    
    var body: some View {
        
        VStack {
            
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
            
            VStack(alignment: .leading, spacing: 0, content: {
                
                ImageWithURL(image)
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(14)
                    .padding(.top, 30)
                
                
                Text(description)
                    .font(Font.custom("ReadexPro-Regular", size: 18))
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.1)
                    .padding(.top, 20)
                Text("Compatible with:")
                    .font(Font.custom("ReadexPro-Bold", size: 18))
                    .padding(.top, 5)
                
                
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
                WebView(URLRequest(url: learnGuideLink.url!))
            })
            
            
            
            
            if isConnected {
                
                if compatibility.contains(bindingString) {
                    
                    Button {
                        viewModel.deleteStoredFilesInFM()
                    } label: {
                        Text("Delete File Manager Contents")
                            .bold()
                            .padding(12)
                    }
                    
                    if contentTransfer.downloadState == .idle {
                        
                        Button(action: {
                            
                            /// Condition: Connected to the internet
                            ///- If you're not connected to the internet, but you've downloaded the project...
                            /// - If you're not connected to the internet, and you're project is not downloaded...
                            /// *Show Alert*
                            
                            if viewModel.projectDownloaded == false && viewModel.isConnectedToInternet == false {
                                showAlertMessage()
                            } else {
                                contentTransfer.testFileExistance(for: title, bundleLink: downloadLink)
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
                            ProgressView("", value: CGFloat(contentTransfer.contentCommands.counter), total: CGFloat(contentTransfer.numOfFiles) )
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
        
        
            .onAppear(){
                
                print("On Appear")
                contentTransfer.contentCommands.setup(fileTransferClient: connectionManager.selectedClient)
                // viewModel.readFile(filename: "boot_out.txt")
            }
        
            .onChange(of: contentTransfer.transferError, perform: { newValue in
                if newValue {
                    showTransferErrorMessage()
                }
            })
        
            .onAppear(perform: {
                viewModel.getProjectForSubClass(nameOf: title)
                if viewModel.projectDownloaded {
                    viewModel.projectDownloaded = true
                } else {
                    viewModel.projectDownloaded = false
                }
            })
            .padding(.top, 8)
    }
}


