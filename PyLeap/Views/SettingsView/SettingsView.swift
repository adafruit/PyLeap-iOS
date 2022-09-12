//
//  SettingsView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 9/7/22.
//

import SwiftUI

struct SettingsView: View {
    
    
    @State private var jsonFileName: String = "ter"
    @State private var pythonFileName: String = ""
    
    @State private var presentJSONAlert = false
    @State private var presentPythonAlert = false
    
    @EnvironmentObject var rootViewModel: RootViewModel
    @ObservedObject var networkModel = NetworkService()
    
    
    var body: some View {
        
        NavigationView {
          
            Form {

                VStack() {
                    Button("Real Test") {
                        alertTF(title: "Login test", message: "Message", hintText: "Hint text", primaryTitle: "primaryTitle", secondaryTitle: "secondaryTitle") { text in
                            print(text)
                        } secondaryAction: {
                            print("Cancel")
                        }

                    }
                }

                Section {
                    Toggle(isOn: .constant(false)) {
                        Text("Dark Mode")
                    }

                }
            
            header: {
                    Text("Display")
                }
                
                
                Section {
                    Text("Enter project URL")
                    TextField("https://", text: $pythonFileName)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                        .onSubmit {
                            NetworkService.shared.fetchThirdParyProject(stringURL: pythonFileName)
                            print(pythonFileName)
                            pythonFileName = ""
                        }
                        //.padding(7)
                     //   .padding(.horizontal, 8)
                      //  .background(Color(.systemGray6))
                        //.cornerRadius(8)

                } header: {
                    Text("Add Project")
                }
                .listRowSeparator(.hidden)
                
                
                Section {
                   
                    
                    
                    Button("Create Python File"){
                        presentPythonAlert = true
                    }
                    .alert("Create Python File", isPresented: $presentPythonAlert, actions: {
                                
                        TextField("bbhj", text: $pythonFileName)
                        
                       
                        
                     
                        Button("Add", action: {})
                                
                        Button("Cancel", role: .cancel, action: {})
                            }, message: {
                                Text("Please enter your username and password.")
                            })
                    
                    
                    
                    Button("Create JSON File"){
                        presentPythonAlert = true
                    }
                    .alert("Create Python File", isPresented: $presentPythonAlert, actions: {
                                
                        
                        Button("Add", action: {})
                                
                        Button("Cancel", role: .cancel, action: {})
                            }, message: {
                                Text("Please enter your username and password.")
                            })
                    
// enter a url
                    
                    // add sub
                    //enter a yurrl
                    
                    //https://
                    
                    ///
                    /// fething...
                    /// could not load proj
                    /// //plz check url
                }
            header: {
                Text("Create")
            }
                
                
                
//            footer: {
//                Text("Test")
//            }

                Section{
                    Label("Go to Adafruit.com", systemImage: "link")
                }
                .font(.system(size: 16, weight: .semibold))
                
                
            }
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
                    .padding(8)

                    
                    
                }
            }
        }

    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}


extension View {
   
    func alertMessage(title: String, cancel: @escaping()->()){
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alert.addAction(.init(title: nil, style: .cancel, handler: { _ in
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
