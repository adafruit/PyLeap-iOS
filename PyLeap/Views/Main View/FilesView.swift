//
//  FileView.swift
//  SwiftUI File Manager
//
//  Created by Trevor Beaton on 7/11/21.
//
///FileTransferView
import SwiftUI

struct FilesView: View {
    

    
    var projects: [Project] = ProjectData.projects
    
    let layout = [
        GridItem(.adaptive(minimum: 180))
    ]
    
    var columns = Array(repeating: GridItem(.flexible(), spacing:20), count: 2)
    
    @StateObject var viewModel = FileViewModel()
    
    var body: some View {
        
       
            
            VStack {
                SearchBarView()
                //MARK:- Project Grid Stack
                
                ScrollView {
                    
                    LazyVGrid(columns: layout, spacing: 20) {
                        
                        ForEach(projects,id: \.id) { item in
                            
                            ZStack {
                                
                                NavigationLink(destination: ProjectCardView(fileTransferClient: AppState.shared.fileTransferClient, project: item)) {
                                    ProjectCell(title: item.title, deviceName: item.device)
                                }
                            }
                        }
                        
                    }.ignoresSafeArea(.all)
                }
                
                .background(Color.init(red: 240/255, green: 240/255, blue: 240/255))
            }
            
            .navigationTitle("PyLeap Demo")
        }
        
    }
    
struct ContentFile: Identifiable {
    var id = UUID()
    var title: String
}


struct FileView_Previews: PreviewProvider {
    static var previews: some View {
        FilesView()
    }
}
