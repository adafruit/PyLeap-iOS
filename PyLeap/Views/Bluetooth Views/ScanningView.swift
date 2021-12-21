//
//  ScanningView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 7/6/21.
//

import SwiftUI

struct ScanningView: View {
    
    @State private var wave = false
    @State private var wave1 = false
    @State private var wave2 = false
    @State private var wave3 = false
    @State private var wave4 = false
    @State private var wave5 = false
    
    var body: some View {
        
        ZStack {

            Circle()
                .stroke(lineWidth: 5)
                .frame(width: 100, height: 100)
                .foregroundColor(Color(#colorLiteral(red: 0.8300942183, green: 0.4873027205, blue: 0.7138621807, alpha: 1)))
                .scaleEffect(wave ? 2 : 1)
                .opacity(wave ? 0 : 1)
                .onAppear(){
                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: false).speed(0.5)) {
                    self.wave.toggle()
                    }
                }
            
            Circle()
                .stroke(lineWidth: 5)
                .frame(width: 200, height: 200)
                .foregroundColor(Color(#colorLiteral(red: 0.8300942183, green: 0.4873027205, blue: 0.7138621807, alpha: 1)))
                .scaleEffect(wave1 ? 2 : 1)
                .opacity(wave1 ? 0 : 1)
                .onAppear(){
                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: false).speed(0.5)) {
                    self.wave1.toggle()
                    }
                }
            
            
            Circle()
                .stroke(lineWidth: 5)
                .frame(width: 300, height: 300)
                .foregroundColor(Color(#colorLiteral(red: 0.8300942183, green: 0.4873027205, blue: 0.7138621807, alpha: 1)))
                .scaleEffect(wave2 ? 2 : 1)
                .opacity(wave2 ? 0 : 1)
                .onAppear(){
                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: false).speed(0.5)) {
                    self.wave2.toggle()
                    }
                }
            
            Circle()
                .stroke(lineWidth: 5)
                .frame(width: 400, height: 400)
                .foregroundColor(Color(#colorLiteral(red: 0.8300942183, green: 0.4873027205, blue: 0.7138621807, alpha: 1)))
                .scaleEffect(wave3 ? 2 : 1)
                .opacity(wave3 ? 0 : 1)
                .onAppear(){
                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: false).speed(0.5)) {
                    self.wave3.toggle()
                    }
                }
            
            Circle()
                .stroke(lineWidth: 5)
                .frame(width: 500, height: 500)
                .foregroundColor(Color(#colorLiteral(red: 0.8300942183, green: 0.4873027205, blue: 0.7138621807, alpha: 1)))
                .scaleEffect(wave4 ? 2 : 1)
                .opacity(wave4 ? 0 : 1)
                .onAppear(){
                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: false).speed(0.5)) {
                    self.wave4.toggle()
                    }
                }
            
            Circle()
                .stroke(lineWidth: 5)
                .frame(width: 600, height: 600)
                .foregroundColor(Color(#colorLiteral(red: 0.8300942183, green: 0.4873027205, blue: 0.7138621807, alpha: 1)))
                .scaleEffect(wave5 ? 2 : 1)
                .opacity(wave5 ? 0 : 1)
                .onAppear(){
                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: false).speed(0.5)) {
                    self.wave5.toggle()
                    }
                }
        }
    }
}

struct ScanningView_Previews: PreviewProvider {
    static var previews: some View {
        ScanningView()
    }
}
