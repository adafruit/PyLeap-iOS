// ;}
//  FileView.swift
//  SwiftUI File Manager
//
//  Created by Trevor Beaton on 7/11/21.
//
///FileTransferView
import SwiftUI
import FileTransferClient

struct SelectionView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var connectionManager: FileTransferConnectionManager
    @StateObject var viewModel = SelectionViewModel()
    @ObservedObject var model = NetworkService()
    @StateObject var globalString = GlobalString()
    
    
  /*
   need to know what device is paired.
   
   */
    
    @State private var boardBootInfo = ""
    
    
    @State private var inConnectedInSelectionView = true
    
    var body: some View {
        
        NavigationView {
            VStack {
                
//                Group {
//                    Button {
//                        viewModel.removeAllFiles()
//                    } label: {
//                        Text("Delete")
//                            .foregroundColor(Color.red)
//                    }
//
//                    Button {
//                        viewModel.listDirectory(filename: "")
//                        viewModel.listDirectory(filename: "lib/")
//                    } label: {
//                        Text("List files on disk")
//                            .foregroundColor(Color.blue)
//                    }
//                }
//                .font(Font.custom("ReadexPro-Regular", size: 25))
//                .padding(5)
                
                
                
                ScrollView {
                    
                    
                    
                    HStack {
                        Text("Browse all of the available PyLeap Projects")
                            .multilineTextAlignment(/*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .font(Font.custom("ReadexPro-Regular", size: 25))
                    }
                    .padding(.vertical,30)
                    
                    ForEach(model.pdemos) { demo in
                        DemoViewCell(result: demo, isConnected: $inConnectedInSelectionView, bootOne: $boardBootInfo)

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
            }
            .background(Color.white)
            .navigationBarColor(UIColor(named: "pyleap_gray"))
            .navigationBarTitleDisplayMode(.inline)
            
        }
        
        .environmentObject(globalString)
        
        
        
        
        .onChange(of: viewModel.sendingBundle, perform: { newValue in
            globalString.isSendingG = newValue
            print("Is Sending? = \(newValue)")
        })
        
        .onChange(of: viewModel.numOfFiles, perform: { newValue in
            globalString.numberOfFilesG = newValue
            print("NumOfFiles: \(newValue)")
        })
        
        .onChange(of: viewModel.counter, perform: { newValue in
            globalString.counterG = newValue

        })
        
        .onChange(of: viewModel.bootUpInfo, perform: { newValue in
            viewModel.readMyStatus()
            print("newValue \(newValue)")
            boardBootInfo = newValue
        })
        
        .onChange(of: globalString.projectString, perform: { newValue in
            viewModel.getProjectURL(nameOf: newValue)

        })
        
        .onChange(of: connectionManager.selectedClient) { selectedClient in
            viewModel.setup(fileTransferClient: selectedClient)
        }
        .onAppear {
            viewModel.setup(fileTransferClient: connectionManager.selectedClient)
            viewModel.readFile(filename: "boot_out.txt")
            
          
        }
    }
}


