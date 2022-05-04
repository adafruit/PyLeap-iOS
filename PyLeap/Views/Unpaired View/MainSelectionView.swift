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
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var connectionManager: FileTransferConnectionManager
    
    @State private var showWebViewPopover: Bool = false
    @ObservedObject var model = NetworkService()
    
    @State private var isConnected = false

    @State private var test = ""
    
    @State private var nilBinder = DownloadState.idle
    
    @EnvironmentObject var rootViewModel: RootViewModel
    
    var body: some View {
        // rootViewModel.goTobluetoothPairing()
        VStack(spacing: 0) {
            HeaderView()
            
            HStack(alignment: .center, spacing: 8, content: {
                Text("Not Connected to a Device.")
                    .font(Font.custom("ReadexPro-Regular", size: 16))
                Button {
                    rootViewModel.goTobluetoothPairing()
                } label: {
                    Text("Connect Now")
                        .font(Font.custom("ReadexPro-Regular", size: 16))
                        .underline()
                        .spotlight(enabled: true, title: "TEST")
                        
                }

            })
            .padding(.all, 0.0)
            .frame(maxWidth: .infinity)
            .frame(maxHeight: 40)
            .background(Color("pyleap_burg"))
            .foregroundColor(.white)
            
            ScrollView {
            
                ScrollViewReader { scroll in
                   
                   SubHeaderView()
                    
                    ForEach(model.pdemos) { demo in
                        DemoViewCell(result: demo, isConnected: $isConnected, bootOne: $test, onViewGeometryChanged: {
                            withAnimation {
                                scroll.scrollTo(demo.id)
                            }
                        }, stateBinder: $nilBinder)
                    }
                    
                }
            }

        }
        
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

