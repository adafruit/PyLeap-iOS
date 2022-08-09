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
    @EnvironmentObject private var connectionManager: FileTransferConnectionManager

    @State var transferInProgress = false
    @State var isDownloaded = false
    
  //  @State private var testState = DownloadState.idle
    
    @EnvironmentObject var globalString : GlobalString
    
    @Binding var bindingString: String
    
    @Binding var downloadStateBinder: DownloadState
    
    @State private var toggleView: Bool = false
    
    let resultItem: ResultItem
    
//    @ObservedObject private var testState: WrappedStruct<DownloadState>
//    init(testState:DownloadState) {
//        _testState = ObservedObject(wrappedValue: WrappedStruct(withItem: testState))
//       }
    
    
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
                
                ImageWithURL(resultItem.projectImage)
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(14)
                    .padding(.top, 30)

                Text("Test Button")
                    .padding(.top, 30)
                    .onAppear(){
                        print("On Appear: \(viewModel.texttest)")
                    }
                    .onTapGesture {
                       print("Attempting to transfer...")
                        viewModel.getProjectURL(nameOf: resultItem.projectName)
                    }
                
//                switch testState {
//                case .idle:
//                    Text("Is idle")
//                    
//                case .downloading:
//                    Text("Is downloading")
//                    
//                case .transferring:
//                    Text("Is transferring")
//                    
//                case .complete:
//                    Text("Is complete")
//                case .failed:
//                    Text("Is failed")
//                default:
//                    Text("default")
//                }
                
                Text(resultItem.description)
                    .font(Font.custom("ReadexPro-Regular", size: 18))
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.1)
                    .padding(.top, 20)
                Text("Compatible with:")
                    .font(Font.custom("ReadexPro-Regular", size: 18))
                    .padding(.top, 5)
                    
                
                ForEach(resultItem.compatibility, id: \.self) { string in
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
                WebView(URLRequest(url: URL(string: resultItem.learnGuideLink)! ))
            })
            
            
            
            
            if isConnected {
                
                if resultItem.compatibility.contains(bindingString) {
                  
                    
                    if viewModel.state == .idle {
                        
                        Button(action: {

                            viewModel.state = .transferring
                            viewModel.getProjectURL(nameOf: resultItem.projectName)
                          
                            if selectionModel.isConnectedToInternet == false {
                                print("Going offline...")
                                viewModel.state = .transferring
                                viewModel.getProjectURL(nameOf: resultItem.projectName)
                            }

                            if viewModel.projectDownloaded == false && selectionModel.isConnectedToInternet == false {
                                print("No Internet Connection and Project not downloaded.")
                                offlineWithoutProject = true
                                viewModel.state  = .idle

                            }

                            if viewModel.projectDownloaded == false {

                            }
                            
                        }) {
                            
                            RunItButton()
                            .padding(.top, 20)
                              
                        }
                    }
                    
                    if viewModel.state  == .failed {
                        
                        FailedButton()
                            .padding(.top, 20)
                    }
                    
                    
                    if viewModel.state  == .transferring {
                        
                        
                        Button(action: {
                            print("Project Selected: \(resultItem.projectName) - DemoSubView")
                        }) {

                            DownloadingButton()
                                .padding(.top, 20)
                        }
                        .disabled(true)

                        VStack(alignment: .center, spacing: 0) {
                            ProgressView("", value: CGFloat(viewModel.counter), total: CGFloat(viewModel.numOfFiles) )
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
                    

                    
                    if viewModel.state  == .complete {
                        
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
                        viewModel.state = .idle
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
            viewModel.getProjectForSubClass(nameOf: resultItem.projectName)
        })
        
        .onChange(of: downloadModel.didDownloadBundle, perform: { newValue in
            print("For project: \(resultItem.projectName), project download is \(newValue)")
            
            globalString.projectString = resultItem.projectName
            
            if newValue {
                DispatchQueue.main.async {
                    print("Getting project from Subclass \(resultItem.projectName)")
                    viewModel.getProjectForSubClass(nameOf: resultItem.projectName)
                    isDownloaded = true
                }
            }else {
                print("was not downloaded")
                isDownloaded = false
            }
            
        })
        
        .onChange(of: connectionManager.selectedClient) { selectedClient in
            viewModel.setup(fileTransferClient: selectedClient)
        }
        .onAppear {
           // downloadModel.delegate = self
            print("SelectionView")
            viewModel.setup(fileTransferClient: connectionManager.selectedClient)
            print("in cell model")
            viewModel.readFile(filename: "boot_out.txt")
            viewModel.readBoardStatus()
        }
    
        
        .onAppear(perform: {
            viewModel.getProjectForSubClass(nameOf: resultItem.projectName)
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


