//
//  ProjectCardView.swift
//  SwiftUI File Manager
//
//  Created by Trevor Beaton on 8/2/21.
//

import SwiftUI

struct ProjectCardView: View {
    
    var project: Project
    //@AppStorage("onboarding") var onboardingSeen = false
    
    @AppStorage("index") var selectedProjectIndex = 0
    
    // Data
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var model = ProjectViewModel()
    @StateObject var downloadModel = DownloadViewModel()
    
    @State private var filename = "/code.py"
    @State private var consoleFile = "/boot_out.txt"
    @State private var fileContents = ProjectViewModel.defaultFileContentePlaceholder
    @State private var showingDownloadAlert = false
    @State private var sendLabel = "Send Bundle"
    
    @State private var progress : CGFloat = 0
    
    @AppStorage("value") var value = 0
    @AppStorage("fileSent") var neopixelFileSent = false
    
    @State private var name = ""
    
    // Params
    let fileTransferClient: FileTransferClient?
    
    init(fileTransferClient: FileTransferClient?, project: Project) {
        self.fileTransferClient = fileTransferClient
        self.project = project
    }
    
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    func sendingNeopixelFile() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        let data = try? Data(contentsOf: URL(fileURLWithPath: "neopixel", relativeTo: documentsURL).appendingPathExtension("mpy"))
        print(documentsURL)
        
        model.writeFile(filename: "/neopixel.mpy", data: data!)
        
    }
    
    func sendingCodeFile() {
        //        if value == 1 {
        if let data = project.pythonCode.data(using: .utf8) {
            model.writeFile(filename: filename, data: data)
            
            //  }
        }
        
    }
    
    //Downloads
    @State private var buttonInteractivity: Bool = false
    @State private var sendInteractivity: Bool = true
    
    
    @State private var downloadAmount = 0.0
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    let downloadLink: String = "https://learn.adafruit.com/pages/22555/elements/3098569/download?type=zip"
    
    
    
    func fileCheck(){
            print("Inital value: \(value)")
            if value == 0 {
                print("Ready to transmit...")
            }
            
            if value == 1{
                print("In file checker - step 1")
                if selectedProjectIndex == 1 {
                    model.blinkCP7xLib()
                    print("Sending Blink Lib")
                    print("Proj. Index \(selectedProjectIndex)")
                }else {
                    print("Sending Neopixel Lib")
                    print("Proj. Index \(selectedProjectIndex)")
                    model.retrieveCP7xNeopixel()
                    
                }
                value += 1

            }
            if value == 2 {
                print("Restarting")
                value = 0
                
            }
        }
    
    var frameworks = ["UIKit", "Core Data", "CloudKit", "SwiftUI"]
    var projectNames = ["Glide on over some rainbows!","Blink!", "LED Glasses", "Hello World"]
    
    let projectArray = ProjectData.projects
    
    
    var body: some View {
        
        VStack {
            
            Form {
                Section {
                    Picker(selection: $selectedProjectIndex, label: Text("Select")) {
                        ForEach(0 ..< projectNames.count) {
                            Text(self.projectNames[$0])
                        }
                    }
                    .onAppear(){
                        print("selectedFrameworkIndex: \(selectedProjectIndex)")
                    }
                }
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
                            
                            
                            Text("Circuit Playground Bluefruit")
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
                        downloadModel.startDownload(urlString: projectArray[selectedProjectIndex].downloadLink)
                        
                        print(projectArray[selectedProjectIndex].downloadLink)
                    }, label: {
                        HStack{
                            DownloadButtonViewModel(percentage: $progress)
                            Text("Download Project Bundle")
                                .bold()
                                .onChange(of: downloadModel.downloadProgress, perform: { value in
                                    progress = downloadModel.downloadProgress
                                })
                            
                        }
                        
                    })
                }
                
                // Section 2
                Section{
                    Button(action: {
                        if selectedProjectIndex == 0 {
                            model.retrieveCP7xCode()
                            print("Rainbow")
                        }
                        if selectedProjectIndex == 1 {
                            model.retrieveBlinkCP7xCode()
                            print("Blink")
                        }
//                        if selectedProjectIndex == 2 {
//                            model.ledGlassesCP7xCode()
//                            print("Glasses")
//                        }
//                        if selectedProjectIndex == 3 {
//                            model.retrieveCP7xCode()
//
//                        }
                        
                        //   model.retrieveCP7xCode()
                        //model.counterFunc()
                        value = 1
                        print("value: \(value)")
                    }, label: {
                        Text("\(sendLabel)")
                            .bold()
                            .foregroundColor(.purple)
                    })
                }
                
            }
            
            .navigationBarTitle("Project Card")
            .navigationBarBackButtonHidden(true)
        }
        
        
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
            // model.gatherFiles()
            // model.retrieveCP7xNeopixel()
            fileCheck()
            print("value: \(value)")
            
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

