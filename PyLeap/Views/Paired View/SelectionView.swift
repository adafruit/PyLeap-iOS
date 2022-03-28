//
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
   
    @State private var isConnected = true
    
    var body: some View {
        
        NavigationView {
            VStack {
                ScrollView {
                    HStack {
                        Text("Browse all of the available PyLeap Projects")
                            .multilineTextAlignment(/*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .font(Font.custom("ReadexPro-Regular", size: 25))
                    }
                    .padding(.vertical,30)
                    
                    ForEach(model.pdemos) { demo in
                        DemoViewCell(result: demo, isConnected: $isConnected)
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
        .onAppear {
            viewModel.setup(fileTransferClient: connectionManager.selectedClient)
            viewModel.readFile(filename: "boot_out.txt")
        }
    }
}

struct FileView_Previews: PreviewProvider {
    static var previews: some View {
        SelectionView()
    }
}
