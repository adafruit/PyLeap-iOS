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

    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
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
            

            Image("pyleapLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
              //  .offset(y: -20)
               // .padding(.top, 100)
                .padding(.horizontal, 60)

            
            if userWaitThreshold == false {
                
                
                Text("Searching for device...")
                    .font(Font.custom("ReadexPro-Regular", size: 36))
                    //.padding(.top, 100)
                    .padding(.horizontal, 20)
                
                    Spacer()
                BlinkaAnimationView()
                    .minimumScaleFactor(0.1)
                    .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0.0))
                
                    Spacer()
                
                    .onAppear(){
                        Animation.linear(duration: 1.0)
                            .repeatForever(autoreverses: false)
                        isAnimating = true
                    }
                
                
            } else {
                
                
                if nextText == false {
                    
                    Text("""
        No device found.

        First, disconnect your device from your computer, and connect it to a  Lipoly battery, AAA battery or USB wall power.

        """)
                        .font(Font.custom("ReadexPro-Regular", size: 36))
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                      //  .padding(.top, 100)
                        .padding(.horizontal, 20)
                    
                    
                    Spacer()
                    
                    Button(action: {
nextText = true
                    }) {
                        
                        Text("Next Step")
                            .font(Font.custom("ReadexPro-Regular", size: 25))
                            .foregroundColor(Color.white)
                            
                            .padding()
                            .padding(.horizontal, 60)
                            
                            .frame(height: 50)
                            .background(Color("pyleap_pink"))
                            .clipShape(Capsule())

                    }
                    Spacer()
                        .frame(height: 14)
                    
                } else {
                    
                    Text("""
                  Press the RESET button on your board. When the LED(s) quickly flash blue, press RESET one more time.
                  
                  The LED(s) on your board should be flashing blue.
                  """)
                                  .font(Font.custom("ReadexPro-Regular", size: 32))
                                  .minimumScaleFactor(0.01)
                                  .multilineTextAlignment(.center)
                                 .padding(.horizontal, 20)
                    
                    
                    Spacer()
                    
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
                    Spacer()
                        .frame(height: 14)
                    
                }
                

            }
            

           // Spacer()
        }
        
        .edgesIgnoringSafeArea(.all)

        .onAppear {
            print("BTConnectionView")
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
                .previewDevice("iPhone SE (2nd generation)")
            BTConnectionView()
                .previewDevice("iPad Pro (11-inch) (3rd generation)")
        }
    }
}


