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
    @StateObject var wifiTransferService = WifiTransferService()
    let result : ResultItem
    
    @Binding var bindingString: String
    
    @Binding var downloadStateBinder: DownloadState
    
    @State private var toggleView: Bool = false
    
    @EnvironmentObject var rootViewModel: RootViewModel
    @StateObject var downloadModel = DownloadViewModel()
    @ObservedObject var viewModel = WifiSubViewCellModel()
    
    @Binding var isConnected : Bool
    
    @State private var counter = 0
    @State private var numOfFiles = 0
    @State var downloadState: DownloadState = .idle
    
    
    @State private var showWebViewPopover: Bool = false
    @State var errorOccured = false
    @State private var presentAlert = false
    
    @State var offlineWithoutProject = false
    
    
    func showTransferErrorMessage() {
        alertMessage(title: """
Download Error
Unable to download project
Try again later
""", exitTitle: "Retry") {
            wifiFileTransfer.transferError = false
        }
    }
    
    func usbInUseErrorMessage() {
        alertMessage(title: """
USB In Use

Files cannot be tranferred or moved while USB is in use.

Remove device from USB. Press "Reset" on the device.
""", exitTitle: "Retry") {
            //  wifiFileTransfer.transferError = false
            
        }
    }
    

    
    func startTransferProcess() {
        
    
            if isDownloaded {
                print("Project found")
                wifiFileTransfer.testFileExistance(for: result.projectName, bundleLink: result.bundleLink)
                
            } else {
            print("Project not found")
                downloadModel.trueDownload(useProject: result.bundleLink, projectName: result.projectName)
            }
        
        
    }
    
    
  
    
    
        func testOperation() {
            let operationQueue = OperationQueue()

            let operation1 = BlockOperation {
                wifiTransferService.optionRequest(handler: { results in
                    
                    switch results {
                        
                    case .success(let contents):

                        if contents.contains("GET, OPTIONS, PUT, DELETE, MOVE") {
                            
                        } else {
                            print("Connected to USB")
                            DispatchQueue.main.async {
                                usbInUseErrorMessage()
                                wifiFileTransfer.stopTransfer = true
                            }
                        }
                        
                    case .failure:
                        print("Failure")
                    }
                })
            }
            
            let operation2 = BlockOperation {
                
                if isDownloaded {
                    print("Project found")
                    wifiFileTransfer.testFileExistance(for: result.projectName, bundleLink: result.bundleLink)
                    
                } else {
                print("Project not found")
                    downloadModel.trueDownload(useProject: result.bundleLink, projectName: result.projectName)
                }
            
                
            }
            
            
            // Add operations to the operation queue
            operationQueue.addOperation(operation1)
            operationQueue.addOperation(operation2)
            
            // Block the current thread until all operations have finished executing
            operationQueue.waitUntilAllOperationsAreFinished()
            
        }
    
    
    var body: some View {
        
        VStack {
            
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
                SwiftUIWebView(webAddress: result.learnGuideLink)
            })
            
            
            
            
            if isConnected {
                
                if result.compatibility.contains(bindingString) {
                    
                    
                    if wifiFileTransfer.testIndex.downloadState == .idle {
                        
                        
                        Button {
                            //   NotificationCenter.default.post(name: .didCompleteZip, object: nil, userInfo: projectResponse)

                            testOperation()
                            
                        } label: {
                            RunItButton()
                                .padding(.top, 20)
                        }
                        
                    }
                    
                    if wifiFileTransfer.testIndex.downloadState == .transferring  {
                        DownloadingButton()
                            .padding(.top, 20)
                            .disabled(true)
                        
                        VStack(alignment: .center, spacing: 5) {
                            ProgressView("", value: CGFloat(counter), total: CGFloat(numOfFiles))
                                .padding(.horizontal, 90)
                                .padding(.top, -5)
                                .padding(.bottom, 10)
                                .accentColor(Color.gray)
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                                .cornerRadius(10)
                                .frame(height: 10)
                            
                            ProgressView()
                        }
                    }
                    
                    if wifiFileTransfer.testIndex.downloadState == .complete {
                        CompleteButton()
                            .padding(.top, 20)
                            .disabled(true)
                    }
                    
                    if wifiFileTransfer.testIndex.downloadState == .failed {
                        FailedButton()
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
        

            .onAppear(perform: {
                
                wifiFileTransfer.registerWifiNotification(enabled: true)
                
                viewModel.searchPathForProject(nameOf: result.projectName)
                
                
                if viewModel.projectDownloaded {
                    isDownloaded = true
                } else {
                    isDownloaded = false
                }
                print("is downloaded? \(viewModel.projectDownloaded)")
                            
            })
        
        
            .padding(.top, 8)
        
            .onChange(of: wifiFileTransfer.transferError, perform: { newValue in
                if newValue {
                    showTransferErrorMessage()
                }
            })
        
            .onChange(of: viewModel.showUsbInUseError) { newValue in
                if newValue {
                    usbInUseErrorMessage()
                }
            }
        
            .onChange(of: wifiFileTransfer.counter) { newValue in
                print("New counter : \(newValue)")
                counter = newValue
            }
        
            .onChange(of: wifiFileTransfer.numOfFiles) { newValue in
                print("New numOfFiles : \(newValue)")
                numOfFiles = newValue
            }
        
        
            .onChange(of: wifiFileTransfer.testIndex.count) { newValue in
                print("New count index : \(newValue)")
            }
        
            .onChange(of: wifiFileTransfer.testIndex.numberOfFiles) { newValue in
                print("New numberOfFiles index : \(newValue)")
            }
        
            .onChange(of: wifiFileTransfer.testIndex.downloadState) { newValue in
                print("New download state : \(newValue)")
            }
        
            
        
            .onChange(of: wifiFileTransfer.downloadState) { newValue in
                switch newValue {
                case .idle:
                    downloadState = .idle
                    print("idle")
                case .transferring:
                    downloadState = .transferring
                    print("transferring")
                case .complete:
                    downloadState = .complete
                    print("complete")
                case .downloading:
                    downloadState = .downloading
                    print("downloading")
                case .failed:
                    downloadState = .failed
                    print("failed")
                }
            }
        
    }
}


