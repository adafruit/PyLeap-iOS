//
//  StartupView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 7/25/21.
//

import SwiftUI

struct StartupView: View {
    
    @StateObject private var model = StartupViewModel()
    @EnvironmentObject var rootViewModel: RootViewModel
    @AppStorage("onboarding") var onboardingSeen = false
    
    var body: some View {
        VStack {
            Text("Restoring Connection...")
                .bold()
                .foregroundColor(Color.purple)
            
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
        }
        .modifier(Alerts(activeAlert: $model.activeAlert, model: model))
        .onAppear {
            print("Startup View Appeared.")
            model.setupBluetooth()
        }
        .onChange(of: model.isStartupFinished) { isStartupFinished in
            if isStartupFinished {
                rootViewModel.goToMain()
            }
        }
    }
    
    
    private struct Alerts: ViewModifier {
        @Binding var activeAlert: StartupViewModel.ActiveAlert?
        @ObservedObject var model: StartupViewModel
        
        func body(content: Content) -> some View {
            content
                .alert(item: $activeAlert, content:  { alert in
                    switch alert {
                    case .bluetoothUnsupported:
                        return Alert(
                            title: Text("Error"),
                            message: Text("This device doesn't support Bluetooth Low Energy which is needed to connect to Bluefruit devices"),
                            dismissButton: .cancel(Text("Ok")) {
                                model.setupBluetooth()
                            })
                        
                    case .fileTransferErrorOnReconnect:
                        return Alert(
                            title: Text("Error"),
                            message: Text("Error initializing FileTransfer service"),
                            dismissButton: .cancel(Text("Ok")) {
                                model.setupBluetooth()
                            })
                    }
                })
        }
    }
    
}

struct StartupView_Previews: PreviewProvider {
    static var previews: some View {
        StartupView()
            .environmentObject(RootViewModel())
    }
}
