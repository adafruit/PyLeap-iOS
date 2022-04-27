//
//  HeaderView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 4/25/22.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack {
            
            VStack {
                
                Spacer()
                
                Image("pyleap_logo_white")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125, height: 125)
                    .offset(y: 10)
                Spacer()
                
            }
            
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 130)
        .background(Color("pyleap_gray"))
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView()
    }
}
