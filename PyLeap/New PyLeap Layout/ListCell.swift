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
    
    var body: some View {
        
        content
            .frame(maxWidth: .infinity)
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            header
            if isExpanded {
                Group {
                    
                    DemoSubview(description: result.description, learnGuideLink: URLRequest(url: URL(string: result.learn_guide_link)!), compatibility: result.compatibility)
                }
            }
        }
        
    }
    
    
    private var header: some View {
        HStack {
            
            Text(result.project_name)
            
                .font(Font.custom("ReadexPro-VariableFont_wght", size: 24))
                .fontWeight(.bold)
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
    var isConnect = false
    
//    private let test: Bool
//
//    init(_ name: URLRequest) {
//        self.learnGuideLink = name
//    }
    
    @State private var showWebViewPopover: Bool = false
    
    var body: some View {
        VStack {
            
            Image("product_image_cpb")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
            
            //           GifImage("test")
            //               .frame(width: 300, height: 300, alignment: .center)
            //               .scaledToFit()
            //               .cornerRadius(35)
            
            Text(description)
                .font(Font.custom("ReadexPro-VariableFont_wght", size: 17))
                .fontWeight(.regular)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 10)
                .padding(.top, 8)
            
            HStack {
                Text("Compatible with:")
                    .bold()
                
                Spacer()
            }
            .padding(.top, 5)
            
            VStack(alignment: .trailing, spacing: 8) {
                ForEach(compatibility, id: \.self) { string in
                    Text(string)
                        .bold()
                }
            }
            .padding(0)
//            HStack {
//                Image(systemName: "checkmark")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .foregroundColor(.green)
//                    .frame(width: 16, height: 16, alignment: .center)
//                    .padding(5)
//                Text(compatibility.first!)
//                    .bold()
//
//                Spacer()
//            }
//            .padding(0)
            
            
            
            Button(action: {
                showWebViewPopover = true
            }) {
                Text("Learn Guide")
                
                    .font(.custom("ReadexPro", size: 25))
                    .fontWeight(.ultraLight)
                    .foregroundColor(Color("pyleap_purple"))
                    .padding(.horizontal, 50)
                    .padding(.vertical, 8)
                
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
            .padding(5)
            
            
            
                NavigationLink(destination: RootView(), label: {
                    Text("Connect")
                        .font(Font.custom("ReadexPro-VariableFont_wght", size: 25))
                        .padding(.horizontal, 75)
                        .padding(.vertical, 8)
                        .background(Color("adafruit_blue"))
                        .foregroundColor(Color.white)
                        .cornerRadius(30)
                })
                    .padding(10)
            
           
            
        }
    }
}
