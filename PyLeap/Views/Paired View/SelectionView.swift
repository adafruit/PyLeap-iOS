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
    let selectedPeripheral = FileTransferConnectionManager.shared.selectedPeripheral
    

    @State private var boardBootInfo = ""
    
    
    @State private var inConnectedInSelectionView = true
    
    var body: some View {
        
        let connectedPeripherals = connectionManager.peripherals.filter{$0.state == .connected}
        
        NavigationView {
            VStack {
//                Section(
//                    header:
//                        HStack{
//                            Spacer()
//                            Text("Connected peripherals:")
//                                .foregroundColor(.white)
//                            Spacer()
//                        },
//                    footer:
//                        HStack {
//
//                            Button(
//                                action: {
//                                    FileTransferConnectionManager.shared.reconnect()
//                                },
//                                label: {
//                                    Label("Find paired peripherals", systemImage: "arrow.clockwise")
//                                })
//
//
//                        }) {
//
//                if connectedPeripherals.isEmpty {
//                        Text("No peripherals found".uppercased())
//                            .foregroundColor(.gray)
//                            .frame(maxWidth: .infinity)
//                    }
//                    else {
//                    let selectedPeripheral = FileTransferConnectionManager.shared.selectedPeripheral
//                    ForEach(connectedPeripherals, id: \.identifier) { peripheral in
//
//                        HStack {
//                            Button(action: {
//                                DLog("Select: \(peripheral.name ?? peripheral.identifier.uuidString)")
//                                FileTransferConnectionManager.shared.setSelectedClient(blePeripheral: peripheral)
//                            }, label: {
//                                Text(verbatim: "\(peripheral.name ?? "<unknown>")")
//                                    .if(selectedPeripheral?.identifier == peripheral.identifier) {
//                                        $0.bold()
//                                    }
//                            })
//
//                            Spacer()
//
//                            Button(action: {
//                                activeAlert = .confirmUnpair(blePeripheral: peripheral)
//                            }, label: {
//                                Image(systemName: "xmark.circle")
//                            })
//                        }
//                        .foregroundColor(.black)
//
//                    }
//
//                    .listRowBackground(Color.white.opacity(0.7))
//                    }
//                }
                
                
                ScrollView {
                    
                    
                    
                    HStack {
                        Text("Browse all of the available PyLeap Projects")
                            .multilineTextAlignment(/*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .font(Font.custom("ReadexPro-Regular", size: 25))
                            .foregroundColor(.black)
                    }
                    .padding(.vertical,30)
                    
                    ForEach(model.pdemos) { demo in
                        DemoViewCell(result: demo, isConnected: $inConnectedInSelectionView, bootOne: $boardBootInfo, onViewGeometryChanged: {
                            // TODO
                        })
                        
                    }
                }
//                .toolbar {
//                    Button(action: {
//                       // print("Go to...")
//                        //rootModel.goToTest()
//                       // btConnectionViewModel.disconnect(peripheral: selectedPeripheral!)
//                        print("Pressing Disconnection Button")
//                        
//                    }) {
//                        Image(systemName: "list.bullet")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 30, height: 30, alignment: .center)
//                    }                }
//                .modifier(Alerts(activeAlert: $activeAlert))
                
                
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Image("pyleap_logo_white")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .offset(y: -10)
                    }
                }
            }
            .background(Color.white)
            .navigationBarColor(UIColor(named: "pyleap_gray"))
            .navigationBarTitleDisplayMode(.inline)
            
        }
        
        .environmentObject(globalString)
        
        
        
        
        .onChange(of: viewModel.sendingBundle, perform: { newValue in
            globalString.isSendingG = newValue
            print("Is Sending? = \(newValue)")
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
            viewModel.setup(fileTransferClient: connectionManager.selectedClient)
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


