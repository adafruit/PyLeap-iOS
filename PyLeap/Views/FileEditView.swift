//
//  FileEditView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 2/7/22.
//

import SwiftUI
import FileTransferClient

struct FileEditView: View {

    @State private var editedContents = "Hello World"
    
    var body: some View {
        NavigationView {
        VStack(spacing: 0) {
            TextEditor(text: $editedContents)
        }
        .onAppear {
            
        }
    }
        .navigationViewStyle(.stack)
    }
    
}

// MARK: - Preview
struct FileEditView_Previews: PreviewProvider {
    static var previews: some View {
        FileEditView()
    }
}
