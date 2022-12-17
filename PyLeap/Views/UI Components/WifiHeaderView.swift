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
        
            
            
            HStack (alignment: .center, spacing: 0) {

                Image(systemName: "gearshape")
                    .resizable()
                    .frame(width: 25, height: 25, alignment: .center)
                    .offset(y: 15)
                    .padding(.leading, CGFloat(20))
                    .foregroundColor(.clear)
                
                Spacer()
                
                Image("pyleap_logo_white")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125, height: 125)
                    .offset(y: 12)
                
                Spacer()
                
                Button {
                    rootViewModel.goToSettings()
                } label: {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 25, height: 25, alignment: .center)
                        .offset(y: 15)
                        .padding(.trailing, CGFloat(20))
                        .foregroundColor(.white)
                }
                
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
