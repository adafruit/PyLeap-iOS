//
//  FileView.swift
//  SwiftUI File Manager
//
//  Created by Trevor Beaton on 7/11/21.
//
///FileTransferView
import SwiftUI

struct SelectionView: View {
    
    
    
    var projects: [Project] = ProjectData.projects
    
    let layout = [
        GridItem(.adaptive(minimum: 180))
    ]
    
    var columns = Array(repeating: GridItem(.flexible(), spacing:20), count: 2)
    let fileTransferClient: FileTransferClient?
    @StateObject var viewModel = SelectionViewModel()
    
    init(fileTransferClient: FileTransferClient?){
        self.fileTransferClient = fileTransferClient
    }
    
    var body: some View {
        
        
        
        VStack {
          //  SearchBarView()
            //MARK:- Project Grid Stack
            
            ScrollView {
                
                LazyVGrid(columns: layout, spacing: 20) {
                    
                    ForEach(projects.indices,id: \.self) { item in
                        
                        ZStack {
                            
                            NavigationLink(destination: ProjectCardView(fileTransferClient: AppState.shared.fileTransferClient,project: self.projects[item])) {
                                ProjectCell(title: projects[item].title, deviceName: projects[item].device)
                            }
                            
                        }
                    }
                    
                }.ignoresSafeArea(.all)
            }
                
            .background(Color.init(red: 240/255, green: 240/255, blue: 240/255))
        }
        .onAppear {
            viewModel.onAppear(fileTransferClient: fileTransferClient)
            viewModel.startup()
           
            if fileTransferClient == nil {
                print("FileTransfer is nil")
            }
        }
        .onDisappear {
            print("Selection - on disappear")
            viewModel.onDissapear()
            
        }
        .navigationTitle("PyLeap")

    }
    
}

struct ContentFile: Identifiable {
    var id = UUID()
    var title: String
}


struct FileView_Previews: PreviewProvider {
    static var previews: some View {
        SelectionView(fileTransferClient: nil)
    }
}
