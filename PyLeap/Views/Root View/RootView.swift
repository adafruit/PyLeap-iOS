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
    @ObservedObject var connectionManager = FileTransferConnectionManager.shared
    @AppStorage("onboarding") var onboardingSeen = true
    
    var data = OnboardingDataModel.data
    @State var isReconnecting = false
    
    var body: some View {
        
        Group{
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
                
            case .wifi:
                WifiView()
                
            case .settings:
                SettingsView()
            default:
                FillerView()
            }
        }
        
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
            
            if isConnectedOrReconnecting, model.destination == .fileTransfer {
                model.destination = .fileTransfer
                isReconnecting = true
                
            } else {
                isReconnecting = false
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
    }
}


