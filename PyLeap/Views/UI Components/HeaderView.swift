//
//  HeaderView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 4/25/22.
//

import SwiftUI

struct HeaderView: View {
    @State var showSheetView = false
    var body: some View {

        VStack {
            HStack {
                
                Spacer()
                Image("pyleap_logo_white")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125, height: 125)
                    .offset(y: 10)
                    .padding(.leading, 60)
                
                Spacer()
                
                Button {
                    self.showSheetView.toggle()
                } label: {
                    Image(systemName: "info.circle")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                        .offset(y: 15)
                        .foregroundColor(.white)
                }.sheet(isPresented: $showSheetView) {
                    CreditView(isPresented: $showSheetView)
                                    }
                
                .padding()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 120)
        .background(Color("pyleap_gray"))
      
//        Button(action: {
//                    self.showSheetView.toggle()
//                }) {
//                    PairingTutorialButton()
//                }.sheet(isPresented: $showSheetView) {
//                    PairingTutorialView()
//                }
        
        
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView()
    }
}
