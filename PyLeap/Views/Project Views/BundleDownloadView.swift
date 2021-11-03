//
//  BundleDownloadView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 11/2/21.
//

import SwiftUI

struct BundleDownloadView: View {
   
    @StateObject var model = BundleDownloadVModel()
    
    var body: some View {
        List {
            Section(header: Text("Downloaded Files")) {
                ForEach(model.fileArray) { file in
                    
                    ContentFileRow(title: file.title)
                    
                }
            }
        }
    }
}

struct BundleDownloadView_Previews: PreviewProvider {
    static var previews: some View {
        BundleDownloadView()
    }
}
