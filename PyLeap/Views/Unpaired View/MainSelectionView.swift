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
    @State var test: String = "x"
    
    
    var body: some View {
        
        VStack{
            
            ScrollView {
                
                HStack {
                    
                    Text("Browse all of the available PyLeap Projects")
                        .multilineTextAlignment(/*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .font(Font.custom("ReadexPro-Regular", size: 25))
                }
                .padding(.vertical,30)
                
                ForEach(model.pdemos) { demo in
                    DemoViewCell(result: demo, isConnected: $isConnected, newerTest: test)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("pyleap_logo_white")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .offset(y: -10)
                    
                }
            }
            
//            .toolbar {
//                Button(action: {
//                    print("Hello button tapped!")
//                }) {
//                    Image(systemName: "list.bullet")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 30, height: 30, alignment: .center)
//                }                }
        }
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

