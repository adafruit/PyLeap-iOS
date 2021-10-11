//
//  RootViewModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 6/30/21.
//

import Foundation

class RootViewModel: ObservableObject {
    
    enum Destination {
        case splash
        case main
        case startup
        case onboard
        case bluetoothConnection
        case filesView
        case fileTransfer
        case test
    }
    
    @Published var destination: Destination = AppEnvironment.isRunningTests ? .test : .startup
    
    
    func goToSplash(){
        destination = .splash
    }
    
    func goToMain(){
        destination = .main
    }
    
    func goToStartup(){
        destination = .startup
    }
    
    func goToOnboarding() {
        destination = .onboard
    }
    
    func goToConnection() {
        destination = .bluetoothConnection
    }
    
    func goToFilesView() {
        destination = .filesView
    }
    
}

