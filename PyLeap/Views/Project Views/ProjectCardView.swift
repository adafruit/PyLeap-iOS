//
//  ProjectCardView.swift
//  SwiftUI File Manager
//
//  Created by Trevor Beaton on 8/2/21.
//

import SwiftUI
import FileTransferClient
import WebKit

struct WebView : UIViewRepresentable {
    
    let request = URLRequest(url: URL(string: "https://learn.adafruit.com/pyleap-device-enabled-blinky")!)
    
    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
    
}

struct ProjectCardView: View {
    
    var project: Project
    
    // Data
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject private var connectionManager: FileTransferConnectionManager
    
    @State private var showWebViewPopover: Bool = false
    
    @StateObject var model = ProjectViewModel()
    @StateObject var downloadModel = DownloadViewModel()
    
    
    @State private var showDownloadButton = false
    @State private var sendLabel = "Send Bundle"
    @State private var progress : CGFloat = 0
    @State private var downloadedBundle = false
    // Download Button
    @State private var disableDownload = false
    @State private var downloadLabel = "Download Bundle"
    
    @State var showProgressBar = false
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
                    //model.filesDownloaded(url: project.filePath)
                }
            } else {
                DispatchQueue.main.async {
                    print("FILE NOT AVAILABLE")
                    downloadedBundle = false
                    progress = 0
                }
            }
        }
    }
    
    let layout = [
        GridItem(.adaptive(minimum: 180))
    ]
    
    var columns = Array(repeating: GridItem(.flexible(), spacing:20), count: 2)
    @State var editedContents = ""
    
    var body: some View {
        
        VStack {
            
//            ScrollView {
//                
//                
//                
//                VStack{
//                    
//                    
//                    Group {
//                        
//                        Text("code.py")
//                        
//                        TextEditor(text: $editedContents)
//                            .background(Color.white)
//                        //                        Image("rainbow")
//                        //                        .resizable(resizingMode: .stretch)
//                        //                        .aspectRatio(contentMode: .fit)
//                        //                        .frame(width: 200, height: 200, alignment: .center)
//                        //                        .shadow(radius: 10)
//                        //
//                        //                        .padding(.top, 5)
//                        //
//                        //                    Text(project.title)
//                        //                        .bold()
//                        //                        .font(.system(size: 22))
//                        //                        .padding(.top, 0)
//                        //
//                        //
//                        //                    Text(project.device)
//                        //                        .font(.subheadline)
//                        //                        .padding(.top, 0)
//                        //                        .foregroundColor(Color.secondary)
//                        //
//                        //
//                        //                    Text(project.description)
//                        //                        .font(.subheadline)
//                        //                        .multilineTextAlignment(.leading)
//                        //                        .padding()
//                        //
//                        
//                        Spacer()
//                    }
//                    
//                    
//                    if downloadedBundle == false {
//                        
//                        Section {
//                            Button(action: {
//                                downloadModel.startDownload(urlString: project.downloadLink)
//                                
//                                disableDownload = true
//                                downloadLabel = "Downloading..."
//                                
//                                print(project.downloadLink)
//                                print("Download type: \(project.title)")
//                            }, label: {
//                                
//                                HStack {
//                                    
//                                    Text(downloadLabel)
//                                        .fontWeight(.semibold)
//                                        .font(.system(size: 18))
//                                        .frame(width: 230, height: 50, alignment: .center)
//                                        .background(Color(red: 1, green: 1, blue: 1))
//                                        .cornerRadius(10)
//                                        .padding()
//                                    
//                                        .onAppear {
//                                            print("on awake: \(downloadedBundle)")
//                                        }
//                                    
//                                        .onChange(of: downloadModel.downloadProgress) { newValue in
//                                            print("Current Download Progress: \(newValue)")
//                                            
//                                            
//                                            if newValue == 1.0 {
//                                                
//                                                
//                                                downloadLabel = "Download Bundle"
//                                                // downloadedBundle = false
//                                                downloadedBundle = true
//                                                disableDownload = false
//                                                
//                                                DispatchQueue.main.async {
//                                                    model.downloadCheck(at: project.filePath)
//                                                }
//                                                
//                                                
//                                                print("Status: \(downloadedBundle)")
//                                                print("PASS")
//                                                print("Current Download Status: \(downloadedBundle)")
//                                            }
//                                            
//                                        }
//                                        .onChange(of: downloadModel.isDownloading, perform: { value in
//                                            
//                                            DispatchQueue.main.async {
//                                                print("Download Status: \(value)")
//                                                
//                                                
//                                                progress = downloadModel.downloadProgress
//                                            }
//                                            
//                                            
//                                        })
//                                    
//                                }
//                                
//                            })
//                            
//                        }
//                        .disabled(disableDownload)
//                        
//                        
//                        
//                    } else {
//                        // Section 2
//                        Section{
//                            Button(action: {
//                                print("Start transfer process...")
//                            }, label: {
//                                Text(sendLabel)
//                                    .fontWeight(.semibold)
//                                    .font(.system(size: 18))
//                                    .frame(width: 230, height: 50, alignment: .center)
//                                    .foregroundColor(Color.purple)
//                                    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
//                                    .cornerRadius(10)
//                                    .padding()
//                            })
//                            
//                        }
//                        
//                        
//                        
//                        
//                    }
//                    
//                    
//                    //          Divider()
//                    Spacer()
//                }
//                
//                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.1)
//                .border(Color(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.497), width: 3)
//                //  .background(Color.purple)
//                
//                
//                HStack{
//                    Text("Files Downloaded")
//                        .font(.system(size: 22))
//                        .fontWeight(.bold)
//                        .multilineTextAlignment(.leading)
//                        .padding(5)
//                    
//                    Spacer()
//                }
//                //                ForEach(model.directoryArray) { file in
//                //
//                //                    VStack(alignment: .leading) {
//                //                        DirectoryRow(title: file.title)
//                //                            .padding(5)
//                //                        Divider()
//                //                    }
//                //
//                //                }
//                
//                ForEach(model.fileArray) { file in
//                    VStack(alignment: .leading) {
//                        FileRow(title: file.title, fileSize: file.fileSize)
//                            .padding(5)
//                        Divider()
//                    }
//                }
//                
//                
//                
//                Section{
//                    VStack(alignment: .leading){
//                        
//                        HStack{
//                            Text("Serial Terminal")
//                                .font(.system(size: 22))
//                                .fontWeight(.bold)
//                                .multilineTextAlignment(.leading)
//                                .padding(5)
//                            
//                            Spacer()
//                        }
//                        
//                        Text("""
//                                                \(model.bootUpInfo)
//                                                """)
//                        
//                            .font(.custom("Menlo", size: 13))
//                            .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
//                    }
//                    
//                }
//                
//                .background(Color.secondary)
//                //    .border(Color(hue: 0.926, saturation: 1.0, brightness: 1.0, opacity: 0.8), width: 4)
//                
//            }
//            .border(Color(red: 1.0, green: 0.0, blue: 0.0, opacity: 1.0), width: 4)
//            
            
            
            
            
            
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
                        
                        Button("Show Learn Guide") {
                            self.showWebViewPopover = true
                        }
                        .popover(
                            isPresented: self.$showWebViewPopover,
                            arrowEdge: .bottom
                        ) {
                            VStack{
                                WebView()
                            }
                            
                            .padding(0)
                            
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
                            .fixedSize(horizontal: false, vertical: true)
                        
                    }
                }
                
                
                
                if model.didDownload {
                    
                    // Section 2
                    Section {
                        
                        Button {
                            model.filesTransfer(url: project.filePath)
                        } label: {
                            Text("\(sendLabel)")
                                .bold()
                                .foregroundColor(.purple)
                        }
                        
                        
                        
                        if model.sendingBundle {
                            
                            ProgressView("Please wait...", value: CGFloat(model.counter), total: CGFloat(model.numOfFiles) )
                                .accentColor(.purple)
                                .foregroundColor(.purple)
                            
                        }
                        
                        
                        if model.didCompleteTranfer {
                            Text("Transfer Complete")
                                .foregroundColor(.green)
                                .bold()
                        }
                        
                        if model.writeError {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("""
                                        Cannot write to device
                                        Unplug from USB & reset Circuit Playground Bluefruit
                                        """)
                                
                                
                            }
                            .foregroundColor(.red)
                            
                        }
                        
                        
                        //                                            .isHidden(showProgressBar)
                        //                                            .onChange(of: model.numOfFiles) { newValue in
                        //                                                print("Current Download Progress: \(newValue)")
                        //                                                if model.counter == model.numOfFiles || model.counter == 0 {
                        //                                                    showProgressBar = true
                        //                                                    print("HIDE")
                        //                                                } else {
                        //                                                    showProgressBar = false
                        //                                                    print("SHOW")
                        //                                                }
                        //                                            }
                    }
                    .disabled(model.sendingBundle)
                    
                } else {
                    
                    Section {
                        
                        Button(action: {
                            
                            if model.isConnectedToInternet {
                                downloadModel.startDownload(urlString: project.downloadLink)
                                
                                disableDownload = true
                                downloadLabel = "Downloading..."
                                
                                
                            } else {
                                print("Not connected.")
                            }
                            
                            
                        }, label: {
                            
                            
                            
                            Text(downloadLabel)
                                .bold()
                                .onChange(of: downloadModel.downloadProgress) { newValue in
                                    print("Current Download Progress: \(newValue)")
                                    
                                    if newValue == 1.0 {
                                        
                                        
                                        downloadLabel = "Download Bundle"
                                        downloadedBundle = true
                                        disableDownload = false
                                        
                                        
                                        model.downloadCheck(at: project.filePath)
                                        
                                        
                                        
                                    }
                                    
                                }
                                .onChange(of: downloadModel.isDownloading, perform: { value in
                                    
                                    DispatchQueue.main.async {
                                        print("Download Status: \(value)")
                                        progress = downloadModel.downloadProgress
                                    }
                                })
                            
                        })
                        
                    }
                    .disabled(disableDownload)
                    
                    
                }
                
                
                
                
                
                
                
                Section(header: Text("Serial Terminal")){
                    VStack(alignment: .leading){
                        Text("""
                                        \(model.bootUpInfo)
                                        """)
                        
                            .font(.custom("Menlo", size: 12))
                            .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    }
                    
                }
                
                //            // MARK: - Keep for debugging - or will add as a feature
                //                                Button {
                //                                    model.removeAllFiles()
                //                                } label: {
                //                                    Text("Delete All")
                //                                }
                
                
                
                
                
                Section(header: Text("Files Downloaded")) {
                    List {
                        
                        
                        ForEach(model.contentList) { file in
                            
                            DirectoryRow(incomingURL: file, fileSize: 0)
                            
                        }
                        
                        
                    }
                    
                }
                
            }
            
            .navigationBarTitle("Project Card")
            //    .navigationBarBackButtonHidden(true)
        }
        
        
        
        
        
        .alert(isPresented:$model.showAlert) {
            Alert(
                title: Text("Internet Connection"),
                message: Text("There's a problem with your internet connection. Try again later."),
                primaryButton: .destructive(Text("Try Again")) {
                    print("Deleting...")
                },
                secondaryButton: .cancel()
            )
        }
        
        .disabled(model.transmissionProgress != nil)
        
        
        
        .onChange(of: model.editableContent1, perform: { value in
            
            editedContents = model.editableContent1
            
            print("NEW VALUE: \(value)")
        })
        
        
        .onChange(of: connectionManager.selectedClient) { selectedClient in
            model.setup(fileTransferClient: selectedClient)
        }
        
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.none)
        .onAppear {
            
            model.setup(fileTransferClient: connectionManager.selectedClient)
            model.internetMonitoring()
            model.downloadCheck(at: project.filePath)
            model.readFile(filename: "boot_out.txt")
        }
    }
}


struct FileRow: View {
    let title : String
    let fileSize: Int
    var body: some View {
        
        HStack{
            Image(systemName: "doc.text")
                .padding(5)
            VStack(alignment: .leading){
                Text(title)
                    .font(.system(size: 18))
                
                
                
                Text("\(fileSize) kb")
                    .font(.subheadline)
                
            }
        }
    }
}

struct URLData: Identifiable {
    let id = UUID()
    let urlTitle: URL
}

struct DirectoryRow: View {
    var incomingURL: URLData
    // let urlTitle: URL
    let fileSize: Int
    
    
    
    var body: some View {
        
        
        if incomingURL.urlTitle.hasDirectoryPath {
            Label(
                title: {
                    HStack {
                        Text(incomingURL.urlTitle.lastPathComponent)
                            .font(.system(size: 18))
                        
                        Image(systemName: "chevron.down")
                        
                    }
                },
                icon: { Image(systemName: "folder.fill") })
        } else {
            HStack{
                Image(systemName: "doc.text")
                    .padding(5)
                VStack(alignment: .leading){
                    
                    Text(incomingURL.urlTitle.lastPathComponent)
                        .font(.system(size: 18))
                    
                }
            }
        }
        
        
    }
}

struct ContentDir: Identifiable {
    var id = UUID()
    var urlTitle: URL
    
}

struct ContentFile: Identifiable {
    var id = UUID()
    var title: String
    var fileSize: Int
}



struct ProjectCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectCardView(project: CPBProjects.projects.first!)
    }
}

