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
    @ObservedObject private var connectionManager = FileTransferConnectionManager.shared
    @AppStorage("onboarding") var onboardingSeen = true
    
    var data = OnboardingDataModel.data

    @State private var isBTConnectVisible = false
    
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
                
            case .main:
                BTConnectionView()

            case .fileTransfer:
                SelectionView()
                
            default:
                FillerView()
            }
        }
        .onChange(of: connectionManager.isConnectedOrReconnecting) { isConnectedOrReconnecting in
            
            if !isConnectedOrReconnecting, model.destination == .fileTransfer {
                model.destination = .main
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            DLog("App moving to the foreground. Force reconnect")
            FileTransferConnectionManager.shared.reconnect()
        }
        .environmentObject(model)
        .environmentObject(connectionManager)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea(.all)
    }
}



extension NSNotification {
    static let fileSent = Notification.Name.init("fileSent")
}
