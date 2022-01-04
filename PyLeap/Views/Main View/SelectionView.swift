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
    
    
    var projects: [Project] = ProjectData.projects
    
    let layout = [
        GridItem(.adaptive(minimum: 180))
    ]
    
    var columns = Array(repeating: GridItem(.flexible(), spacing:20), count: 2)
    
    @StateObject var viewModel = SelectionViewModel()
    
    
    var body: some View {
       
        NavigationView {
            
            
            VStack {
                
                ScrollView {
                    
                    LazyVGrid(columns: layout, spacing: 20) {
                        
                        ForEach(projects.indices,id: \.self) { item in
                            
                            ZStack {
                                
                                NavigationLink(destination: ProjectCardView(project: self.projects[item])) {
                                    
                                    ProjectCell(title: projects[item].title, deviceName: projects[item].device, image: projects[item].image)
                                }
                                
                            }
                        }
                        
                    }
                    .navigationBarBackButtonHidden(true)
                    .ignoresSafeArea(.all)
                    
                }
                .padding(.top,20)
                .navigationBarTitle("PyLeap")
                
            }
            
        }
        .preferredColorScheme(.dark)
        
        .onAppear {
            
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
