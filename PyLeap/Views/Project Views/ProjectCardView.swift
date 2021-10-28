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
    
    @StateObject var model = ProjectViewModel()
    @StateObject var downloadModel = DownloadViewModel()
    
    
    @State private var showingDownloadAlert = false
    @State private var sendLabel = "Send Bundle"
    
    @State private var progress : CGFloat = 0
    
    @AppStorage("value") var value = 0
    @AppStorage("fileSent") var neopixelFileSent = false
    
    @State private var downloadedBundle = false
    // Params
    //let fileTransferClient: FileTransferClient? = FileTransferConnectionManager.shared.selectedClient
    
    init(project: Project) {
        self.project = project
    }
    
    func fileCheck() {
        print("Inital value: \(value)")
        if value == 0 {
            print("Ready to transmit...")
        }
        
        if value == 1{
            
            print("In file checker - step 1")
            
            if selectedProjectIndex == 0 {
                value = 0
                model.retrieveCP7xNeopixel()
                print("Sending Rainbow Lib")
                print("Proj. Index \(selectedProjectIndex)")
            }
            
            if selectedProjectIndex == 1 {
                value = 0
                model.blinkCP7xLib()
                print("Sending Blink Lib")
                print("Proj. Index \(selectedProjectIndex)")
            }
            
            if selectedProjectIndex == 2 {
                
                
                if selectedLEDIndex == 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                        selectedLEDIndex += 1
                        print("File 1")
                        value += 1
                        model.ledGinit_File()
                    }
                    
                }
                
            }
            
        }
        if value == 2 {
            if selectedProjectIndex == 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    if selectedLEDIndex == 1 {
                        selectedLEDIndex += 1
                        print("File 2")
                        value += 1
                        model.ledGMain_File()
                    }
                }
            }
            //print("Restarting")
            //value = 0
            
        }
        
        if value == 3 {
            if selectedProjectIndex == 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    if selectedLEDIndex == 2 {
                        selectedLEDIndex += 1
                        print("File 3")
                        value += 1
                        model.ledGrgbmatrixFile()
                    }
                }
            }
        }
        //Here
        if value == 4 {
            if selectedProjectIndex == 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    if selectedLEDIndex == 3 {
                        selectedLEDIndex += 1
                        print("File 4")
                        value += 1
                        model.ledGIssi_evb_File()
                    }
                }
            }
        }
        
        if value == 5 {
            if selectedProjectIndex == 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    if selectedLEDIndex == 4 {
                        selectedLEDIndex += 1
                        print("File 5")
                        value += 1
                        model.ledGinit_Reg()
                    }
                }
            }
        }
        
        if value == 6 {
            if selectedProjectIndex == 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    if selectedLEDIndex == 5 {
                        selectedLEDIndex += 1
                        print("File 6")
                        value += 1
                        model.ledGbcd_Reg()
                    }
                }
            }
        }
        
        if value == 7 {
            if selectedProjectIndex == 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    if selectedLEDIndex == 6 {
                        selectedLEDIndex += 1
                        print("File 7")
                        value += 1
                        model.ledGbcd_DaytimeReg()
                    }
                }
            }
        }
        
        if value == 8 {
            if selectedProjectIndex == 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    if selectedLEDIndex == 7 {
                        selectedLEDIndex += 1
                        print("File 8")
                        value += 1
                        model.ledGi2c_bit_Reg()
                    }
                }
            }
        }
        
        if value == 9 {
            if selectedProjectIndex == 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    if selectedLEDIndex == 8 {
                        selectedLEDIndex += 1
                        print("File 9")
                        value += 1
                        model.ledGi2c_bits_Reg()
                    }
                }
            }
        }
        
        
        if value == 10 {
            if selectedProjectIndex == 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    if selectedLEDIndex == 9 {
                        selectedLEDIndex += 1
                        print("File 10!")
                        value += 1
                        model.ledGi2c_struct_Reg()
                    }
                }
            }
        }
        
        if value == 11 {
            if selectedProjectIndex == 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    if selectedLEDIndex == 10 {
                        selectedLEDIndex += 1
                        print("File 11!")
                        value += 1
                        model.ledGi2c_struct_array_Reg()
                    }
                }
            }
        }
        
        
        if value == 12{
            print("Restart")
            selectedLEDIndex = 0
            value = 0
        }
        
    }
    
    func downloadCheck(at filePath: URL){
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            
            
            if FileManager.default.fileExists(atPath: filePath.path) {
                print("FILE AVAILABLE")
                downloadedBundle = true
            } else {
                print("FILE NOT AVAILABLE")
                downloadedBundle = false
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
                                        downloadCheck(at: projects[item].filePath)
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
                            
                            if downloadedBundle == false{
                                
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
                                //Download Button
                            } else {
                                
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
                                    if selectedProjectIndex == 2 {
                                        model.createLEDGlassesLib()
                                        model.ledGlassesCP7xCode()
                                        print("Glasses")
                                    }
                                    
                                    value = 1
                                    print("value: \(value)")
                                }, label: {
                                    Text("\(sendLabel)")
                                        .bold()
                                        .foregroundColor(.purple)
                                })
                            }
                            if selectedProjectIndex == 2 {
                                Text("\(selectedLEDIndex)/10 Files Transferred")
                            }
                        }
                        
                        
                    }
                    .navigationBarTitle("Project Card")
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            
                            Button("Back") {
                                showSelection.toggle()
                            }
                        }
                    }
                    
                    
                }
                
                
            }
            
            .disabled(model.transmissionProgress != nil)
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            
            print("View Did Load.")
            model.onAppear(/*fileTransferClient: fileTransferClient*/)
            model.startup()
            downloadCheck(at: projects[selectedProjectIndex].filePath)
            fileCheck()
            print("value: \(value)")
            
            /*
            if fileTransferClient == nil {
                print("FileTransfer is nil")
            }*/
        }
        
        .onDisappear {
            print("ProjectCard - on disappear")
            model.onDissapear()
            
        }
        
        
    }
}


struct ProjectCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectCardView(project: ProjectData.projects.first!)
    }
}

