//
//  WifiCell.swift
//  PyLeap
//
//  Created by Trevor Beaton on 9/1/22.
//

import SwiftUI
import Foundation


class ExpandedState: ObservableObject {
    @Published var currentCell = ""
}



struct WifiCell: View {
    
    @EnvironmentObject var expandedState : ExpandedState
    
    let result : PyProject
    
    @State var isExpanded: Bool = false {
        didSet {
                onViewGeometryChanged()
        }
    }
   
    @State var isExpandedTest: String = ""
    
    
    @ObservedObject var viewModel = WifiCellViewModel()
    @Binding var isConnected: Bool
    @Binding var bootOne: String
    @Binding var stateBinder: DownloadState
    
    var showRunItButton = false
    
    var projectName = String()
    
    let onViewGeometryChanged: ()->Void
    
    var body: some View {
        content
            .frame(maxWidth: .infinity)
    }
    
    var header: some View {
       
       HStack {
           Text(result.projectName)
               .font(Font.custom("ReadexPro-Regular", size: 24))
               .padding(8)
               .foregroundColor(.white)
           
           Spacer()
           
           Image(systemName: "chevron.down")
               .resizable()
               .scaledToFit()
               .frame(width: 30, height: 15, alignment: .center)
               .foregroundColor(.white)
               .padding(.trailing, 30)
       }
           
       
       .padding(.vertical, 5)
       .padding(.leading)
       .frame(maxWidth: .infinity)
       .background(Color("pyleap_purple"))
       .onTapGesture {
           expandedState.currentCell = result.bundleLink
       }
       

       
   }
    
    
     var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            
            if isExpanded  {
                Group {
                    WifiSubViewCell(result: result, bindingString: $bootOne, downloadStateBinder: $stateBinder,isConnected: $isConnected)
                       
                }
            }
        }
    }
    

    

    
}
