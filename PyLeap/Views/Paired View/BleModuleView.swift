// ;}
//  FileView.swift
//  SwiftUI File Manager
//
//  Created by Trevor Beaton on 7/11/21.
//
///FileTransferView
import SwiftUI
import FileTransferClient

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
    @ObservedObject var networkService = NetworkService()
    @EnvironmentObject var rootViewModel: RootViewModel
    
    //clearKnownPeripheralUUIDs
    
    @State private var isConnected = false
    @State private var errorOccured = false
    @State private var scrollViewID = UUID()
    
    @State private var activeAlert: ActiveAlert?
    
    
    @State private var boardBootInfo = ""
    
    
    @State private var inConnectedInSelectionView = true
    
    @AppStorage("shouldShowOnboarding123") var switchedView: Bool = false
    
    @State var isExpanded = true
    @State var subviewHeight : CGFloat = 0
    
    var body: some View {
        
     //   var connectedPeripherals = connectionManager.peripherals.filter{$0.state == .connected }
       // let selectedPeripheral = FileTransferConnectionManager.shared.selectedPeripheral
        
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
                            HStack {
                                Text("Connected to Circuit Playground Bluefruit")
                                    .font(Font.custom("ReadexPro-Regular", size: 16))
                                
                            Image("bluetoothLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                            }
                            
                                
                        }
                        
                        if boardBootInfo == "clue_nrf52840_express" {
                            VStack {
                                
                                HStack {
                                    Text("Connected to Adafruit CLUE")
                                        .font(Font.custom("ReadexPro-Regular", size: 16))
                                    
                                    Image("bluetoothLogo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                }
                               // Expandable
                                VStack {
                                    Text("More Info")
                                }
                                .background(GeometryReader {
                                            Color.clear.preference(key: ViewHeightKey.self,
                                                                   value: $0.frame(in: .local).size.height)
                                        })
                                
                                
                            }
                            
                            .onPreferenceChange(ViewHeightKey.self) { subviewHeight = $0 }
                                    .frame(height: isExpanded ? subviewHeight : 50, alignment: .top)
                            
                            .clipped()
                                    .frame(maxWidth: .infinity)
                                    .transition(.move(edge: .bottom))

                            
                            .onTapGesture {
                                        withAnimation(.easeIn(duration: 0.5)) {
                                            isExpanded.toggle()
                                        }
                                    }
                        }
                        
                    }
                    .padding(.all, 0.0)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 40)
                    .background(Color("adafruit_blue"))
                    .foregroundColor(.white)
                    
                    
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        
                        ScrollViewReader { scroll in
                            
                            MainSubHeaderView()
                              //  .spotlight(enabled: spotlight.counter == 1, title: "1")
                              
                            let check = networkService.pdemos.filter {
                                $0.compatibility.contains(boardBootInfo)
                            }
                            
                            
                            ForEach(check) { demo in
                                
                                
                                DemoViewCell(result: demo, isConnected: $inConnectedInSelectionView, deviceInfo: $boardBootInfo, onViewGeometryChanged: {
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
            print("Opened BleModuleView")
         //   networkServiceModel.fetch()
            
            viewModel.setup(fileTransferClient:connectionManager.selectedClient)
            
            connectionManager.isSelectedPeripheralReconnecting = true

            viewModel.readFile(filename: "boot_out.txt")
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

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}
