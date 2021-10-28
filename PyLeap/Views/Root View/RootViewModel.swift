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
        //case bluetoothConnection
        //case filesView
        case fileTransfer
        case test
        case mainSelection
    }
    
    @Published var destination: Destination = AppEnvironment.isRunningTests ? .test : .startup
    
    /*
    func goToSplash(){
        destination = .splash
    }
    */
    func goToMainSelection(){
        destination = .mainSelection
    }
    
    func goToMain(){
        // Check if we are reconnecting to a known Peripheral. If AppState.shared.fileTransferClient is not nil, no need to scan, just go to the connected screen
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
    
    /*
    func goToConnection() {
        destination = .bluetoothConnection
    }*/
    /*
    func goToFilesView() {
        destination = .filesView
    }*/
    
}

