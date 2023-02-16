//
//  WifiListDetailView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/23/22.
//

import SwiftUI

struct WifiListDetailView: View {
   
    let text: String
    
    var body: some View {
        VStack {
        Text(text)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
            
    }
}
}
struct WifiListDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WifiListDetailView(text: "")
    }
}
