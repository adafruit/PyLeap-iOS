//
//  BLESettingsView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 12/15/22.
//

import SwiftUI

struct BLESettingsView: View {
    
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
                
                Section {
                    Text("Enter project URL")
                    TextField("https://", text: $pythonFileName)
                        .background(GeometryGetter(rect: $kGuardian.rects[0]))
                        .keyboardType(.URL)
                        .textContentType(.URL)
                        .onSubmit {
                            networkModel.fetchThirdPartyProject(urlString: pythonFileName)
                            print(pythonFileName)
                            pythonFileName = ""
                        }
                    
                }
            header: {
                Text("""
Download your own project here. Enter your URL to add your project to the collection.

Add Project
""")
            }
            .listRowSeparator(.hidden)
   
            
        Section{
            Label("[Go to GitHub](https://github.com/adafruit/pyleap.github.io)", systemImage: "link")
        }
            header: {
                Text("""
Find more information on adding your own project here:
""")
            }
        
        
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
                        rootViewModel.goToFileTransfer()
                        
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
                        rootViewModel.goToFileTransfer()
                        
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

struct BLESettingsView_Previews: PreviewProvider {
    static var previews: some View {
        BLESettingsView()
    }
}
