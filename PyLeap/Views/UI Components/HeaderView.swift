//
//  HeaderView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 4/25/22.
//

import SwiftUI

struct HeaderView: View {
    @State var showSheetView = false
    @EnvironmentObject var rootViewModel: RootViewModel

    
    
    var body: some View {


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
                rootViewModel.goToBLESettings()
            } label: {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 25, height: 25, alignment: .center)
                    .offset(y: 15)
                    .padding(.trailing, CGFloat(20))
                    .foregroundColor(.white)
            }
            
        }
        
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 120)
        .background(Color("pyleap_gray"))
      

    }
}

struct MainHeaderView: View {
    @State var showSheetView = false
    @EnvironmentObject var rootViewModel: RootViewModel
    var body: some View {

        VStack {
            HStack {
                
                Spacer()
                Image("pyleap_logo_white")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125, height: 125)
                    .offset(y: 12)
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
      

    }
}



struct HeaderView_Previews: PreviewProvider {

    static var previews: some View {
        HeaderView()
    }
}
