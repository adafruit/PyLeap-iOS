
//  BluetoothStatusView.swift
//  Glider
//
//  Created by Antonio García on 7/9/21.
//

import SwiftUI
import FileTransferClient

struct BluetoothStatusView: View {
    @State private var messageTitle: String
    @State private var message: String
    @State private var isActionHidden: Bool
    @StateObject private var model = BTConnectionViewModel()
    @EnvironmentObject var rootViewModel: RootViewModel
    
    init() {
        
        let bluetoothState = BleManager.shared.state
        
        var isActionHidden: Bool
        
        switch bluetoothState {
        
        case .unauthorized:
            messageTitle = "This app is not authorized to use Bluetooth Low Energy"
            message = "Bluetooth permission should be granted for the app to connect to a Bluetooth device"
            isActionHidden = false
        case .unsupported:
            messageTitle = "This device doesn't support Bluetooth"
            message = "Bluetooth support and specifically Bluetooth Low Energy support is needed to communicate with a Bluefruit Device"
            isActionHidden = true
        case .poweredOff:
            messageTitle = "Bluetooth is currently powered off"
            message = "Bluetooth should be enabled on your device for the app to connect to a Bluetooth device"
            isActionHidden = true
        default:
            DLog("Error: BluetoothStatusView in wrong state: \(bluetoothState)")
            messageTitle = "Bluetooth is not available"
            message = "Bluetooth should be enabled on your device for the app to connect to a Bluetooth device"
            isActionHidden = true
            break
        }
        
        let settingsUrl = URL(string: UIApplication.openSettingsURLString)
        self.isActionHidden = isActionHidden || settingsUrl == nil || !UIApplication.shared.canOpenURL(settingsUrl!)
    }
    
    var body: some View {
        
        VStack(spacing: 30) {
            Image("bluetooth")
            
            VStack(spacing: 16) {
                Text(messageTitle).bold()
                Text(message)
            }
            .font(Font.custom("ReadexPro-Regular", size: 20))
           
            Button("Bluetooth permissions") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            // .buttonStyle(MainButtonStyle())
            .opacity(isActionHidden ? 0 : 1)
        }
        
        .onChange(of: model.destination) { destination in
            if destination == .fileTransfer {
                self.rootViewModel.goToFileTransfer()
            }
        }
        .padding(.horizontal)
        .multilineTextAlignment(.center)
        .foregroundColor(.gray)
        .edgesIgnoringSafeArea(.all)

    }
       
}

struct BluetoothStatusView_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothStatusView()
    }
}
