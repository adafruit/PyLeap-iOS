//
//  RootView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 6/30/21.
//

import SwiftUI

struct RootView: View {
    
    @StateObject private var model = RootViewModel()
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
                StartupView()
                
            case .main:
                MainView()

            default:
                FillerView()
            }
        }
        .environmentObject(model)
        .edgesIgnoringSafeArea(.all)
//        .onAppear {
//           print("Root View Appeared.")
//            isBTConnectVisible = true
//
//        }

    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}

extension NSNotification {
    static let fileSent = Notification.Name.init("fileSent")
}
