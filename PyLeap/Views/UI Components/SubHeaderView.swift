//
//  SubHeaderView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 4/25/22.
//

import SwiftUI

struct SubHeaderView: View {
    var body: some View {
        HStack {
            
            Text("Browse available WiFi PyLeap Projects")
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(/*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .font(Font.custom("ReadexPro-Regular", size: 25))
            
        }
        .padding(.vertical,30)
    }
}

struct MainSubHeaderView: View {
    let device: String
    
    var body: some View {
        
       
        HStack {
            
            Text("Pick a project to run on your \(device)")
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(/*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .font(Font.custom("ReadexPro-Regular", size: 25))
            
        }
        .padding(.vertical,30)
    }
}


struct SubHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SubHeaderView()
    }
}
