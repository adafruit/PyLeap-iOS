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

    // Data
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject private var connectionManager: FileTransferConnectionManager
    
    
    @StateObject var model = ProjectViewModel()
    @StateObject var downloadModel = DownloadViewModel()
    
    
    @State private var showDownloadButton = false
    @State private var sendLabel = "Send Bundle"
    @State private var progress : CGFloat = 0
    @State private var downloadedBundle = false
   // Download Button
    @State private var disableDownload = false
    @State private var downloadLabel = "Download Bundle"
    
    
    // Params
    //let fileTransferClient: FileTransferClient? = FileTransferConnectionManager.shared.selectedClient
    
    init(project: Project) {
        self.project = project
    }
    
    func downloadCheck(at filePath: URL){
        
        do {
            
            if FileManager.default.fileExists(atPath: filePath.path) {
                DispatchQueue.main.async {
                print("FILE AVAILABLE")
                downloadedBundle = true
               // downloadedBundle = false
               // downloadedBundle = true
                model.filesDownloaded(url: project.filePath)
                
                //model.startup(url: projects[selectedProjectIndex].filePath)
                }
            } else {
                DispatchQueue.main.async {
                print("FILE NOT AVAILABLE")
                downloadedBundle = false
                progress = 0
                }
            }
        } catch {
            print(error)
        }
        
        
    }

    let layout = [
        GridItem(.adaptive(minimum: 180))
    ]
    
    var columns = Array(repeating: GridItem(.flexible(), spacing:20), count: 2)
    
    
    var body: some View {
        
        
        
        
        ZStack {
            
            
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
                    
                    if downloadedBundle == false {
                        
                        Section {
                            Button(action: {
                                downloadModel.startDownload(urlString: project.downloadLink)
                              
                                disableDownload = true
                                downloadLabel = "Downloading..."
                                
                                print(project.downloadLink)
                                print("Download type: \(project.title)")
                            }, label: {
                                
                                    HStack {
                                        // DownloadButtonViewModel(percentage: $progress)
                                        // ProgressBar(progress: self.$progress)
                                        Text(downloadLabel)
                                            .bold()
                                            
                                            .onAppear {
                                                print("on awake: \(downloadedBundle)")
                                            }
                                        
                                            .onChange(of: downloadModel.downloadProgress) { newValue in
                                                print("Current Download Progress: \(newValue)")


                                                if newValue == 1.0 {

                                                    
                                                    downloadLabel = "Download Bundle"
                                                   // downloadedBundle = false
                                                    downloadedBundle = true
                                                    disableDownload = false
                                                    
                                                    DispatchQueue.main.async {
                                                        downloadCheck(at: project.filePath)
                                                    }
                                                    
                                                    
                                                    print("Status: \(downloadedBundle)")
                                                    print("PASS")
                                                    print("Current Download Status: \(downloadedBundle)")
                                                }

                                            }
                                            .onChange(of: downloadModel.isDownloading, perform: { value in
                                                
                                                DispatchQueue.main.async {
                                                print("Download Status: \(value)")
                                                
                                                
                                                    progress = downloadModel.downloadProgress
                                                }
                                                

                                            })

                                    }
                                    
                                    // ProgressView("Download Progress", value: downloadModel.downloadProgress, total: 1)
                                
                            })
                                
                        }
                        .disabled(disableDownload)
                        
                        
                        //Download Button
                    } else {
                        // Section 2
                        Section{
                            Button(action: {
                                if project.index == 0 {
                                    model.sendCPBRainbowFiles()
                                    print("Start Rainbow File Transfer")
                                }
                                if project.index == 1 {
                                    model.sendCPBBlinkFiles()
                                    print("Start Blink File Transfer")
                                }
                                if project.index == 2 {
                                    model.checkForDirectory()
                                    print("Start LED Glasses File Transfer")
                                }

                            }, label: {
                                Text("\(sendLabel)")
                                    .bold()
                                    .foregroundColor(.purple)
                            })

                        }
                        
                        

                        
                    }
                    
                    


                    
                    
                    
                    Section(header: Text("Files Downloaded")) {
                        List {
                            
                            ForEach(model.fileArray) { file in
                                
                                ContentFileRow(title: file.title)
                                
                            }
                        }
                        
                    }
                    
                }
                .navigationBarTitle("Project Card")
                //    .navigationBarBackButtonHidden(true)
            }
            
            
        }
        
        
        
        
        .disabled(model.transmissionProgress != nil)
        
        
        
        
        
        .onChange(of: connectionManager.selectedClient) { selectedClient in
            model.setup(fileTransferClient: selectedClient)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            
            print("View Did Load.")
            
            //  model.startup(url: projects[selectedProjectIndex].filePath)
          //  model.gatherGlassesBundle()
            model.setup(fileTransferClient: connectionManager.selectedClient)
            downloadCheck(at: project.filePath)
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

