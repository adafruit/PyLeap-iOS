//
//  MainSelectionView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 10/16/21.
//

import SwiftUI
import FileTransferClient


struct MainSelectionView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var connectionManager: FileTransferConnectionManager
    
    var projects: [Project] = CPBProjects.projects
    var clueProjects: [Project] = CPBProjects.clueProjects
    var cpbProjects: [Project] = CPBProjects.cpbDemos
    
    
    @State private var showWebViewPopover: Bool = false
    @ObservedObject var model = NetworkService()
    
    let layout = [
        GridItem(.adaptive(minimum: 180))
    ]
    
    var columns = Array(repeating: GridItem(.flexible(), spacing:20), count: 2)
    
    
    
    //    func readFile() {
    //     if let url = Bundle.main.url(forResource: "PyLeapProjects", withExtension: "json"),
    //
    //           let data = try? Data(contentsOf: url) {
    //
    //         let decoder = JSONDecoder()
    //
    //         if let jsonData = try? decoder.decode(RootResults.self, from: data) {
    //
    //             self.proj = jsonData.projects
    //       }
    //     }
    //   }
    //
    
    
    
    let grayColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    
    var body: some View {
        
        VStack{
            
            
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
                .onAppear {
                    print(model.pdemos.count)
                }
                // .animation(.linear)
                
                
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
        }
        .background(Color.white)
        .navigationBarColor(grayColor)
        .navigationBarTitleDisplayMode(.inline)
        
        //            ScrollView {
        //
        //                LazyVGrid(columns: layout, spacing: 20, pinnedViews: [.sectionHeaders]) {
        //
        //                    Section(header:
        //                                HStack {
        //                        Text("Adafruit CLUE")
        //                            .padding(2)
        //
        //
        //                        Spacer()}) {
        //
        //
        //                            List(model.pdemos) { demo in
        //                               // ProjectCell(title: model.pdemos[demo].project_name)
        //                            }
        //
        ////                            **MAIN
        ////                            ForEach(clueProjects.indices,id: \.self) { item in
        ////
        ////                            ZStack {
        ////
        ////                                NavigationLink(destination: MainSelectionDetailView(project: self.clueProjects[item])) {
        ////                                    ProjectCell(title: clueProjects[item].title, deviceName: clueProjects[item].device, image: clueProjects[item].image)
        ////                                }
        ////
        ////                            }
        ////                        }
        //                    }
        //
        //
        //
        //
        //
        ////                    Section(header:
        ////                                HStack {
        ////                        Text("Circuit Playground Bluefruit")
        ////                            .padding(2)
        ////
        ////
        ////                        Spacer()}
        ////                                ) {
        ////                        ForEach(cpbProjects.indices,id: \.self) { item in
        ////
        ////                            ZStack {
        ////
        ////                                NavigationLink(destination: MainSelectionDetailView(project: self.cpbProjects[item])) {
        ////                                    ProjectCell(title: cpbProjects[item].title, deviceName: cpbProjects[item].device, image: cpbProjects[item].image)
        ////                                }
        ////
        ////                            }
        ////                        }
        ////                    }
        //
        //
        //
        //
        //
        //
        //                }
        //            }
    }
}


struct MainSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        MainSelectionView()
    }
}

