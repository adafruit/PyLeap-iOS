//
//  PyLeap
//
//  Created by Trevor Beaton on 6/28/21.
//

import SwiftUI

struct BTConnectionView: View {
    
    @Environment(\.presentationMode) var presentation
    @StateObject private var model = BTConnectionViewModel()
    @EnvironmentObject var rootViewModel: RootViewModel
    @State private var showModal = false

    let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    @State private var isAnimating = false
    @State private var showProgress = false
    var foreverAnimation: Animation {
        Animation.linear(duration: 2.0)
            .repeatForever(autoreverses: false)
    }
    @State private var userWaitThreshold = false
    @State private var nextText = false
    
    
    var body: some View {
        
        
        
        VStack{
           
            HStack {
                
                Spacer()
                Image("bluetooth")
                    .resizable()
                    
                    .aspectRatio(contentMode: .fit)
                    
                    .frame(width: 30, height: 30, alignment: .center)
                    .padding(35)
                    .onReceive(timer) { _ in
                        userWaitThreshold = true
                        timer.upstream.connect().cancel()
                    }
            }
            
            Spacer()
            
            Image("pyleapLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
              //  .offset(y: -20)
               // .padding(.top, 100)
                .padding(.horizontal, 60)

            
            if userWaitThreshold == false {
                
                Spacer()
                Text("Searching for your Bluefruit device...")
                    .font(Font.custom("ReadexPro-Regular", size: 36))
                    //.padding(.top, 100)
                    .padding(.horizontal, 20)
                
                BlinkaAnimationView()
                    .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0.0))
                
                
                
                    .onAppear(){
                        Animation.linear(duration: 1.0)
                            .repeatForever(autoreverses: false)
                        isAnimating = true
                    }
                
                
            } else {
                
                
                if nextText == false {
                    
                    Text("""
        No device found.
        Let's fix this.

        First, disconnect your device from USB and connect to a battery.

        """)
                        .font(Font.custom("ReadexPro-Regular", size: 36))
                        .multilineTextAlignment(.center)
                      //  .padding(.top, 100)
                        .padding(.horizontal, 30)
                        
                    Button(action: {
nextText = true
                    }) {
                        
                        Text("Next Step")
                            .font(Font.custom("ReadexPro-Regular", size: 25))
                            .foregroundColor(Color.white)
                            .padding(.horizontal, 60)
                            .frame(height: 50)
                            .background(Color("pyleap_pink"))
                            .clipShape(Capsule())
                    }
                    
                    
                } else {
                    
                    Text("""
                  Press the RESET button on your board, the press it one more time.
                  
                  The LEDs on your board should be flashing blue.
                  """)
                                  .font(Font.custom("ReadexPro-Regular", size: 32))
                                  .multilineTextAlignment(.center)
                                  //.padding(.top, 108.7)
                                 .padding(.horizontal, 30)
                    
                    
                    Button(action: {
nextText = false
                    }) {
                        
                        Text("Back")
                            .font(Font.custom("ReadexPro-Regular", size: 25))
                            .foregroundColor(Color.white)
                            .padding(.horizontal, 60)
                            .frame(height: 50)
                            .background(Color("pyleap_pink"))
                            .clipShape(Capsule())
                    }
                    
                    
                }
                

            }
            

            Spacer()
        }
        
        .edgesIgnoringSafeArea(.all)
        //.preferredColorScheme(.dark)
        .onAppear {
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
    
    // MARK: - UI
    private var detailText: String {
        let text: String
        switch model.connectionStatus {
        case .scanning:
            text = "Scanning..."
        case .restoringConnection:
            text = "Restoring connection..."
        case .connecting:
            text = "Connecting..."
        case .connected:
            text = "Connected..."
        case .discovering:
            text = "Discovering Services..."
        case .fileTransferError:
            text = "Error initializing FileTransfer"
        case .fileTransferReady:
            text = "FileTransfer service ready"
        case .disconnected(let error):
            if let error = error {
                text = "Disconnected: \(error.localizedDescription)"
            } else {
                text = "Disconnected"
            }
        }
        return text
    }
}


struct BTConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BTConnectionView()
                .previewDevice("iPhone SE (2nd generation)")
            BTConnectionView()
                .previewDevice("iPad Pro (11-inch) (3rd generation)")
        }
    }
}


