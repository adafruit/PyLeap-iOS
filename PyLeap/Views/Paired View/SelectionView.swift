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
                
                Group {
                Button {
                    viewModel.removeAllFiles()
                } label: {
                    Text("Delete")
                        .foregroundColor(Color.red)
                }

                Button {
                    viewModel.listDirectory(filename: "")
                    viewModel.listDirectory(filename: "lib/")
                } label: {
                    Text("List files on disk")
                        .foregroundColor(Color.blue)
                }
                }
                .font(Font.custom("ReadexPro-Regular", size: 25))
                .padding(5)
                
                
                
                ScrollView {
                    HStack {
                        Text("Browse all of the available PyLeap Projects")
                            .multilineTextAlignment(/*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .font(Font.custom("ReadexPro-Regular", size: 25))
                    }
                    .padding(.vertical,30)
                    
                    ForEach(model.pdemos) { demo in
                        DemoViewCell(result: demo, isConnected: $isConnected)
                       
                        
                        
                        
                        Button(action: {
                            //Uses the Project name to locate the path of the downloaded bundle.
                            
                            viewModel.filesDownloaded(projectName: demo.projectName)
                            print(demo.projectName)
                        }) {
                            Text("File Transfer")
                                .font(.custom("ReadexPro-Regular", size: 25))
                                .foregroundColor(Color("pyleap_purple"))
                                .padding(.leading, 60)
                                .padding(.trailing, 60)
                                .frame(height: 50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke((Color("pyleap_purple")), lineWidth: 3.5))
                        }
                        
                        
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
        .onChange(of: connectionManager.selectedClient) { selectedClient in
            viewModel.setup(fileTransferClient: selectedClient)
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
