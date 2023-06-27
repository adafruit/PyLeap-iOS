//
//  OnboardingBackgroundView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 7/6/21.
//

import SwiftUI

struct OnboardingBackgroundView: View {
    
    @State var scale: CGFloat = 1
    
    var body: some View {
        ZStack {
            ForEach(0..<20) { _ in
                Circle()
                    .strokeBorder(Color(red: .random(in: 0...1),
                                        green: .random(in: 0...1),
                                        blue: .random(in: 0...1)),
                                  lineWidth: .random(in: 1...20))
                    .blendMode(.colorDodge)
                    .animation(Animation.easeInOut(duration: 0.05)
                                .repeatForever()
                                .speed(.random(in: 0.05...0.9))
                                .delay(.random(in: 0...2))
                    )
                    .scaleEffect(self.scale * .random(in: 0.1...3))
                    .frame(width: .random(in: 20...100),
                           height: CGFloat.random(in: 20...100),
                           alignment: .center)
                    .position(CGPoint(x: .random(in: 0...1112),
                                      y: .random(in: 0...834)))
                
            }
        }.onAppear {
            self.scale = 1.2
        }
    }
}

struct OnboardingBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingBackgroundView()
    }
}
