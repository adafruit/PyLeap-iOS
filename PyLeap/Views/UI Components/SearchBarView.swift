//
//  SearchBarView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/12/21.
//

import SwiftUI

struct SearchBarView: View {
    
    @State private var text: String = ""
    @State private var isEditing = false
    
    var body: some View {
        //MARK:-  Search Bar UI
        
        HStack {
            
            Spacer()
            
            Button(action: {
               print("Do something")
            }, label: {
                Image(systemName:"plus")
                    .font(.title)
            })
            
        }
        
        HStack {
            
            TextField("Search ...", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
                }
            
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
                    
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
        .overlay(
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
                
                if isEditing {
                    Button(action: {
                        self.text = ""
                    }) {
                        Image(systemName: "multiply.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                }
            }
        )
        
        }
    }


struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView()
    }
}
