// ;}
//  FileView.swift
//  SwiftUI File Manager
//
//  Created by Trevor Beaton on 7/11/21.
//
///FileTransferView
import SwiftUI
import FileTransferClient

class ExpandedBLECellState: ObservableObject {
    @Published var currentCell = ""
}

class Board: Equatable {
   
    static func == (lhs: Board, rhs: Board) -> Bool {
        return lhs.name == rhs.name && lhs.versionNumber == rhs.versionNumber
    }
    
    static let shared = Board(name: "Unrecognized Board", versionNumber: "8")

    var name: String
    var versionNumber: String
    
    private init(name: String, versionNumber: String) {
        self.name = name
        self.versionNumber = versionNumber
    }
}

struct BleModuleView: View {
    
    @State var boardInfoForView: Board?
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var expandedState : ExpandedBLECellState
    @ObservedObject var connectionManager = FileTransferConnectionManager.shared
    
    @State var unknownBoardName: String?
    
    let selectedPeripheral = FileTransferConnectionManager.shared.selectedPeripheral
    
    @StateObject var viewModel = BleModuleViewModel()
    @EnvironmentObject var rootViewModel: RootViewModel
    
    
    @State private var isConnected = false
    @State private var errorOccured = false
    
    @State var notExpanded = false
    @State var isExpanded = true
    
    @State private var scrollViewID = UUID()
    @State private var boardBootInfo = ""
    @State private var inConnectedInSelectionView = true
    
    @AppStorage("shouldShowOnboarding123") var switchedView: Bool = false
    
    @State var subviewHeight : CGFloat = 0
    
    func showConfirmationPrompt() {
        comfirmationAlertMessage(title: "Are you sure you want to disconnect?", exitTitle: "Cancel", primaryTitle: "Disconnect") {
            connectionManager.isDisconnectingFromCurrent = true
        } cancel: {
            
        }
    }
    
    var body: some View {
        
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
                        
                        
                    } else if boardBootInfo == "clue_nrf52840_express" {
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
                        
                    } else {
                        Image("Placeholder Board Image")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                            .padding(.horizontal, 60)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text(unknownBoardName ?? "")
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
                        
                        BleBannerView(deviceName: boardInfoForView?.name ?? "Unknown Device", disconnectAction: {
                            showConfirmationPrompt()
                        })
                        
                        
                    }
                    .padding(.all, 0.0)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 40)
                    .background(Color("adafruit_blue"))
                    .foregroundColor(.white)
                    
                    
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        
                        ScrollViewReader { scroll in
                            
                            if boardBootInfo == "clue_nrf52840_express" {
                                MainSubHeaderView(device: "Adafruit CLUE")
                            }
                            
                            else if boardInfoForView?.name == "Circuitplayground Bluefruit" {
                                MainSubHeaderView(device: "Circuit Playground")
                                
                            }
                            
                            else {
                                MainSubHeaderView(device: unknownBoardName ?? "device")
                            }
                            
                            
                            let check = viewModel.pdemos.filter {
                                
                                if boardInfoForView?.name == "Circuitplayground Bluefruit" {
                                    let cpbProjects = $0.compatibility.contains("circuitplayground_bluefruit")
                                    print("Returned \(cpbProjects) for circuitplayground_bluefruit")
                                    return cpbProjects
                                }
                                
                                else if boardInfoForView?.name == "Clue Nrf52840 Express" {
                                    let clueProjects = $0.compatibility.contains("clue_nrf52840_express")
                                    return clueProjects
                                }
                                else {
                                    return true
                                }
                                
                            }
                            
                            
                            ForEach(check) { demo in
                                
                                if demo.bundleLink == expandedState.currentCell {
                                    
                                    DemoViewCell(result: demo, isExpanded: true, isConnected: $inConnectedInSelectionView, deviceInfo: $boardBootInfo, onViewGeometryChanged: {
                                    })
                                    .onAppear(){
                                        print("Cell Appeared")
                                        withAnimation {
                                            scroll.scrollTo(demo.id)
                                        }
                                        
                                    }
                                    
                                } else {
                                    
                                    DemoViewCell(result: demo, isExpanded: false, isConnected: $inConnectedInSelectionView, deviceInfo: $boardBootInfo, onViewGeometryChanged: {
                                        
                                        
                                    })
                                    
                                }
                                
                            }
                            
                        }
                        
                        .id(self.scrollViewID)
                    }
                    .environmentObject(expandedState)
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
        
        .onChange(of: viewModel.connectedBoard, perform: { newValue in
            dump(newValue)
            boardInfoForView = newValue
            unknownBoardName = newValue?.name
        })
        
        .onAppear(){
            
            
            viewModel.setup(fileTransferClient:connectionManager.selectedClient)
            
            connectionManager.isSelectedPeripheralReconnecting = true
            
            viewModel.readFile(filename: "boot_out.txt")
            
        }
        
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}
