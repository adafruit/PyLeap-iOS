//
//  SettingsView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 9/7/22.
//

import SwiftUI

struct SettingsView: View {
    
    
    @State private var jsonFileName: String = ""
    @State private var pythonFileName: String = ""
    
    @State private var presentJSONAlert = false
    @State private var presentPythonAlert = false
    
    @EnvironmentObject var rootViewModel: RootViewModel
    @StateObject var viewModel = SettingsViewModel()
    @ObservedObject var networkModel = NetworkService()
    
    @ObservedObject private var kGuardian = KeyboardGuardian(textFieldCount: 1)
    
    private let kPrefix = Bundle.main.bundleIdentifier!
    let userDefaults = UserDefaults.standard
    
    
    func showInvalidURLEntryAlert() {
        alertMessage(title: "Invalid URL entry", exitTitle: "Ok") {
            
        }
    }
    
    func showDownloadConfirmationAlert() {
        alertMessage(title: "Added to Project List", exitTitle: "Ok") {
            
        }
    }
    
    func showDisconnectionPrompt() {
        comfirmationAlertMessage(title: "Are you sure you want to disconnect?", exitTitle: "Cancel", primaryTitle: "Disconnect") {
            viewModel.clearKnownIPAddress()
            rootViewModel.goToWifiView()
        } cancel: {
            
        }
    }
    
    var body: some View {
        
        VStack {
            
            Form {
                
                VStack() {
                    
                    if viewModel.connectedToDevice {
                        
                        
                        Section() {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Host Name:")
                                    .bold()
                                Text(viewModel.hostName)
                                Text("IP Address:")
                                    .bold()
                                Text(viewModel.ipAddress)
                                Text("Device:")
                                    .bold()
                                Text(viewModel.device)
                                
                            }
                            .padding(.leading,0)
                        }
                        
                    } else {
                        
                        Section() {
                            Button {
                                rootViewModel.goToWifiView()
                            } label: {
                                Text("Connect to Adafruit Device")
                            }
                            
                        }
                        
                    }
                    
                }
                
                if viewModel.connectedToDevice {
                    Section() {
                        Button {
                            rootViewModel.goToWiFiSelection()
                        } label: {
                            Text("Disconnect")
                        }
                    }
                }
                
                
                if viewModel.connectedToDevice {
                    
                        Section {
                            Text("Enter project URL")
                            TextField("https://", text: $pythonFileName)
                                .background(GeometryGetter(rect: $kGuardian.rects[0]))
                                .keyboardType(.URL)
                                .textContentType(.URL)
                                .onSubmit {
                                    networkModel.fetchThirdParyProject(urlString: pythonFileName)
                                    print(pythonFileName)
                                    pythonFileName = ""
                                }
                            
                        }
                    header: {
                        Text("Add Project")
                    }
                    .listRowSeparator(.hidden)
                    
                    
                    
                    
                    Section {
                        
                        Button("Create Python File"){
                            presentPythonAlert = true
                        }
                        .alert("Create Python File", isPresented: $presentPythonAlert, actions: {
                            
                            TextField("", text: $pythonFileName)
                            
                            Button("Add", action: {})
                            
                            Button("Cancel", role: .cancel, action: {
                                presentPythonAlert = false
                            })
                        }, message: {
                            Text("Please enter your username and password.")
                        })
                        
                        
                        Button("Create JSON File"){
                            presentJSONAlert = true
                        }
                        .alert("Create JSON File", isPresented: $presentJSONAlert, actions: {
                            
                            TextField("", text: $jsonFileName)
                            
                            Button("Add", action: {})
                            
                            Button("Cancel", role: .cancel, action: {
                                presentJSONAlert = false
                            })
                        }, message: {
                            Text("Please enter your username and password.")
                        })
                    }
                header: {
                    Text("Create")
                }
                    
                }
                
                Section{
                    Label("[Go to Adafruit.com](https://www.adafruit.com)", systemImage: "link")
                }
                .font(.system(size: 16, weight: .semibold))
                
            }
            
            .offset(y: kGuardian.slide).animation(.easeInOut(duration: 1.0))
            .onAppear { self.kGuardian.addObserver() }
            .onDisappear { self.kGuardian.removeObserver() }
            
            .onChange(of: viewModel.invalidURL, perform: { newValue in
                showInvalidURLEntryAlert()
                viewModel.invalidURL = false
            })
            
            .onChange(of: viewModel.confirmDownload, perform: { newValue in
                showDownloadConfirmationAlert()
                viewModel.confirmDownload = false
            })
            
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    
                    Button {
                        rootViewModel.goToWifiView()
                    } label: {
                        Text("Back")
                        // .font(.system(size: 18, weight: .regular, design: .default))
                            .foregroundColor(.blue)
                    }
                    .padding(12)
                }
            }
        }
        
        .background(Color(UIColor.systemGroupedBackground))
        .safeAreaInset(edge: .top) {
            VStack {
                HStack {
                    Button {
                        rootViewModel.goToWifiView()
                    } label: {
                        Text("Back")
                    }
                    
                    .padding(.leading,20)
                    Spacer()
                }
                
                .frame(height: UIScreen.main.bounds.height / 19)
                .background(Color(.systemGroupedBackground))
                
                HStack {
                    Text("Settings")
                        .font(.largeTitle)
                        .bold()
                    
                        .padding(.leading,20)
                    Spacer()
                }
                .background(Color(.systemGroupedBackground))
            }
            .padding(.top, 25)
            
        }

    }
}




extension View {
    
    func comfirmationAlertMessage(title: String, exitTitle: String, primaryTitle: String,disconnect: @escaping() -> (),cancel: @escaping() -> ()){
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alert.addAction(.init(title: primaryTitle, style: .destructive, handler: { _ in
            disconnect()
        }))
        
        alert.addAction(.init(title: exitTitle, style: .cancel, handler: { _ in
            cancel()
        }))
        
        
        
        rootController().present(alert, animated: true, completion: nil)
    }
    
    func alertMessage(title: String, exitTitle: String, cancel: @escaping()->()){
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alert.addAction(.init(title: exitTitle, style: .cancel, handler: { _ in
            cancel()
        }))
        rootController().present(alert, animated: true, completion: nil)
    }
    
    func alertTF(title: String, message: String, hintText: String, primaryTitle: String, secondaryTitle: String, primaryAction: @escaping(String)->(), secondaryAction: @escaping()->()) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { field in
            field.keyboardType = .decimalPad
            field.placeholder = hintText
            
        }
        alert.addAction(.init(title: secondaryTitle, style: .cancel, handler: { _ in
            secondaryAction()
            
        }))
        alert.addAction(.init(title: primaryTitle, style: .default, handler: { _ in
            if let text = alert.textFields?[0].text {
                primaryAction(text)
            } else {
                primaryAction("")
            }
            
        }))
        rootController().present(alert, animated: true, completion: nil)
    }
    
    func rootController()->UIViewController{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        return root
    }
    
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
