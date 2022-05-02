// ;}
//  FileView.swift
//  SwiftUI File Manager
//
//  Created by Trevor Beaton on 7/11/21.
//
///FileTransferView
import SwiftUI
import FileTransferClient


struct SelectionView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var connectionManager: FileTransferConnectionManager
    @StateObject var viewModel = SelectionViewModel()
    @ObservedObject var model = NetworkService()
    @StateObject var globalString = GlobalString()
    @StateObject var btConnectionViewModel = BTConnectionViewModel()
    @StateObject private var rootModel = RootViewModel()
    
    
    
    //clearKnownPeripheralUUIDs
    
    @State private var isConnected = false
    @State private var switchedView = false
    @State private var errorOccured = false
    @State private var downloadState = DownloadState.idle
    @State private var scrollViewID = UUID()
    
    // Data
    enum ActiveAlert: Identifiable {
        case confirmUnpair(blePeripheral: BlePeripheral)
        
        var id: Int {
            switch self {
            case .confirmUnpair: return 1
            }
        }
    }
    
    
    @State private var activeAlert: ActiveAlert?
    @State private var internetAlert = false
    
    let selectedPeripheral = FileTransferConnectionManager.shared.selectedPeripheral
    
    
    @State private var boardBootInfo = ""
    
    
    @State private var inConnectedInSelectionView = true
    
    var body: some View {
        
        let connectedPeripherals = connectionManager.peripherals.filter{$0.state == .connected}
        let selectedPeripheral = FileTransferConnectionManager.shared.selectedPeripheral
        
        VStack {
            //Start
            
            if switchedView == false {
                HStack {
                    
                    Spacer()
                    Image("bluetooth")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30, alignment: .center)
                        .padding(35)
                    
                }
                
                Image("pyleapLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .minimumScaleFactor(0.01)
                    .padding(.horizontal, 60)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                VStack(alignment: .center, spacing: 30, content: {
                    
                    
                    Text("Connected!")
                        .font(Font.custom("ReadexPro-Regular", size: 36))
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    
                    
                    
                    if boardBootInfo == "circuitplayground_bluefruit" {
                        Image("cpb")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300.0, height: 300.0)
                            .minimumScaleFactor(0.01)
                        
                            .padding(.horizontal, 60)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("Circuit Playground Bluefruit")
                            .font(Font.custom("ReadexPro-Regular", size: 24))
                            .minimumScaleFactor(0.01)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        
                        
                    } else {
                        
                    }
                    
                    
                    if boardBootInfo == "clue_nrf52840_express" {
                        Image("clue")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300.0, height: 300.0)
                            .padding(.horizontal, 60)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("Adafruit CLUE")
                            .font(Font.custom("ReadexPro-Regular", size: 30))
                            .minimumScaleFactor(0.01)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 20)
                        
                    }
                    
                    
                    
                })
                Spacer()
                
                Button(action: {
                    switchedView = true
                }) {
                    
                    Text("Let's Go!")
                        .font(Font.custom("ReadexPro-Regular", size: 25))
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 60)
                        .frame(height: 50)
                        .background(Color("pyleap_purple"))
                        .clipShape(Capsule())
                }
                
                Spacer()
                    .frame(height: 60)
                
            } else {
                //End
                
                // Start
                
                VStack(spacing: 0) {
                    
                    
                    
                    HeaderView()

                    VStack {
                        
                        if boardBootInfo == "circuitplayground_bluefruit" {
                            Text("Connected to Circuit Playground Bluefruit")
                                .font(Font.custom("ReadexPro-Regular", size: 16))
                        }
                        if boardBootInfo == "clue_nrf52840_express" {
                            Text("Connected to Adafruit CLUE")
                                .font(Font.custom("ReadexPro-Regular", size: 16))
                        }
                        
                    }
                    .padding(.all, 0.0)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 40)
                    .background(Color("pyleap_green"))
                    .foregroundColor(.white)

               
                
                    ScrollView(.vertical, showsIndicators: true) {
                        
                        ScrollViewReader { scroll in
                            
                            SubHeaderView()
                            
                            ForEach(model.pdemos) { demo in
                                DemoViewCell(result: demo, isConnected: $inConnectedInSelectionView, bootOne: $boardBootInfo, onViewGeometryChanged: {
                                    withAnimation {
                                        scroll.scrollTo(demo.id)
                                    }
                                }, stateBinder: $downloadState)
                                
                            }
                        }
                        .id(self.scrollViewID)
                    }
                    
                }
                
            }
        }
        .background(Color.white)
        
        .environmentObject(globalString)
        
        //        .onChange(of: viewModel.writeError, perform: { newValue in
        //            print("changed value")
        //            errorOccured = newValue
        //            if newValue {
        //                errorOccured = true
        //            } else {
        //                errorOccured = false
        //            }
        //
        //
        //        })
        
        //        .onChange(of: globalString.numberOfTimesDownloaded, perform: { newValue in
        //            viewModel.getProjectURL(nameOf: globalString.projectString)
        //            print("Current project...\(globalString.projectString)")
        //            print("Number of downloads: \(newValue)")
        //        })
        
        .alert(isPresented: $errorOccured) {
            Alert(title: Text("Cannot write to device"), message: Text("""
Please unplug from computer and use external power source
Then press RESET on device to continue
"""), dismissButton: .destructive(Text("Got it!"), action: {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    //   selectionModel.writeError = false
                    
                }
            }))
        }
        
        .alert(isPresented: $internetAlert) {
            Alert(
                title: Text("Title"),
                message: Text("Message")
            )}
        
        
        
        .onChange(of: viewModel.isConnectedToInternet, perform: { newValue in
            
            if newValue {
                internetAlert = false
            } else {
                internetAlert = true
            }
        })
        
        .modifier(Alerts(activeAlert: $activeAlert))
        
        .onChange(of: viewModel.state, perform: { newValue in
            print("State: \(newValue)")
            downloadState = newValue
        })
        
        .onChange(of: viewModel.writeError, perform: { newValue in
            print("Change happened! \(newValue)")
            
            globalString.bundleHasBeenDownloaded = newValue
            errorOccured = newValue
        })
        
        .onChange(of: viewModel.sendingBundle, perform: { newValue in
            globalString.isSendingG = newValue
            if newValue {
                print("Is transferring...")
            } else {
                print("Not transferring...")
            }
        })
        
        .onChange(of: viewModel.numOfFiles, perform: { newValue in
            globalString.numberOfFilesG = newValue
            print("NumOfFiles: \(newValue)")
        })
        
        .onChange(of: viewModel.counter, perform: { newValue in
            globalString.counterG = newValue
            print("Change for counterG happened: Value should be \(newValue)")
        })
        
        .onChange(of: viewModel.bootUpInfo, perform: { newValue in
            viewModel.readMyStatus()
            print("newValue \(newValue)")
            boardBootInfo = newValue
        })
        
        .onChange(of: globalString.projectString, perform: { newValue in
            viewModel.getProjectURL(nameOf: newValue)
            
        })
        
        
        
        .onChange(of: connectionManager.selectedClient) { selectedClient in
            viewModel.setup(fileTransferClient: selectedClient)
        }
        .onAppear {
            print("SelectionView")
            viewModel.setup(fileTransferClient: connectionManager.selectedClient)
            viewModel.readFile(filename: "boot_out.txt")
            
        }
        
    }
    
    enum ButtonStatus: CaseIterable, Identifiable {
      case download
      case transfer
      case complete
      
      var id: String { return title }
      
      var title: String {
        switch self {
        case .download: return "Download"
        case .transfer: return "Transfer"
        case .complete: return "Complete"
        }
      }
      
    }
    
    
    struct Alerts: ViewModifier {
        @Binding var activeAlert: ActiveAlert?
        
        func body(content: Content) -> some View {
            content
                .alert(item: $activeAlert, content:  { alert in
                    switch alert {
                    case .confirmUnpair(let blePeripheral):
                        return Alert(
                            title: Text("Confirm disconnect \(blePeripheral.name ?? "")"),
                            message: nil,
                            primaryButton: .destructive(Text("Disconnect")) {
                                //BleAutoReconnect.clearAutoconnectPeripheral()
                                BleManager.shared.disconnect(from: blePeripheral)
                            },
                            secondaryButton: .cancel(Text("Cancel")) {})
                    }
                })
        }
    }
}


