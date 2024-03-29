//
//  ScanningView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 7/6/21.
//

import SwiftUI

struct BlinkaAnimationView: View {

    @State private var isAnimating = false
       @State private var showProgress = false
       var foreverAnimation: Animation {
           Animation.linear(duration: 4.0)
               .repeatForever(autoreverses: false)
       }
    
    var height: CGFloat
    var width: CGFloat
    
    var body: some View {
        
        ZStack {
            Image("BlinkaLoading")
                .resizable(resizingMode: .stretch)
                .aspectRatio(contentMode: .fit)
                .frame(width: width, height: height)
                .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0.0))
                .animation(self.isAnimating ? foreverAnimation : .default)
            
                .onAppear { self.isAnimating = true }
        
        }
    }
}

struct ScanningView_Previews: PreviewProvider {
    static var previews: some View {
        BlinkaAnimationView(height: 300, width: 300)
    }
}
