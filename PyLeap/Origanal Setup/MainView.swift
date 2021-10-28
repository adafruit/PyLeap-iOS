//
//  MainView.swift
//  Glider
//
//  Created by Antonio García on 14/5/21.
//

/*
import SwiftUI

struct MainView: View {
    @State private var isAutoConnectVisible = false

    
    var body: some View {
        NavigationView {
            ZStack {
                BTConnectionView(isVisible: $isAutoConnectVisible)
            }
            .onAppear {
                print("Main View Appeared.")
                // onAppear doesnt work on navigationItem so pass the onAppear/onDissapear via a binding variable: https://developer.apple.com/forums/thread/655338
                DispatchQueue.main.async {
                    isAutoConnectVisible = true
                }
            }
            .onDisappear() {
                DispatchQueue.main.async {
                    isAutoConnectVisible = false
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())

    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

*/
