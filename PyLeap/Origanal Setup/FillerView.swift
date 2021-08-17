//
//  FillerView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/12/21.
//

import SwiftUI

struct FillerView: View {
    var body: some View {
        VStack{
            
            Image("pyleapLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .offset(y: -20)
        }
        .padding(.horizontal, 20)
        .edgesIgnoringSafeArea(.all)
        .background(Color.red)
    }
}

struct FillerView_Previews: PreviewProvider {
    static var previews: some View {
        FillerView()
    }
}
