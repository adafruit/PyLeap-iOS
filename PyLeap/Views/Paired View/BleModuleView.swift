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

struct BleModuleView: View {
    
    // Data
    enum ActiveAlert: Identifiable {
        case confirmUnpair(blePeripheral: BlePeripheral)
        
        var id: Int {
            switch self {
            case .confirmUnpair: return 1
            }
        }
    }
    
    
    @Environment(\.presentationMode) var presentationMode
    
    
    @ObservedObject var connectionManager = FileTransferConnectionManager.shared
    let selectedPeripheral = FileTransferConnectionManager.shared.selectedPeripheral
    
    
    


    @StateObject var viewModel = BleModuleViewModel()
    @ObservedObject var networkServiceModel = NetworkService()
    @StateObject var btConnectionViewModel = BTConnectionViewModel()
    @EnvironmentObject var rootViewModel: RootViewModel
    @StateObject var downloadModel = DownloadViewModel()
    @StateObject var spotlight = SpotlightCounter()
    
    //clearKnownPeripheralUUIDs
    
    @State private var isConnected = false
    //@State private var switchedView = false
    @State private var errorOccured = false
    @State private var downloadState = DownloadState.idle
    @State private var scrollViewID = UUID()
    @State var currentHightlight: Int = 0
    
    
    
    
    @State private var activeAlert: ActiveAlert?
    @State private var internetAlert = false
    @State private var showAlert1 = false
    
    
    @State private var boardBootInfo = ""
    
    
    @State private var inConnectedInSelectionView = true
    
    @AppStorage("shouldShowOnboarding123") var switchedView: Bool = false
    
    var body: some View {
        
        var connectedPeripherals = connectionManager.peripherals.filter{$0.state == .connected }
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
                    
//                    Button {
//                        print("Disconnect")
//
//                        activeAlert = .confirmUnpair(blePeripheral: connectedPeripherals[0])
//                        connectedPeripherals = []
//
//                        connectionManager.isConnectedOrReconnecting = false
//                        FileTransferConnectionManager.shared
//                        connectionManager.selectedPeripheral = nil
//                        connectionManager.isAnyPeripheralConnecting = false
//                        connectionManager.isSelectedPeripheralReconnecting = false
//                       // connectionManager.clearAllPeripheralInfo()
//                        rootViewModel.goToMain()
//
//                        print("Destination: \(rootViewModel.destination)")
//                    } label: {
//                        Text("Disconnection")
//                    }

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
                    
                    
                
                    ScrollView(.vertical, showsIndicators: true) {
                        
                        ScrollViewReader { scroll in
                            
                            MainSubHeaderView()
                              //  .spotlight(enabled: spotlight.counter == 1, title: "1")
                              
                            let check = networkServiceModel.pdemos.filter {
                                $0.compatibility.contains(boardBootInfo)
                            }
                            
                            
                            ForEach(check) { demo in
                                
                                
                                DemoViewCell(result: demo, isConnected: $inConnectedInSelectionView, bootOne: $boardBootInfo, onViewGeometryChanged: {
                                    withAnimation {
                                        scroll.scrollTo(demo.id)
                                    }
                                })
                               
                                
                            }
                            
                        }
                        
                        .id(self.scrollViewID)
                    }
                    
                }

            }
        }
        .background(Color.white)


        .onChange(of: viewModel.bootUpInfo, perform: { newValue in
            viewModel.readMyStatus()
            print("newValue \(newValue)")
            boardBootInfo = newValue
        })
        
        .onChange(of: connectionManager.selectedClient) { selectedClient in
            viewModel.setup(fileTransferClient: selectedClient)
        }

        .onAppear(){
            
            print("On Appear")
            networkServiceModel.fetch()
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


