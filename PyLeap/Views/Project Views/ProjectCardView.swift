//
//  ProjectCardView.swift
//  SwiftUI File Manager
//
//  Created by Trevor Beaton on 8/2/21.
//

import SwiftUI

struct ProjectCardView: View {
    
    var project: Project
    
    // Data
    @Environment(\.presentationMode) var presentationMode
    @StateObject var model = ProjectViewModel()
    @StateObject var downloadModel = DownloadViewModel()
    
    @State private var filename = "/code.py"
    @State private var consoleFile = "/boot_out.txt"
    @State private var fileContents = ProjectViewModel.defaultFileContentePlaceholder
    
    // Params
    let fileTransferClient: FileTransferClient?
    
    
    init(fileTransferClient: FileTransferClient?, project: Project) {
        self.fileTransferClient = fileTransferClient
        self.project = project
    }
    
    
    
    
    //Downloads
    @State private var enabled: Bool = true
    @State var value = 0
    @State var standardColor = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
    
    @State private var downloadAmount = 0.0
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    
    //MARK:- Properties
    
    @State private var textField = ""
    @State private var textField2 = ""
    @ObservedObject var input = NumbersOnly()
    @ObservedObject var input2 = NumbersOnly()
    @State private var showStatus = false
    
    let downloadLink: String = "https://learn.adafruit.com/pages/22555/elements/3098569/download?type=zip"
    
    
    
    
    var body: some View {
        
        VStack {
            
            //MARK:- List Of Directories
            //            List {
            //                Section(header: Text("On Device")) {
            //                    ForEach(model.fileArray) { file in
            //                        //    ContentFileRow(title: file.title)
            //                        Text(file.title)
            //                    }
            //                }
            //
            //            }
            
            HStack {
                // Bottom
                Button(action: {
                    downloadModel.startDownload(urlString: downloadLink)
                    downloadModel.unzipProjectFile()
                }, label: {
                    Text("Gather Bundle")
                        .fontWeight(.semibold)
                        .padding(.vertical,10)
                        .padding(.horizontal,30)
                        .background(Color(#colorLiteral(red: 0.7267638319, green: 0.521538479, blue: 1, alpha: 1)))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                })
                .padding(.top)
                
                
                Button(action: {
                    //downloadModel.startDownload(urlString: downloadLink)
                    
                    //downloadModel.unzipProjectFile()
                    model.mypContents()
                    
                    print("""
                            model.neopixelFile
                             \(model.placeholder)
                            """)
                    
                    
                    
                    //                    if let data = model.placeholder.data(using: .utf8) {
                    //                        model.writeFile(filename: "/neopixel.mpy", data: data)
                    //                    }
                    
                }, label: {
                    Text("XXXX")
                        .fontWeight(.semibold)
                        .padding(.vertical,10)
                        .padding(.horizontal,30)
                        .background(Color(#colorLiteral(red: 0.7267638319, green: 0.521538479, blue: 1, alpha: 1)))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                })
                .padding(.top)
            }
            
            Form {
                
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
                        
                        Button(action: {}, label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                        })
                        
                    }
                    
                    Text(project.title)
                        .fontWeight(.semibold)
                    
                    Divider()
                    
                    Group {
                        
                        Button(action: {
                            
                            // Write Function here!
                            print("Send Attempted")
                            if let data = project.pythonCode.data(using: .utf8) {
                                model.writeFile(filename: filename, data: data)
                            }
                            
                        }, label: {
                            Text("Send Code")
                               
                                .padding(.top,8)
                        })
                        .padding(1)
                        
                        
                        DisclosureGroup(
                            
                            content: {
                                
                                Divider()
                                
                                Section(header: Text("Settings")){
                                    
                                    HStack{
                                        Text("Rainbow Brightness")
                                        
                                        TextField("0 - 2.0", text: $input.value)
                                            .keyboardType(.decimalPad)
                                            .padding(.leading, 97)
                                            .disabled(enabled)
                                    }
                                    .padding(.top,10)
                                    
                                    HStack {
                                        Text("Rainbow Speed")
                                        
                                        TextField("0 - 2.0", text: $input2.value)
                                            .keyboardType(.decimalPad)
                                            .padding(.leading, 130)
                                    }
                                    .padding(.top,10)
                                    
                                    DisclosureGroup("Reveal Code") {
                                        
                                        Text("""
\(project.pythonCode)

""")
                                            .padding(1)
                                            .font(.custom("Menlo", size: 12))
                                    }
                                    .padding(.top,10)
                                    
                                }
                                .disabled(true)
                            },
                            label: {
                                Text("Show Content")
                                    .font(.footnote)
                                    .padding(3)
                            })
                    }
                }
                
                // MARK:- Download Progress UI *Do not delete
//                //  value 0  beginning
//                if value == 0 {
//                    Section(header:Text("Files required")
//                                .foregroundColor(.red)
//                    ){
//
//                        Button(action: {
//                            value = 1
//                        }, label: {
//                            VStack(alignment: .leading) {
//                                Text("neopixel.py")
//                                    .foregroundColor(.black)
//                                Text("Download In Rainbows Project Bundle")
//                                    .padding(.top, 8)
//                            }
//                        })
//                    }
//                }
//
//                //Value 1
//
//                if value == 1 {
//                    ProgressView("Downloading…", value: downloadAmount, total: 100)
//                        .onReceive(timer) { _ in
//                            if downloadAmount < 100 {
//                                downloadAmount += 5
//                            }
//                            if downloadAmount == 100 {
//                                enabled = false
//                                value = 2
//
//                            }
//
//                        }
//                }
//
//                if value == 2 {
//                    Section(header:Text("")){
//
//                        Text("Download Complete")
//
//                    }
//                }
                
                Section(header:Text("Console")){
                    
                    //   ContentsView(fileContents: , filename: $consoleFile)
                    //   TextField("cc")
                    //                        .frame(height: 300)
                    //                        .foregroundColor(.green)
                    //                        .foregroundColor(.secondary)
                    //                        .font(.custom("Menlo", size: 12))
                    //                        .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    
                }
                
            } .navigationBarTitle("Project Card")
            
        }
        .onAppear {
            print("View Did Load.")
            model.onAppear(fileTransferClient: fileTransferClient)
            model.startup()
            model.gatherFiles()
            
            model.readFile(filename: "boot_out.txt")
            
            
            
            if fileTransferClient == nil {
                print("FileTransfer is nil")
            }
        }
        .onDisappear {
            print("ProjectCard - on dissapear")
            model.onDissapear()
        }
        .onChange(of: model.fileTransferClient) { fileTransferClient in
            if fileTransferClient == nil {
                self.presentationMode.wrappedValue.dismiss()
            }
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
