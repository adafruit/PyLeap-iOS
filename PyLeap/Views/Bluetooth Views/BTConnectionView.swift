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
    
    init() {
        let navBarAppearence = UINavigationBarAppearance()
        UINavigationBar.appearance().tintColor = UIColor.white
    }
    
    var body: some View {
        
        
        ZStack {
            
            NavigationView {
                
                ZStack{
                    
                    Color(#colorLiteral(red: 0.5275210142, green: 0.4204645753, blue: 0.6963143945, alpha: 1)).edgesIgnoringSafeArea(.all)
                    
                    VStack{
                        HStack {
                            Spacer()
                            
                            Button {
                                self.showModal.toggle()
                            } label: {
                                Image(systemName: "info.circle.fill")
                                    .frame(width: 50, height: 50)
                                    .padding(3)
                            }
                        }
                      //  .border(Color(red: 1.0, green: 0.0, blue: 1.0, opacity: 0.6), width: 3)
                      //  Spacer()
                         //   .border(Color(red: 1.0, green: 0.0, blue: 1.0, opacity: 0.6), width: 3)
                        
                        
                        
                        Text("Press the RESET button in the center of the board")
                            .font(.system(size: 15))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(3)
                           // .border(Color(red: 1.0, green: 0.0, blue: 1.0, opacity: 0.6), width: 3)
                        Text("Then press RESET again while LEDs flashes blue")
                            .font(.system(size: 15))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.top,3)
                         //   .border(Color(red: 1.0, green: 0.0, blue: 1.0, opacity: 0.6), width: 3)
                        
                        ZStack {
                            
                            ScanningView()
                            
                            Image("cpb")
                                .resizable(resizingMode: .stretch)
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.white)
                                .frame(width: 200, height: 200)
                            
                        }
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 3)
                        //.border(Color(red: 1.0, green: 0.0, blue: 1.0, opacity: 0.6), width: 3)
                        Text("Hold your Bluefruit device closely to your mobile device")
                            .font(.system(size: 15))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Text("Unplug Circuit Playground Bluefruit from USB")
                            .bold()
                            .font(.system(size: 15))
                            .foregroundColor(.red)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top,5)
                            .multilineTextAlignment(.center)
                          //  .border(Color(red: 1.0, green: 0.0, blue: 1.0, opacity: 0.6), width: 3)
                       
                        Spacer()
                           
                        
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Devices found: \(model.numPeripheralsScanned)")
                            Text("Adafruit devices found: \(model.numAdafruitPeripheralsScanned)")
                            Text("PyLeap enabled devices found: \(model.numAdafruitPeripheralsWithFileTranferServiceNearby)")
                            Text("Status: ")
                            Text(detailText)
                                .bold()
                        }
                        .font(.system(size: 15))
                      //  .border(Color(red: 1.0, green: 0.0, blue: 1.0, opacity: 0.6), width: 3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(5)
                    }
                   // .border(Color(red: 1.0, green: 0.0, blue: 1.0, opacity: 0.6), width: 3)
                    .navigationBarTitle("Searching...")
                    
                    .foregroundColor(Color.white)
                    
                    
                }
                //                .toolbar {
                //                    Button {
                //                        self.showModal.toggle()
                //                    } label: {
                //                        Image(systemName: "info.circle.fill")
                //
                //                    }
                //
                //                    .foregroundColor(.white)
                //                  //  .padding(15)
                //                    .border(Color(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.497), width: 3)
                //                }
                
                
            }
            
            ZStack {
                HStack {
                    Spacer()
                    VStack {
                        
                        HStack {
                            Button(action: {
                                // trigger modal presentation
                                withAnimation {
                                    self.showModal.toggle()
                                }
                                
                            }, label: {
                                Text("Dismiss")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            })
                            Spacer()
                            
                        }
                        .padding(.top, UIApplication.shared.windows.filter{$0.isKeyWindow}.first?.safeAreaInsets.top)
                        
                        
                        VStack(alignment: .leading) {
                            Group {
                                
                                Text("Welcome to PyLeap")
                                    .bold()
                                    .font(.system(size: 26))
                                
                                Text("""
PyLeap provides you with a variety of example projects to communicate with the Circuit Playground Bluefruit.

First, follow the instructions here to load the correct firmware. Then, connect your Bluefruit device to a battery source.

""")
                                Text("Do not connect your Bluefruit to a computer.")
                                    .bold()
                                
                                Text("""
First, follow the instructions here to load the correct firmware. Then, connect your Bluefruit device to a battery source.

Once your Bluefruit device is powered, move it towards your iPhone and prepare to pair.
""")
                                
                                
                                
                                Divider()
                            }
                            Group {
                                Text("Pairing mode")
                                    .bold()
                                    .font(.system(size: 26))
                                Text("""
Once powered, press the reset button in the center of the board.

Press the reset button again while LEDs are flashing blue, then hold the board closely to your mobile device.
""")
                                
                            }
                            
                            
                            //                            Group {
                            //                                Text("Troubleshooting")
                            //                                    .bold()
                            //                                    .font(.system(size: 25))
                            //                                Text("1. Turn on your Bluefruit device.")
                            //
                            //                                Text("Make sure that the Bluefruit device is connected to a battery power source and not connected to a computer.")
                            //
                            //
                            //                                Text("2. Check the Bluefruit device's firmware")
                            //                                Text("You'll need to load the newest firmware on your device to interact with this app.")
                            //
                            //                                Text("Currently PyLeap requires a Circuit Playground Bluefruit board running the most recent build of Circuit Python 7. If you haven't already, you'll need to download the latest version of CircuitPython from the link below.")
                            //
                            //                                Link("Circuit Python", destination: URL(string: "https://circuitpython.org/board/circuitplayground_bluefruit/")!)
                            //
                            //                            }
                            
                            
                            
                        }
                        .padding(10)
                        .font(.system(size: 15))
                        Spacer()
                    }//
                    
                    
                    Spacer()
                }
                
                
                
                
                
            }
            .background(Color(#colorLiteral(red: 0.5275210142, green: 0.4204645753, blue: 0.6963143945, alpha: 1)))
            .edgesIgnoringSafeArea(.all)
            .offset(x: 0, y: self.showModal ? 0 : UIApplication.shared.keyWindow?.frame.height ?? 0)
            
        }
        .preferredColorScheme(.dark)
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
        BTConnectionView()
    }
}


