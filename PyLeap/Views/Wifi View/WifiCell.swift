//
//  WifiCell.swift
//  PyLeap
//
//  Created by Trevor Beaton on 9/1/22.
//

import SwiftUI
import Foundation

struct WifiCell: View {
    
    let result : ResultItem
    
    @State private var isExpanded: Bool = false {
        didSet {
            onViewGeometryChanged()
        }
    }
    
    @Binding var isConnected: Bool
    @Binding var bootOne: String
    @Binding var stateBinder: DownloadState
    
    var showRunItButton = false
    
    let onViewGeometryChanged: ()->Void
    
    var body: some View {
        content
            .frame(maxWidth: .infinity)
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
               
            if isExpanded {
                
                Group {
                    WifiSubViewCell(result: result, bindingString: $bootOne, downloadStateBinder: $stateBinder,isConnected: $isConnected)
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
