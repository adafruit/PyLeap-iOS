//
//  PyLeap
//
//  Created by Trevor Beaton on 6/28/21.
//

import SwiftUI

struct BTConnectionView: View {
    
    @StateObject private var model = BTConnectionViewModel()
    @EnvironmentObject var rootViewModel: RootViewModel
    //var projects: [Project] = ProjectData.projects
    
    var body: some View {
        
       // NavigationView {
            
            ZStack{
                //NavigationLink(destination: ProjectCardView(project: projects.first!),tag: .fileTransfer, selection: $model.destination) { EmptyView() }
             
                Color(#colorLiteral(red: 0.5275210142, green: 0.4204645753, blue: 0.6963143945, alpha: 1)).edgesIgnoringSafeArea(.all)
                
                
                VStack{
                    
                    Group{
                        
                        Text("Hold your device closely to your mobile device.")
                            .foregroundColor(.white)
                            .bold()
                            .font(.custom("SF Pro", size: 15))
                            .padding(.top, 90)
                        
                    }
                    
                    Spacer()
                    
                    ZStack{
                        
                        Text("  ")
                            .fontWeight(.semibold)
                            .font(.system(size: 55))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Found peripherals: \(model.numPeripheralsScanned)")
                        Text("Adafruit peripherals: \(model.numAdafruitPeripheralsScanned)")
                        Text("FileTransfer peripherals: \(model.numAdafruitPeripheralsWithFileTranferServiceScanned)")
                        Text("FileTransfer peripherals nearby: \(model.numAdafruitPeripheralsWithFileTranferServiceNearby)")
                        Text("Status: ")
                        Text(detailText)
                            .bold()
                    }
                    .font(.custom("SF Pro", size: 15))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                
            }
            .navigationBarHidden(false)
            .foregroundColor(Color.white)
        /*}
        .navigationViewStyle(StackNavigationViewStyle())*/
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


