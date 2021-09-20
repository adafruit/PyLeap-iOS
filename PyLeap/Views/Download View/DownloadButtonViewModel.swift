//
//  DownloadButtonViewModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/26/21.
//

import SwiftUI

struct DownloadButtonViewModel: View {
    
    @Binding var percentage : CGFloat
    
    var body: some View {
        ZStack {
            DownloadButtonView(percentage: $percentage)
        }
       
    }
}

struct DownloadButtonViewModel_Previews: PreviewProvider {
    static var previews: some View {
        DownloadButtonViewModel(percentage: .constant(0.2))
    }
}
