// ;}
//  FileView.swift
//  SwiftUI File Manager
//
//  Created by Trevor Beaton on 7/11/21.
//
///FileTransferView
import SwiftUI
import FileTransferClient

class SpotlightCounter: ObservableObject {
    @Published var counter = 0
}

struct SelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var connectionManager: FileTransferConnectionManager
    @StateObject var viewModel = SelectionViewModel()
    @ObservedObject var model = NetworkService()
    @StateObject var globalString = GlobalString()
    @StateObject var btConnectionViewModel = BTConnectionViewModel()
    @StateObject private var rootModel = RootViewModel()
    @StateObject var downloadModel = DownloadViewModel()
    @StateObject var spotlight = SpotlightCounter()
    
    //clearKnownPeripheralUUIDs
    
    @State private var isConnected = false
    //@State private var switchedView = false
    // Error Alert triggers
    @State private var errorOccured = false
    @State private var zipAlert = false
    
    @State private var downloadState = DownloadState.idle
    @State private var scrollViewID = UUID()
    @State var currentHightlight: Int = 0
    
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
    @State private var showAlert1 = false
    let selectedPeripheral = FileTransferConnectionManager.shared.selectedPeripheral
    
    
    @State private var boardBootInfo = ""
    
    
    @State private var inConnectedInSelectionView = true
    
    @AppStorage("shouldShowOnboarding123") var switchedView: Bool = false
    
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
                        .padding(.horizontal, 30)
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .lineLimit(0)
                    
                    
                    
                    
                    if boardBootInfo == "circuitplayground_bluefruit" {
                        Image("cpb")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 226)
                            .minimumScaleFactor(0.01)
                        
                            .padding(.horizontal, 95)
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
                   
                    // Sub-Header
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
                    //.spotlight(enabled: spotlight.counter == 0, title: "Welcome to PyLeap!")
               
              
                
                    ScrollView(.vertical, showsIndicators: true) {
                        
                        ScrollViewReader { scroll in
                            
                            SubHeaderView()
                              //  .spotlight(enabled: spotlight.counter == 1, title: "1")
                              
                            
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
                .alert("Cannot Write To Device", isPresented: $errorOccured) {
                            Button("OK") {
                                // Handle acknowledgement.
                                print("OK")
                                errorOccured = false
                            }
                        } message: {
                            Text("""
                                 Unplug device from computer and use external power source.
                                 
                                 Then press RESET on device to continue.
                                 """)
                            .multilineTextAlignment(.leading)
                        }
                
                        .alert("Download Error", isPresented: $zipAlert) {
                                    Button("OK") {
                                        // Handle acknowledgement.
                                        print("OK")
                                        zipAlert = false
                                    }
                                } message: {
                                    Text("""
                                         Unable to download this project bundle.
                                         
                                         Try again later.
                                         """)
                                    .multilineTextAlignment(.leading)
                                }
                
                .onTapGesture {
                    spotlight.counter += 1
                    print("\(spotlight.counter)")
                }
            }
        }
        .background(Color.white)
        .environmentObject(globalString)
        
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
            print("State Change: \(newValue )")
            if newValue == .failed {
                print("Failed Value")
                errorOccured = true
            }
        })
        
        .onChange(of: viewModel.writeError, perform: { newValue in
            print("Change happened! \(newValue)")
            
            globalString.bundleHasBeenDownloaded = newValue
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
            viewModel.readBoardStatus()
            print("newValue \(newValue)")
            boardBootInfo = newValue
        })
        
        .onChange(of: globalString.projectString, perform: { newValue in
          print("Start Transfer")
          //  viewModel.getProjectURL(nameOf: newValue)
            
        })
        
        .onChange(of: globalString.attemptToDownload, perform: { newValue in
            print("Start Download Process\(globalString.downloadLinkString) - \(globalString.projectString)")
            downloadModel.startDownload(urlString: globalString.downloadLinkString, projectTitle: globalString.projectString)
            
        })
        
        .onChange(of: globalString.attemptToSend, perform: { newValue in
           
            viewModel.getProjectURL(nameOf: globalString.projectString)
            
        })
        
        .onChange(of: downloadModel.attemptToSendBunle, perform: { newValue in
            print("Attempting transfer of: \(globalString.projectString)")
            viewModel.getProjectURL(nameOf: globalString.projectString)
            
        })
        
        
        .onChange(of: connectionManager.selectedClient) { selectedClient in
            viewModel.setup(fileTransferClient: selectedClient)
        }
        .onAppear {
            downloadModel.delegate = self
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

extension SelectionView: DownloadDelegate {
    func errorHappened() {
        print("Error Occurred")
        zipAlert = true
        
        DispatchQueue.main.async {
            downloadState = .failed
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            downloadState = .idle
        }
    }

    
    
}


