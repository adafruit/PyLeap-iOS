//
//  TestView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 2/14/22.
//

import SwiftUI

struct ReconnectionView: View {

    @Environment(\.presentationMode) var presentation
    @StateObject private var model = BTConnectionViewModel()
    @EnvironmentObject var rootViewModel: RootViewModel
    
    @State private var isAnimating = false
    
    var body: some View {
 
        VStack {
            
            Image("pyleapLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .offset(y: -20)
            
            BlinkaAnimationView()
                .minimumScaleFactor(0.1)
                .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0.0))
            
                .onAppear(){
                    Animation.linear(duration: 1.0)
                        .repeatForever(autoreverses: false)
                    isAnimating = true
                }
            
            HStack(alignment: .center, spacing: 8, content: {
                Text("Reconnecting...")
                .font(Font.custom("ReadexPro-Regular", size: 36))
                .padding(.horizontal, 20)
            })
            
           

        }
        .padding(.horizontal, 20)
        .edgesIgnoringSafeArea(.all)
            .onAppear {
                print("ReconnectionView")
                model.onAppear()
            }
            .onDisappear {
                model.onDissapear()
            }
            .onChange(of: model.destination) { destination in
                if destination == .fileTransfer {
                    self.rootViewModel.goToFileTransfer()
                }
            }
        }
        
    
}

struct MainView: View {
    
    @State private var isActive: Bool = false
    
    var body: some View {
        NavigationView {
            
            VStack {
                MainSelectionView()
            }
            .navigationTitle("PyLeap")
        }
    }
}

struct FirstOnboardingStep: View {
   
    var data: OnboardingDataModel
    @State private var isAnimating: Bool = false
    @State private var isActive: Bool = false
   
    var body: some View {
        
        VStack {
            Image(data.image)
                .resizable()
                .scaledToFit()
                .scaleEffect(isAnimating ? 1 : 0.6)
                .onAppear(perform: {
                    isAnimating = false
                    withAnimation(.easeOut(duration: 0.5)) {
                        self.isAnimating = true
                        
                    }
                })
            
            Text(data.heading)
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color(#colorLiteral(red: 0.5275210142, green: 0.4204645753, blue: 0.6963143945, alpha: 1)))
                .font(.custom("SF Pro", size: 15))
            
            Text(data.text)
                .font(.headline)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 350)
                .foregroundColor(Color(#colorLiteral(red: 0.5275210142, green: 0.4204645753, blue: 0.6963143945, alpha: 1)))
                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
        }
        // Always on Light Mode.
        //.preferredColorScheme(.light)
        .padding()
    }
}

