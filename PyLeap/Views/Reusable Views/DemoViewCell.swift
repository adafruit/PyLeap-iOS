//
//  ListCell.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/14/22.
//
import SwiftUI
import Foundation

struct DemoViewCell: View {
    
    
    
    @StateObject var spotlight = SpotlightCounter()
    
    let result : ResultItem
    @State private var isExpanded: Bool = false {
        didSet {
            onViewGeometryChanged()
        }
    }
    @Binding var isConnected: Bool
    @Binding var bootOne: String
   
    let onViewGeometryChanged: ()->Void
    
    @Binding var stateBinder: DownloadState
    
    var body: some View {
        content
            .frame(maxWidth: .infinity)
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
               
            
            
            
            if isExpanded {
                
                Group {
                    DemoSubview(bindingString: $bootOne, downloadStateBinder: $stateBinder, title: result.projectName,
                                image: result.projectImage,
                                description: result.description,
                                learnGuideLink: URLRequest(url: URL(string: result.learnGuideLink)!),
                                downloadLink: result.bundleLink,
                                compatibility: result.compatibility,
                                isConnected: $isConnected)
                }
                .onTapGesture {
                    print("sub \(spotlight.counter)")
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
