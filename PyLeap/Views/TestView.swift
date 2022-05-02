//
//  TestView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 2/14/22.
//

import SwiftUI

struct TestingView: View {
    
   // @StateObject private var model = RootViewModel()
    
    var body: some View {
 
            VStack {
                Button {
                   // model.goToTest()
                    print("Let's Go!")
                } label: {
                    Text("Great! Testing View is visible. Now go back to Main View.")
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

