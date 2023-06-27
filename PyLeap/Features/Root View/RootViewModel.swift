//
//  RootViewModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 6/30/21.
//

import Foundation
import FileTransferClient

public class RootViewModel: ObservableObject {

  //  public var shared = RootViewModel()
    
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
        case bleSettings
        case mainSelection
        case wifiSelection
        case wifiPairingTutorial
        case wifiServiceSelection
        case selection
        
    }
    
    @Published var destination: Destination = AppEnvironment.isRunningTests ? .mainSelection : .startup
    
    
    func goToTest(){
        //destination = .test
    }
    
    func goToWiFiServiceSelection() {
        destination = .wifiServiceSelection
    }
    
    func goToWifiPairingTutorial() {
        destination = .wifiPairingTutorial
    }
    
    func goToWiFiSelection() {
        destination = .wifiServiceSelection
    }
    
    func goToWifiView() {
        destination = .wifi
    }
    
    func goTobluetoothPairing() {
        destination = .bluetoothPairing
    }
    
    func goToSelection(){
        destination = .selection
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
    
    func backToMain() {
        destination = .main
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
    
    func goToSettings(content: SettingState){
        destination = .settings
    }
    
    func goToBLESettings(){
        destination = .bleSettings
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

