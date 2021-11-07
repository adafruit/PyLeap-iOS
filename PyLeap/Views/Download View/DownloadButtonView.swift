
//  PyLeap
//
//  Created by Trevor Beaton on 8/24/21.
//

import SwiftUI

struct DownloadButtonView: View {
    
    @StateObject var model = DownloadViewModel()
    
   
    @State var circleOpacity: Double = 1
    @State var iconSize : Int = 20
    @State var test: Double = 0.0
    @Binding var percentage : CGFloat
    
    var body: some View {
     
        
        
        VStack {
            
            ZStack {
                
                Circle()
                    .stroke(lineWidth: 4)
                    .opacity(0.2)
                    .foregroundColor(.gray)
                
                if percentage  == 0 {
                    Image(systemName: "arrow.down")
                        .foregroundColor(.purple)
                        .font(.system(size: CGFloat(iconSize), weight: .semibold))
                        .animation(Animation.linear(duration: 5.0))
                }
                
                if percentage == 1.0 {
                    
                    Image(systemName: "checkmark")
                        .foregroundColor(.purple)
                        .font(.system(size: CGFloat(iconSize), weight: .semibold))
                        .animation(Animation.linear(duration: 5.0))
                }
                
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(percentage))
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.purple)
                    .animation(Animation.linear(duration: 0.5))
                    .rotationEffect(.degrees(-90))
                    .opacity(circleOpacity)
            }
            
            //MARK:- ZStack End
            .frame(width: 35, height: 35, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .padding(.horizontal, 2)
            .rotationEffect(/*@START_MENU_TOKEN@*/.zero/*@END_MENU_TOKEN@*/)
            
            //MARK:- VStack End
            //            Text(String(format: "%.0f%%", min(self.progressPercentage,1) * 100 ))
            //                .fontWeight(.medium)
            //                .offset(x: 5)
            //                .padding(1)
        }
        
    }
}

struct DownloadButton_Previews: PreviewProvider {
    static var previews: some View {
        DownloadButtonView(percentage: .constant(0.2))
    }
}
