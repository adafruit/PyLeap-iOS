//
//  RootViewModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 6/30/21.
//

import Foundation
import FileTransferClient

class RootViewModel: ObservableObject {
    
    enum Destination {
        //case splash
        case main
        case startup
        case onboard
        case bluetoothPairing
        case bluetoothStatus
        case fileTransfer
        case wifi
        case settings
        case mainSelection
    }
    
    @Published var destination: Destination = AppEnvironment.isRunningTests ? .mainSelection : .startup
    
    
    func goToTest(){
        //destination = .test
    }
    
    func goToWifiView() {
        destination = .wifi
    }
    
    func goTobluetoothPairing() {
        destination = .bluetoothPairing
    }
    
    func goToMainSelection(){
        destination = .mainSelection
    }
    
    func goToMain(){

        if FileTransferConnectionManager.shared.selectedClient != nil {
            destination = .fileTransfer
        }
        else {
            destination = .main
        }
    }
    
    func goToStartup(){
        destination = .startup
    }
    
    func goToOnboarding() {
        destination = .onboard
    }
    
    func goToFileTransfer() {
        destination = .fileTransfer
    }
    
    func goToSettings(){
        destination = .settings
    }
    
    func showWarningIfBluetoothStateIsNotReady() {
        let bluetoothState = BleManager.shared.state
        let shouldShowBluetoothDialog = bluetoothState == .poweredOff || bluetoothState == .unsupported || bluetoothState == .unauthorized
        
        if shouldShowBluetoothDialog {
            destination = .bluetoothStatus
        }
        else if destination == .bluetoothStatus {
            goToStartup()
        }
    }
    
    
    
}

