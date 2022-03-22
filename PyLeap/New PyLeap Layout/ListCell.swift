//
//  ListCell.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/14/22.
//
import SwiftUI
import Foundation

struct DemoCell: View {
    @State private var isExpanded: Bool = false
    
    let result : ResultItem
    
    @Binding var isConnected: Bool
    
    var body: some View {
        
        content
            .frame(maxWidth: .infinity)
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            header
            if isExpanded {
                Group {
                    
                    DemoSubview(description: result.description, learnGuideLink: URLRequest(url: URL(string: result.learnGuideLink)!), compatibility: result.compatibility, isConnected: $isConnected)
                }
            }
        }
        
    }
    
    
    private var header: some View {
        HStack {
            
            Text(result.projectName)
            
                .font(Font.custom("ReadexPro-Regular", size: 24))
                .padding(8)
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.down")
                .resizable()
            
                .frame(width: 30, height: 15, alignment: .center)
            
                .foregroundColor(.white)
                .padding(.trailing, 30)
        }
        .padding(.vertical, 5)
        .padding(.leading)
        .frame(maxWidth: .infinity)
        .background(Color("pyleap_purple"))
        .onTapGesture { isExpanded.toggle() }
    }
    
    
    
    
}

struct DemoSubview: View {
    let description: String
    let learnGuideLink: URLRequest
    let compatibility: [String]
    
    @Binding var isConnected : Bool
    
    @State private var showWebViewPopover: Bool = false
    
    var body: some View {
        VStack {
            
            
            Image("product_image_cpb")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .cornerRadius(14)
                .padding(.leading, 30)
                .padding(.trailing, 30)
            
            //           GifImage("test")
            //               .frame(width: 300, height: 300, alignment: .center)
            //               .scaledToFit()
            //               .cornerRadius(35)
            
            Text(description)
                .font(Font.custom("ReadexPro-Regular", size: 18))
                .fontWeight(.regular)
                .multilineTextAlignment(.leading)
                .padding(.leading, 32)
                .padding(.trailing, 30)
            HStack {
                Text("Compatible with:")
                    .bold()
                
                Spacer()
            }
            .padding(.top, 5)
            
            HStack {
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(compatibility, id: \.self) { string in
                        if string == "circuitplayground_bluefruit" {
                            Text("Circuit Playground Bluefruit")
                                .font(Font.custom("ReadexPro-Bold", size: 17))
                        }
                        if string  == "clue_nrf52840_express" {
                            Text("Adafruit CLUE")
                                .font(Font.custom("ReadexPro-Bold", size: 17))
                        }
                        
                    }
                }
                
                Spacer()
                
            }
            .padding(.top, 5)
            
            
            Button(action: {
                showWebViewPopover = true
            }) {
                Text("Learn Guide")
                
                    .font(.custom("ReadexPro-Regular", size: 25))
                    .foregroundColor(Color("pyleap_purple"))
                    .padding(.leading, 60)
                    .padding(.trailing, 60)
                    .frame(height: 50)
                    .popover(
                        isPresented: self.$showWebViewPopover,
                        arrowEdge: .bottom
                    ) {
                        VStack{
                            WebView(URLRequest(url: learnGuideLink.url!))
                        }
                        
                        .padding(0)
                        
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke((Color("pyleap_purple")), lineWidth: 3.5)
                    )
            }
            
            if isConnected {
                
                
                //                Image(systemName: "checkmark")
                //                    .resizable()
                //                    .frame(width: 30, height: 22.4, alignment: .center)
                Text("Run It!")
                    .font(Font.custom("ReadexPro-Regular", size: 25))
                    .background(Color("pyleap_pink"))
                    .foregroundColor(Color.white)
                    .padding(.leading, 60)
                    .padding(.trailing, 60)
                    .frame(height: 50)
                    .cornerRadius(25)


                
            } else {
                
                
                NavigationLink(destination: RootView(), label: {
                    Text("Connect")
                        .font(Font.custom("ReadexPro-Regular", size: 25))
                        .background(Color("adafruit_blue"))
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 50)
                        .frame(height: 50)
                        .cornerRadius(25)
                }
                
                )
                   
                
            }
            
        }
        
        .padding(.top, 8)
    }
}
