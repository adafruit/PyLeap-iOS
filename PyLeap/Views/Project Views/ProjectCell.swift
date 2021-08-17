//
//  ProjectButton.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/12/21.
//

import SwiftUI

struct ProjectCell: View {

    let title: String
    let deviceName: String
    
    static let gradientStart = Color(red: 185 / 255, green: 0 / 255, blue: 220 / 255)
    static let gradientEnd = Color(red: 150 / 255, green: 0 / 255, blue: 200 / 255)
    
    var body: some View {
        HStack {
            
            VStack(alignment: .leading){
                Image("logo")
                    .resizable(resizingMode: .stretch)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .frame(width: 25, height: 25)
                    .padding(9)
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    
                    Text(deviceName)
                        .font(.footnote)
                        .foregroundColor(.white)
                }
                .padding(8)
                   
            }
            
            Spacer()
            
        }
       
        .frame(width: 180,height: 120)
        .background(LinearGradient(
            gradient: .init(colors: [Self.gradientStart, Self.gradientEnd]),
            startPoint: .init(x: 0.5, y: 0),
            endPoint: .init(x: 0.5, y: 0.6)
        ))
        .cornerRadius(20)
    }
    
}

struct ProjectButton_Previews: PreviewProvider {
    static var previews: some View {
        ProjectCell(title: "Title", deviceName: "CPB")
    }
}
