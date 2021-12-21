//
//  InfoModalView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 11/18/21.
//

import SwiftUI

struct InfoModalView: View {
    @Environment(\.presentationMode) var presentation
    var body: some View {
        
        
        VStack {
            Group{
                
                Text("Hold your Bluefruit device closer to your mobile device.")
                    .foregroundColor(.black)
                    .font(.custom("SF Pro", size: 15))
                    .padding(.top, 90)
                ZStack {
                    ScanningView()
                    Image("cpb")
                                        .resizable(resizingMode: .stretch)
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.white)
                                        .frame(width: 250, height: 250)
                }
                
                
                Text("Test")
                
                
            }
        }

    }
    }
struct InfoModalView_Previews: PreviewProvider {
    static var previews: some View {
        InfoModalView()
    }
}
