//
//  MainSelectionDetailView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 10/16/21.
//

import SwiftUI

struct MainSelectionDetailView: View {
    var project: Project

    @EnvironmentObject var rootViewModel: RootViewModel
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    init(project: Project) {
        self.project = project
    }


    
    var body: some View {
        
        VStack {
            
            Form {
               
                Section{
                    
                    VStack(alignment: .leading){
                        
                        HStack{
                            
                            ZStack {
                                
                                Rectangle()
                                    .frame(width: 22, height: 22, alignment: .center)
                                    .cornerRadius(5.0)
                                    .foregroundColor(Color(#colorLiteral(red: 0.2156862745, green: 0.6745098039, blue: 1, alpha: 1)))
                                
                                Image("logo")
                                    .resizable(resizingMode: .stretch)
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20, alignment: .center)
                            }
                            
                            
                            Text(project.device)
                                .font(.caption)
                                .fontWeight(.light)
                                .foregroundColor(.gray)
                                .font(.title)
                            
                            
                            Spacer()
                            
                        }
                        
                        Text(project.title)
                            .fontWeight(.semibold)
                        Divider()
                        
                        Text("""
                            \(project.description)
                            """)
                            .fontWeight(.medium)
                            .font(.footnote)
                            .multilineTextAlignment(.leading)

                    }
                    
                }
                
                Section{
                    Button(action: {
                        ProjectState.shared.projectSingleton = project
                        rootViewModel.goToMainSelection()
                        
                        self.mode.wrappedValue.dismiss()
                        rootViewModel.goToMain()
                        
                    }, label: {
                        Text("Connect to device")
                    })
                }
                
            }
            

            
        }
    }
}

struct MainSelectionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MainSelectionDetailView(project: CPBProjects.cpbInRainbowsProj)
    }
}
