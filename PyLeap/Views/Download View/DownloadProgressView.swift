//
//  DownloadProgressView.swift
//  SwiftUI File Manager
//
//  Created by Trevor Beaton on 7/5/21.
//

import SwiftUI

struct DownloadProgressView: View {
   // Tethers two variables together from another view model
    @Binding var progress: CGFloat

     
    var body: some View {
        ZStack {
            Color.primary
                .opacity(0.25)
                .ignoresSafeArea()
            
            VStack(spacing: 15) {
                
                ZStack {
                    // Custom Circle
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                    
                    ProgressShape(progress: progress)
                        .fill(Color.gray.opacity(0.4))
                        .rotationEffect(.init(degrees: -90))
                }
                .frame(width: 70, height: 70)
                
                //  Cancel Button
                Button(action: {
             //       downloadModel.cancelTask()
                }, label: {
                    Text("Cancel")
                        .fontWeight(.semibold)
                })
                .padding(.top)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 50)
            .background(Color.white)
            .cornerRadius(8)
        }
    }
}

struct DownloadProgressView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadProgressView(progress: .constant(0.05))
    }
}


struct ProgressShape: Shape {
    
    var progress: CGFloat
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.midY))
            
            path.addArc(center: CGPoint(x: rect.midX, y:rect.midY), radius: 35, startAngle: .zero, endAngle: .init(degrees: Double(progress * 360)), clockwise: false)
            
        }
    }
}
