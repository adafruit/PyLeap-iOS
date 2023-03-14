//
//  BLESettingsView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 12/15/22.
//

import SwiftUI

struct BLESettingsView: View {
    
    @State private var thirdPartyLink: String = ""
    
    @EnvironmentObject var rootViewModel: RootViewModel
    @StateObject var viewModel = SettingsViewModel()
    @ObservedObject var networkModel = NetworkService()
    
    
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
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text("Add Custom Project")
                .font(Font.custom("ReadexPro-SemiBold", size: 24))
                .padding([.horizontal, .top])
            
            Text("""
Please enter the URL link to your own project that you would like to add to the current list of projects in PyLeap.
""")
            .font(Font.custom("ReadexPro-Regular", size: 18))
            .font(.callout)
            .padding()
            
            TextField("https://", text: $thirdPartyLink)
                .background(Color.white)
                .cornerRadius(5)
                .keyboardType(.URL)
                .textContentType(.URL)
                .onSubmit {
                    networkModel.fetchThirdPartyProject(urlString: thirdPartyLink)
                    thirdPartyLink = ""
                }
                .padding(.horizontal)
            
            
            Form {
                
                Section{
                    Label("[Go to GitHub](https://github.com/adafruit/pyleap.github.io)", systemImage: "link")
                }
            header: {
                Text("""
Find more information on adding your own project here:
""")
            }
                
                Section{
                    Label("[Go to Adafruit.com](https://www.adafruit.com)", systemImage: "link")
                }
                .font(.system(size: 16, weight: .semibold))
                
            }
            
            
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
                    .padding(.leading, 20)
                    Spacer()
                    
                    //                    switch appState {
                    //
                    //                    case .ble:
                    //                        Button {
                    //                            rootViewModel.goToFileTransfer()
                    //                        } label: {
                    //                            Text("Back")
                    //                        }
                    //                        .padding(.leading, 20)
                    //                        Spacer()
                    //
                    //                    case .wifi:
                    //                        Button {
                    //                            rootViewModel.goToWifiView()
                    //                        } label: {
                    //                            Text("Back")
                    //                        }
                    //                        .padding(.leading, 20)
                    //                        Spacer()
                    //
                    //                    case .none:
                    //                        Button {
                    //                            rootViewModel.goToMainSelection()
                    //                        } label: {
                    //                            Text("Back")
                    //                        }
                    //                        .padding(.leading, 20)
                    //                        Spacer()
                    //                    }
                }
                
                .frame(height: UIScreen.main.bounds.height / 19)
                .background(Color(.systemGroupedBackground))
                
                HStack {
                    Text("Settings")
                        .font(Font.custom("ReadexPro-Bold", size: 32))
                        .padding(.leading,20)
                    Spacer()
                }
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
