//
//  CustomView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 11/4/21.
//

import SwiftUI


struct CustomView: View {
    @State var progressValue: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            Color.yellow
                .opacity(0.1)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressBar(progress: self.$progressValue)
                    .frame(width: 150.0, height: 150.0)
                    .padding(40.0)
                
                Button(action: {
                    self.incrementProgress()
                }) {
                    HStack {
                        Image(systemName: "plus.rectangle.fill")
                        Text("Increment")
                    }
                    .padding(15.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15.0)
                            .stroke(lineWidth: 2.0)
                    )
                }
                
                Spacer()
            }
        }
    }
    
    func incrementProgress() {
        let randomValue = CGFloat([0.012, 0.022, 0.034, 0.016, 0.11].randomElement()!)
        self.progressValue += randomValue
    }
}
struct ProgressBar: View {
    @Binding var progress: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 5)
                .opacity(0.3)
                .foregroundColor(Color.purple)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.purple)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)

        }
        .frame(width: 30, height: 30)
    }
}





struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        CustomView()
    }
}
