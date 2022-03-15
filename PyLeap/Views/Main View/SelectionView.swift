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
    
    @State var projects: [Project] = []
    
    let layout = [
        GridItem(.adaptive(minimum: 180))
    ]
    
    var columns = Array(repeating: GridItem(.flexible(), spacing:20), count: 2)
    @ObservedObject var model = NetworkService()
   
    var body: some View {
        
        NavigationView {
            // Body
            VStack {

                
                ScrollView {
                    HStack {
                        
                        Text("Browse all of the available PyLeap Projects")
                            .multilineTextAlignment(/*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .font(Font.custom("ReadexPro-VariableFont_wght", size: 25))
                    }
                    .padding(.vertical,30)
                    
                    ForEach(model.pdemos) { demo in
                        DemoCell(result: demo)
                    }
                    
                    
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Image("pyleap_logo_white")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                        
                    }
                }
                
                .toolbar {
                    Button(action: {
                        print("Hello button tapped!")
                    }) {
                        Image(systemName: "list.bullet")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30, alignment: .center)
                    }                }
                
                
//                ScrollView {
//
//                    LazyVGrid(columns: layout, spacing: 20, pinnedViews: [.sectionHeaders, .sectionFooters]) {
//
//                        ForEach(projects.indices,id: \.self) { item in
//
//                            ZStack {
//
//                                NavigationLink(destination: ProjectCardView(project: self.projects[item])) {
//
//                                    ProjectCell(title: projects[item].title, deviceName: projects[item].device, image: projects[item].image)
//                                }
//
//                            }
//                        }
//
//                    }
//
//                }

            }
           
         //   .padding(10)
//            .navigationBarHidden(true)
//           // .ignoresSafeArea(.all)
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .edgesIgnoringSafeArea(.all)
//            .ignoresSafeArea(.all)
        }
        
       // .navigationBarBackButtonHidden(true)
       // .edgesIgnoringSafeArea(.all)
        //.frame(maxWidth: .infinity, maxHeight: .infinity)
        
        .onChange(of: viewModel.projects, perform: { value in
            
            DispatchQueue.main.async {
                
                projects = viewModel.projects
            }
        })
        
        .onAppear {
            
            viewModel.setup(fileTransferClient: connectionManager.selectedClient)
            viewModel.readFile(filename: "boot_out.txt")
            
        }
        .onDisappear {
            
        }
        
    }
    
}

struct FileView_Previews: PreviewProvider {
    static var previews: some View {
        SelectionView()
    }
}
