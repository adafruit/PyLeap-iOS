//
//  ScrollRefreshableView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 9/26/22.
//

import SwiftUI

struct ScrollRefreshableView<Content: View>: View {
  
    var content: Content
    var onRefresh: ()->()
    
    
    init(title: String, tintColor: Color, @ViewBuilder content: @escaping ()->Content, onRefresh: @escaping ()->()) {
        self.content = content()
        self.onRefresh = onRefresh
        
        UIRefreshControl.appearance().attributedTitle = NSAttributedString(string: title)
        UIRefreshControl.appearance().tintColor = UIColor(tintColor)
    }
    
    var body: some View {
            List {
               

                    content
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        
               

            }

            .listStyle(.plain)
            .refreshable {
                onRefresh()
            }
    }
        
}

struct ScrollRefreshableView_Previews: PreviewProvider {
    static var previews: some View {
        MainHeaderView()
    }
}
