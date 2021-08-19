//
//  FileChooserView.swift
//  Glider
//
//  Created by Antonio García on 21/5/21.
//

import SwiftUI

struct FileChooserView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var model = FileChooserViewModel()
    @State private var showNewDirectoryDialog = false
    
    @Binding var directory: String
    var fileTransferClient: FileTransferClient?
    
    var body: some View {
        VStack {
            Text("Select File:")
                .bold()
                .textCase(.uppercase)
                .foregroundColor(.white)                .padding(.top)
            
            HStack {
            Text("Path:")
                .font(.caption)
                .foregroundColor(.white)
            
                
                TextField("", text: $model.directory, onCommit:  {})
                    .disabled(true)
                    .colorMultiply(.gray)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            
            ZStack {
                List {
                    if !model.isRootDirectory {
                        Button(action: {
                            let path = FileTransferUtils.upPath(from: model.directory)
                            let _ = print("Up directory: \(path)")
                            $directory.wrappedValue = path
                            model.listDirectory(directory: path)
                            
                        }, label: {
                            ItemView(systemImageName: "arrow.up.doc", name: "..", size: nil)
                                .foregroundColor(.white)
                        })
                        .listRowBackground(Color.clear)
                    }
                    
                    ForEach(model.entries, id:\.name) { entry in
                        HStack {
                            switch entry.type {
                            case .file(let size):
                                Button(action: {
                                    let _ = print("File: \(entry.name)")
                                    $directory.wrappedValue = model.directory + entry.name
                                    presentationMode.wrappedValue.dismiss()
                                }, label: {
                                    ItemView(systemImageName: "doc", name: entry.name, size: size)
                                })
                                
                            case .directory:
                                Button(action: {
                                    let _ = print("Directory: \(entry.name)")
                                    let path = model.directory + entry.name + "/"
                                    $directory.wrappedValue = path
                                    model.listDirectory(directory: path)
                                }, label: {
                                    ItemView(systemImageName: "folder", name: entry.name, size: nil)
                                })
                                
                            }
                        }
                    }
                    .onDelete(perform: model.delete)
                    .listRowBackground(Color.clear)
                    .foregroundColor(.white)
                }
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    .if(!model.isTransmiting) {
                        $0.hidden()
                    }
                
                Text("No files found")
                    .foregroundColor(.white)
                    .if(model.isTransmiting || model.entries.count > 0) {
                        $0.hidden()
                    }
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    showNewDirectoryDialog.toggle()
                    
                }, label: {
                    Label("New Directory", systemImage: "folder.badge.plus")
                })
                .layoutPriority(1)
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.bottom)
        }
        .defaultBackground(hidesKeyboardOnTap: true)
        .onAppear {
            model.setup(fileTransferClient: fileTransferClient, directory: directory)
        }
        .alert(isPresented: $showNewDirectoryDialog, TextFieldAlert(title: "New Directory", message: "Enter name for the new directory") { directoryName in
            if let directoryName = directoryName {
                let path = model.directory + directoryName
                model.makeDirectory(path: path)
            }
        })
    }
    
    private struct ItemView: View {
        let systemImageName: String
        let name: String
        let size: Int?
        
        var body: some View {
            HStack {
                Image(systemName: systemImageName)
                    .frame(width: 24)
                Text(name)
                if let size = size {
                    Spacer()
                    Text("\(size) bytes")
                }
            }
        }
        
    }
}

struct DirectoryChooserView_Previews: PreviewProvider {
    static var previews: some View {
        FileChooserView(directory: .constant("/"), fileTransferClient: nil)
    }
}
