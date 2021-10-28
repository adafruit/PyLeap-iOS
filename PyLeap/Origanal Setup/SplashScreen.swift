//
//  SplashScreen.swift
//  PyLeap
//
//  Created by Trevor Beaton on 6/30/21.
//

/*
import SwiftUI

struct SplashScreen: View {
    
    @StateObject private var model = SplashViewModel()
    @EnvironmentObject var rootViewModel: RootViewModel
    
    @AppStorage("onboarding") var onboardingSeen = false
    
    var body: some View {
        
        ZStack{
            
            VStack{
                
                Image("pyleapLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .offset(y: -20)
            }
            .padding(.horizontal, 20)
            .modifier(StartupAlerts(model: model))
            .onAppear {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    
                    if onboardingSeen == true {
                        
                        rootViewModel.goToStartup()
                        print("Onboarding: \(onboardingSeen)")
                    } else {
                        rootViewModel.goToOnboarding()
                    }
                }
            }
        }
        .onAppear {
            print("Splash View Appeared.")
            model.setupBluetooth()
        }
        .onChange(of: model.isStartupFinished) { isStartupFinished in
            if isStartupFinished {
                
                rootViewModel.goToMain()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}


private struct StartupAlerts: ViewModifier {
    @ObservedObject var model: SplashViewModel
    
    private var isAlertPresented: Binding<Bool> { Binding(
        get: { self.model.activeAlert.isActive },
        set: { if !$0 { self.model.activeAlert.setInactive() } }
    )
    }
    
    func body(content: Content) -> some View {
        content
            .alert(isPresented: isAlertPresented, content: {
                switch model.activeAlert {
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
                    
                case .none:
                    return Alert(title: Text("undefined"))
                }
            })
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
*/
