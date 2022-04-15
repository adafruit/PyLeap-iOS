//
//  FillerView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/12/21.
//

import SwiftUI

struct FillerView: View {
    
    @StateObject private var model = StartupViewModel()
    @EnvironmentObject var rootViewModel: RootViewModel
    
    var body: some View {
        VStack {
            
            Image("pyleapLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .offset(y: -20)
            
            ProgressView()

        }
        .preferredColorScheme(.light)
        .padding(.horizontal, 20)
        .edgesIgnoringSafeArea(.all)
        .modifier(Alerts(activeAlert: $model.activeAlert, model: model))
        .onAppear {
            model.setupBluetooth()
        }
        .onChange(of: model.isStartupFinished) { isStartupFinished in
            if isStartupFinished {
                
                rootViewModel.goToMain()
            
            }
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


struct FillerView_Previews: PreviewProvider {
    static var previews: some View {
        FillerView()
    }
}
