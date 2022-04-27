//
//  MainSelectionView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 10/16/21.
//

import SwiftUI
import FileTransferClient

enum AdafruitDevices {
    case clue_nrf52840_express
    case circuitplayground_bluefruit
}

struct MainSelectionView: View {
    
    
    
    @State private var showWebViewPopover: Bool = false
    @ObservedObject var model = NetworkService()
    @EnvironmentObject var rootViewModel: RootViewModel
    @State private var isConnected = false
    
    @State private var test = ""
    
    var body: some View {
        
        
            
            VStack {
                
                HeaderView()
               
                ScrollView {
                    SubHeaderView()

                    ForEach(model.pdemos) { demo in
                        DemoViewCell(result: demo, isConnected: $isConnected, bootOne: $test)
                    }
                }

            }
            .onChange(of: rootViewModel.destination) { destination in
                if destination == .fileTransfer {
                    self.rootViewModel.goToStartup()
                }
            }
        
            .onAppear(perform: {
                print("MainSelectionView")
            })
            .preferredColorScheme(.light)
            .background(Color.white)
            .navigationBarColor(UIColor(named: "pyleap_gray"))
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }




struct MainSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        MainSelectionView()
    }
}

