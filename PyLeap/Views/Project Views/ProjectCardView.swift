//
//  ProjectCardView.swift
//  SwiftUI File Manager
//
//  Created by Trevor Beaton on 8/2/21.
//

import SwiftUI

struct ProjectCardView: View {
    
    // Params
    let fileTransferClient: FileTransferClient?
    var project: Project
    // Data
    @Environment(\.presentationMode) var presentationMode
    @StateObject var model = ProjectViewModel()
    @StateObject var downloadModel = DownloadViewModel()
    
    @State private var fileContents = ""
    
    @AppStorage("value") var value = 0
    
    
    init(fileTransferClient: FileTransferClient?, project: Project) {
        self.fileTransferClient = fileTransferClient
        self.project = project
    }
    
    let downloadLink: String = "https://learn.adafruit.com/pages/22555/elements/3098569/download?type=zip"
    
    func fileCheck(){
        if value == 1{
            model.retrieveCP7xNeopixel()
            value += 1
        }
        if value == 2 {
            value = 0
        }
    }
    
    var body: some View {
        
        VStack {
            
            //            Button(action: {
            //                AppState.shared.startAutoReconnect()
            //                AppState.shared.forceReconnect()
            //            }, label: {
            //                Text("Reset")
            //            })
            
            Form {
                // Section 1
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
                            PyLeap will list the device enabled guides. Our first stop is using Glider (wireless file transfer) inside of PyLeap to work with BundlFly on the Adafruit Learning System to bundle up and send the files on over!
                            """)
                            .fontWeight(.medium)
                            .font(.footnote)
                            .multilineTextAlignment(.leading)
                        Divider()
                        Text("""
        Download the Project Bundle.
        Then, press Send Project Bundle.
        """)
                            .fontWeight(.bold)
                            .font(.system(size: 15))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Section{
                    Button(action: {
                        downloadModel.startDownload(urlString: downloadLink)
                        downloadModel.unzipProjectFile()
                        
                    }, label: {
                        Text("Download Project Bundle")
                            .bold()
                    })
                }
                
                // Section 2
                Section{
                    Button(action: {
                        model.retrieveCP7xCode()
                        value = 1
                        print("value: \(value)")
                    }, label: {
                        Text("Send Project Bundle")
                            .bold()
                            .foregroundColor(.purple)
                    })
                }
                
                // Section 3
                Section(header: Text("code.py")){
                    VStack(alignment: .leading){
                        Text("""
    \(project.pythonCode)
    """)
                    }
                }
            }
            .navigationBarTitle("Project Card")
        }
        
        .alert(isPresented: $downloadModel.showAlert, content: {
            
            Alert(title: Text("Message"), message: Text(downloadModel.alertMsg), dismissButton: .destructive(Text("Ok"), action: {
                withAnimation{
                    downloadModel.showDownloadProgress = false
                }
            }))
        })
        .overlay(
            
            ZStack{
                if downloadModel.showDownloadProgress{
                    DownloadProgressView(progress: $downloadModel.downloadProgress)
                        .environmentObject(downloadModel)
                }
            }
        )
        .disabled(model.transmissionProgress != nil)
        .onChange(of: model.fileTransferClient) { fileTransferClient in
            if fileTransferClient == nil {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear {
            print("View Did Load.")
            model.onAppear(fileTransferClient: fileTransferClient)
            model.startup()
            model.gatherFiles()
            
            fileCheck()
            model.readFile(filename: "/boot_out.txt")
            print(model.bootUpInfo)
            if fileTransferClient == nil {
                print("FileTransfer is nil")
            }
        }
        
        .onDisappear {
            print("ProjectCard - on disappear")
            model.onDissapear()
            
        }
        
        
        
    }
    
}
private struct ContentsView: View {
    @Binding var fileContents: String
    @Binding var filename: String
    
    var body: some View {
        Text(fileContents)
    }
}


struct ProjectCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectCardView(fileTransferClient: nil, project: ProjectData.projects.first!)
    }
}
