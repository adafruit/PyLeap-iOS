//
//  WifiServiceCellView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 11/7/22.
//

import SwiftUI

struct WifiServiceCellView: View {
   
    let resolvedService: ResolvedService
 
    @State private var isExpanded: Bool = false {
        didSet {
            onViewGeometryChanged()
        }
    }
    
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
                    WifiServiceCellSubView(resolvedService: resolvedService)
                }
                
            }
        }
    }
    
    func removeAdafruitString(text: String) -> String {
        if text.contains("Adafruit") {
            let parsed = text.replacingOccurrences(of: "Adafruit", with: "")
            return parsed
        } else {
            return text
        }
    }
    
    private var header: some View {
        
        
        
        HStack {
            Text(removeAdafruitString(text:resolvedService.device))
                .font(Font.custom("ReadexPro-Regular", size: 24))
                .minimumScaleFactor(0.1)
                .lineLimit(1)
              //  .padding(.horizontal, 30)
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.down")
                .resizable()
                .frame(width: 30, height: 15, alignment: .center)
                .foregroundColor(.white)
                .padding(.trailing, 30)
        }
        
        //.padding(.vertical, 5)
        .padding(.leading)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(Color("alt-gray"))
        .onTapGesture { isExpanded.toggle() }
    }
    
    
    
}
