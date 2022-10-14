//
//  WifiHeaderView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 9/7/22.
//

import SwiftUI

struct WifiHeaderView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var showSheetView = false
    @EnvironmentObject var rootViewModel: RootViewModel

    var body: some View {

        VStack {
        
            HStack {
                
                Button {
                    presentationMode.wrappedValue.dismiss()
                    rootViewModel.goToMain()
                    
                } label: {
                    Image(systemName: "arrow.backward")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                        .offset(y: 15)
                        .foregroundColor(.white)
                }
                
                .padding()
                
                Spacer()
                Image("pyleap_logo_white")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125, height: 125)
                    .offset(y: 12)
                  //  .padding(.leading, 60)
                
                Spacer()
                
                Button {
                    rootViewModel.goToSettings()
                } label: {
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                        .offset(y: 15)
                        .foregroundColor(.white)
                }
                
                .padding()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 120)
        .background(Color("pyleap_gray"))
      

    }
}

struct WifiHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        WifiHeaderView()
    }
}
