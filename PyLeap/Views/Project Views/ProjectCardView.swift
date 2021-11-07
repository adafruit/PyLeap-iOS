//
//  ProjectCardView.swift
//  SwiftUI File Manager
//
//  Created by Trevor Beaton on 8/2/21.
//

import SwiftUI
import FileTransferClient

struct ProjectCardView: View {
    
    var project: Project
    //@AppStorage("onboarding") var onboardingSeen = false
    
    @AppStorage("index") var selectedProjectIndex = 0
    
    @AppStorage("LED") var selectedLEDIndex = 0
    
    @AppStorage("selection") var showSelection = true
    // Data
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var connectionManager: FileTransferConnectionManager
    
    
    @StateObject var model = ProjectViewModel()
    @StateObject var downloadModel = DownloadViewModel()
    
    
    @State private var showDownloadButton = false
    @State private var sendLabel = "Send Bundle"
    
    @State private var progress : CGFloat = 0
    
    
    @State private var downloadedBundle = false
    // Params
    //let fileTransferClient: FileTransferClient? = FileTransferConnectionManager.shared.selectedClient
    
    init(project: Project) {
        self.project = project
    }
    
    
    
    func downloadCheck(at filePath: URL){
        
        do {
            
            if FileManager.default.fileExists(atPath: filePath.path) {
                print("FILE AVAILABLE")
               // downloadedBundle = true
                downloadedBundle = false
                downloadedBundle = true
                model.filesDownloaded(url: projects[selectedProjectIndex].filePath)
                
                //model.startup(url: projects[selectedProjectIndex].filePath)
                
            } else {
                print("FILE NOT AVAILABLE")
                downloadedBundle = false
                progress = 0
            }
        } catch {
            print(error)
        }
        
        
    }
    
    
    var projectNames = ["Glide on over some rainbows!","Blink!", "LED Glasses", "Hello World"]
    
    let projectArray = ProjectData.projects
    var projects: [Project] = ProjectData.projects
    
    let layout = [
        GridItem(.adaptive(minimum: 180))
    ]
    
    var columns = Array(repeating: GridItem(.flexible(), spacing:20), count: 2)
    
    
    var body: some View {
        NavigationView {
            
            
            
            ZStack {
                
                if showSelection == true {
                    
                    ScrollView {
                      
                        LazyVGrid(columns: layout, spacing: 20) {
                            
                            ForEach(projects.indices,id: \.self) { item in
                                
                                ZStack {
                                  
                                    Button {
                                        selectedProjectIndex = projects[item].index
                                        
                                        downloadCheck(at: projects[selectedProjectIndex].filePath)
                                        showSelection.toggle()
                                        
                                    } label: {
                                        
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
                    
                } else {
                    
                    
                    VStack {
                        
                        Form {
                            
                            // Section 2
                            Section {
                                
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
                                        
                                        
                                        Text(projectArray[selectedProjectIndex].device)
                                            .font(.caption)
                                            .fontWeight(.light)
                                            .foregroundColor(.gray)
                                            .font(.title)
                                        
                                        
                                        Spacer()
                                        
                                    }
                                    
                                    
                                    
                                    
                                    Text(projectArray[selectedProjectIndex].title)
                                        .fontWeight(.semibold)
                                    Divider()
                                    
                                    Text("""
                                    \(projectArray[selectedProjectIndex].description)
                                    """)
                                        .fontWeight(.medium)
                                        .font(.footnote)
                                        .multilineTextAlignment(.leading)
                                    
                                }
                            }
                            
                            if downloadedBundle == false {
                     
                                Section{
                                    Button(action: {
                                        downloadModel.startDownload(urlString: projectArray[selectedProjectIndex].downloadLink)
                                        
                                        print(projectArray[selectedProjectIndex].downloadLink)
                                        print("Download type: \(projectArray[selectedProjectIndex].title)")
                                    }, label: {
                                        VStack{
                                        HStack {
                                            //DownloadButtonViewModel(percentage: $progress)
                                          //  ProgressBar(progress: self.$progress)
                                            Text("Download Project Bundle")
                                                .bold()
                                                .onChange(of: downloadModel.downloadProgress, perform: { value in
                                                   
                                                    print("pro: \(progress)")
                                                    print("NEW VALUE: \(value)")
                                                    
                                                    DispatchQueue.main.async {
                                                        progress = downloadModel.downloadProgress
                                                    }
                                                    
                                                    if value == 1.0 {
                                                        downloadedBundle = false
                                                        downloadedBundle = true
                                                       // downloadCheck(at: projects[selectedProjectIndex].filePath)
                                                        print("PASS")
                                                        print("Current Download Status: \(downloadedBundle)")
                                                    }
                                                    
                                                    
                                                })
                                            
                                        }
                                        
                                           // ProgressView("Download Progress", value: downloadModel.downloadProgress, total: 1)
                                    }
                                    })
                                    
                                }
                                .onAppear {
                                    print("on awake: \(downloadedBundle)")
                                }
                                
                                
                                //Download Button
                            } else {

                            }
                            
                            // Section 2
                            Section{
                                Button(action: {
                                    if selectedProjectIndex == 0 {
                                        model.sendCPBRainbowFiles()
                                        print("Start Rainbow File Transfer")
                                    }
                                    if selectedProjectIndex == 1 {
                                        model.sendCPBBlinkFiles()
                                        print("Start Blink File Transfer")
                                    }
                                    if selectedProjectIndex == 2 {
                                        model.checkForDirectory()
                                        print("Start LED Glasses File Transfer")
                                    }
                                    
                                }, label: {
                                    Text("\(sendLabel)")
                                        .bold()
                                        .foregroundColor(.purple)
                                })
                                
                            }
                            
                            if downloadedBundle == true {

                                Section(header: Text("Files Downloaded")) {
                                    List {

                                        ForEach(model.fileArray) { file in

                                            ContentFileRow(title: file.title)

                                        }
                                    }
                                }

                            } else {

                            }
                            
                        }
                    }
                    
                    .navigationBarTitle("Project Card")
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            
                            Button("Back") {
                               // downloadedBundle = false
                                showSelection.toggle()
                            }
                        }
                    }
                }
            }
            
            .disabled(model.transmissionProgress != nil)
            
            
            
        }

        .onChange(of: connectionManager.selectedClient) { selectedClient in
            model.setup(fileTransferClient: selectedClient)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            
            print("View Did Load.")
            
          //  model.startup(url: projects[selectedProjectIndex].filePath)
            model.gatherGlassesBundle()
            model.setup(fileTransferClient: connectionManager.selectedClient)
            downloadCheck(at: projects[selectedProjectIndex].filePath)
        }
    }
}


struct ContentFileRow: View {
    let title : String
    
    var body: some View {
        Label(
            title: { Text(title) },
            icon: { Image(systemName: "doc.text") })
    }
}



struct ProjectCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectCardView(project: ProjectData.projects.first!)
    }
}

