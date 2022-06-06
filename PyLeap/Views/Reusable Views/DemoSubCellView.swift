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
    @Published var downloadLinkString = ""
    @Published var compatibilityString = ""
    
    
    @Published var counterG = 0
    @Published var numberOfFilesG = 0
    @Published var isSendingG = false
    @Published var bundleHasBeenDownloaded = false
    @Published var numberOfTimesDownloaded = 0
    @Published var attemptToDownload = false
    @Published var attemptToSend = false
}

struct DemoSubview: View {
    @State var transferInProgress = false
    @State var isDownloaded = false
    
    @EnvironmentObject var globalString : GlobalString
    
    @Binding var bindingString: String
    
    @Binding var downloadStateBinder: DownloadState
    
    @State private var toggleView: Bool = false
    
    let title: String
    let image: String
    let description: String
    let learnGuideLink: URLRequest
    let downloadLink: String
    let compatibility: [String]
    
    @EnvironmentObject var rootViewModel: RootViewModel
    @StateObject var downloadModel = DownloadViewModel()
    @StateObject var viewModel = SubCellViewModel()
    @StateObject var selectionModel = SelectionViewModel()
    
    @Binding var isConnected : Bool
    
    @State private var showWebViewPopover: Bool = false
    @State var errorOccured = false
    @State private var presentAlert = false
    
    @State var offlineWithoutProject = false
    
    
    
    var body: some View {
        
        VStack {
            
            
            
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
                    .font(Font.custom("ReadexPro-SemiBold", size: 18))
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
                showWebViewPopover = true
                
            }) {
                LearnGuideButton()
                    .padding(.top, 20)
            }
            .sheet(isPresented: $showWebViewPopover, content: {
                WebView(URLRequest(url: learnGuideLink.url!))
            })
            
            
            
            
            if isConnected {
                
                if compatibility.contains(bindingString) {
                  
                       
                    
                    if downloadStateBinder == .idle {
                        
                       
                        
                        Button(action: {

                            downloadStateBinder = .transferring
                            globalString.isSendingG = true
                            globalString.counterG = 0
                            globalString.numberOfFilesG = 1
                            
                            
                            globalString.downloadLinkString = downloadLink
                            globalString.projectString = title
                            globalString.attemptToDownload.toggle()
                            
                           
                            

                            
                            if selectionModel.isConnectedToInternet == false {
                                print("Going offline...")
                                downloadStateBinder = .transferring
                                
                                globalString.projectString = title
                                globalString.attemptToSend.toggle()
                            }
                            
                            if viewModel.projectDownloaded == false && selectionModel.isConnectedToInternet == false {
                                offlineWithoutProject = true
                                downloadStateBinder = .idle
                                
                            }
                            
                            if viewModel.projectDownloaded == false {
                                
                            }
                            
                        }) {
                            
                            RunItButton()
                            .padding(.top, 20)
                              
                        }
                    }
                    
                    if downloadStateBinder == .failed {
                        
                        FailedButton()
                            .padding(.top, 20)
                    }
                    
                    
                    if downloadStateBinder == .transferring {
                        
                        Button(action: {
                           
                            print("Project Selected: \(title) - DemoSubView")

                            globalString.projectString = title
                            globalString.numberOfTimesDownloaded += 1

                        }) {

                            DownloadingButton()
                                .padding(.top, 20)
                        }
                        .disabled(true)



                        if globalString.isSendingG {

                            VStack(alignment: .center, spacing: 0) {
                                ProgressView("", value: CGFloat(globalString.counterG), total: CGFloat(globalString.numberOfFilesG) )
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

                        
                    }
                    

                    
                    if downloadStateBinder == .complete {
                        
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
        
        
    
        .alert("Project Not Found", isPresented: $offlineWithoutProject) {
                    Button("OK") {
                        // Handle acknowledgement.
                        print("OK")
                        offlineWithoutProject = false
                        downloadStateBinder = .idle
                        selectionModel.state = .idle
                        print("\(offlineWithoutProject)")
                    }
                } message: {
                    Text("""
                         To use this project, connect to the internet.
                         """)
                    .multilineTextAlignment(.leading)
                }
        
        .onChange(of: downloadModel.isDownloading, perform: { newValue in
            viewModel.getProjectForSubClass(nameOf: title)
        })
        
        .onChange(of: downloadModel.didDownloadBundle, perform: { newValue in
            print("For project: \(title), project download is \(newValue)")
            
            globalString.projectString = title
            
            if newValue {
                DispatchQueue.main.async {
                    print("Getting project from Subclass \(title)")
                    viewModel.getProjectForSubClass(nameOf: title)
                    isDownloaded = true
                }
            }else {
                print("Is not downloaded")
                isDownloaded = false
            }
            
        })
        .onAppear(perform: {
            viewModel.getProjectForSubClass(nameOf: title)
            if viewModel.projectDownloaded {
                isDownloaded = true
            } else {
                isDownloaded = false
            }
            print("is downloaded? \(isDownloaded)")
        })
        .padding(.top, 8)
        
    }
}


