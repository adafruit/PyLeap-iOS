//
//  RootView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 6/30/21.
//

import SwiftUI
import FileTransferClient

struct RootView: View {
    
    @StateObject private var model = RootViewModel()
    @StateObject var currentCellID = ExpandedState()
    @ObservedObject var connectionManager = FileTransferConnectionManager.shared
    @AppStorage("onboarding") var onboardingSeen = true
    
    var data = OnboardingDataModel.data
    @State var isReconnecting = false
    
    var body: some View {
        
        Group {
            switch model.destination {
            
            case .onboard :
                OnboardingViewPure(data: data, doneFunction: {
                    onboardingSeen = true
                    print("Onboarding Completed.")
                })
            
            case .startup:
                FillerView()
                
            case .bluetoothPairing:
                BTConnectionView()
                
            case .bluetoothStatus:
                BluetoothStatusView()
                
            case .main:
                MainSelectionView()

            case .fileTransfer:
                BleModuleView()
                
            case .wifiServiceSelection:
                WifiServiceSelectionView()
                
            case .wifi:
                WifiView()
                    
                
            case .selection:
                SelectionView()
                
            case .wifiSelection:
                WifiSelection()
                
            case .wifiPairingTutorial:
                WifiPairingView()
                
            case .settings:
                SettingsView()
            default:
                FillerView()
            }
                
        }
        .environmentObject(currentCellID)
    
        
        
        .onReceive(NotificationCenter.default.publisher(for: .didUpdateBleState)) { notification in
            if !Config.isSimulatingBluetooth {
                model.showWarningIfBluetoothStateIsNotReady()
            }
        }
        
        .onChange(of: connectionManager.isConnectedOrReconnecting) { isConnectedOrReconnecting in
            
            if !isConnectedOrReconnecting, model.destination == .fileTransfer {
                model.destination = .bluetoothPairing
            }
        }
        
        .onChange(of: connectionManager.isSelectedPeripheralReconnecting) { isConnectedOrReconnecting in
            print("😡")
            
            if isConnectedOrReconnecting, model.destination == .fileTransfer {
                model.destination = .fileTransfer
                isReconnecting = true

            } else {
                isReconnecting = false
            }
            
        }
        
        .onChange(of: connectionManager.isDisconnectingFromCurrent) { isDisconnected in

            if isDisconnected {
                print("Is disconnected.")
                isReconnecting = false
                connectionManager.clearAllPeripheralInfo()
                connectionManager.peripherals = []
                connectionManager.isDisconnectingFromCurrent = false
                model.destination = .selection
            }
            
        }
        
        
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            DLog("App moving to the foreground. Force reconnect")
            FileTransferConnectionManager.shared.reconnect()
        }
        
        .environmentObject(model)
        .environmentObject(connectionManager)
        .background(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea(.all)
        .preferredColorScheme(.light)
        .statusBar(hidden: true)
    }
}


