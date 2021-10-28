//
//  MainSelectionView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 10/16/21.
//

import SwiftUI

struct MainSelectionView: View {
    
    var projects: [Project] = ProjectData.projects
    
    let layout = [
        GridItem(.adaptive(minimum: 180))
    ]
    
    var columns = Array(repeating: GridItem(.flexible(), spacing:20), count: 2)
    
    
    var body: some View {
        
        VStack{
            ScrollView {
                
                LazyVGrid(columns: layout, spacing: 20) {
                    
                    ForEach(projects.indices,id: \.self) { item in
                        
                        ZStack {
                            
                            NavigationLink(destination: ProjectCardView(project: self.projects[item])) {
                                ProjectCell(title: projects[item].title, deviceName: projects[item].device, image: projects[item].image)
                            }
                            
                        }
                    }
                    
                }.ignoresSafeArea(.all)
            }
            .background(Color.init(red: 240/255, green: 240/255, blue: 240/255))
        }
        
        
        
    }
}

struct MainSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        MainSelectionView()
    }
}
    
