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
    @State private var nextText = 0
    @State var showSheetView = false
    @State var showConnectionErrorView = false
    var body: some View {
        
        VStack{
            
            HStack {
                
                Button {
                                           
                    self.rootViewModel.goToMain()
                } label: {
                    Image(systemName: "arrow.backward")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30, alignment: .center)
                        .foregroundColor(Color("pyleap_gray"))
                }
                
                
                
                
                Spacer()
                Image("bluetooth")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30, alignment: .center)
                    .offset(y: -5)
                
                    .onReceive(timer) { _ in
                        nextText = 1
                        timer.upstream.connect().cancel()
                    }
            }
            .padding(.top, 50)
            .padding(.horizontal, 30)
            
            
            
            Image("pyleapLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.top, 50)
                .padding(.horizontal, 60)
            
                .sheet(isPresented: $showConnectionErrorView) {
                    TroubleshootView()
                }
            
            
            if nextText == 0 {
                
                
                
                Text("Searching for PyLeap compatible device...")
                    .padding(.horizontal, 30)
                    .font(Font.custom("ReadexPro-Regular", size: 24))
                    .minimumScaleFactor(0.1)
                    .padding(.horizontal, 30)
                
                Spacer()
                
                BlinkaAnimationView()
                    .minimumScaleFactor(0.1)
                    .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0.0))
                
                Spacer()
                
                    .onAppear() {
                        Animation.linear(duration: 1.0)
                            .repeatForever(autoreverses: false)
                        isAnimating = true
                    }
                
                Text(detailText)
                    .font(Font.custom("ReadexPro-Regular", size: 24))
                
                Button(action: {
                    nextText = 1
                    timer.upstream.connect().cancel()
                }) {
                    PairingTutorialButton()
                }
                
                Spacer()
                    .frame(height: 60)
            }
            
            
            
            if nextText == 1 {
                
                
                
                Text("""
        No device found.
        
        First, disconnect your device from your computer, and connect it to a Lipoly battery, AAA battery or USB wall power.
        """)
                .font(Font.custom("ReadexPro-Regular", size: 36))
                .minimumScaleFactor(0.01)
                .multilineTextAlignment(.center)
                .padding(.top, 100)
                .padding(.horizontal, 30)
                .padding(.bottom, 69)
                
                
                Spacer()
                
                Button(action: {
                    nextText = 2
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
                    .frame(height: 60)
                
            }
            
            if nextText == 2 {
                
                
                Text("""
        Press the RESET button on your board, then press it one more time.
        
        The LED(s) on your board should be flashing blue.
        """)
                .font(Font.custom("ReadexPro-Regular", size: 36))
                .minimumScaleFactor(0.01)
                .multilineTextAlignment(.center)
                .padding(.top, 100)
                .padding(.horizontal, 30)
                .padding(.bottom, 69)
                
                //                    GifImage("pairingAnimation")
                //                        .frame(width: 300, height: 300, alignment: .center)
                //                        .padding(.horizontal, 10)
                //
                Spacer()
                
                Button(action: {
                    nextText = 3
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
                    .frame(height: 60)
                
            }
            
            if nextText == 3 {
                
                Text("""
    After clicking the button below, your phone will ask you to pair. Click the Pair button.
    """)
                .font(Font.custom("ReadexPro-Regular", size: 36))
                .minimumScaleFactor(0.01)
                .multilineTextAlignment(.center)
                .padding(.top, 100)
                .padding(.horizontal, 20)
                
                Image("connectionRequest")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, 31)
                    .padding(.horizontal, 45)
                    .padding(.bottom, 30)
                
                
                Spacer()
                
                Button(action: {
                    nextText = 0
                }) {
                    
                    Text("Pair Device")
                        .font(Font.custom("ReadexPro-Regular", size: 25))
                        .foregroundColor(Color.white)
                    
                    
                        .padding(.horizontal, 60)
                    
                        .frame(height: 50)
                        .background(Color("pyleap_pink"))
                        .clipShape(Capsule())
                    
                }
                Spacer()
                    .frame(height: 60)
                
            }
            
            
            
            
            
            
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
        
        .onChange(of: model.errorStatus) { value in
            if value == .peerInformationError {
                showConnectionErrorView = true
                print("error good")
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
                //self.showSheetView.toggle()
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


