//
//  PyLeap
//
//  Created by Trevor Beaton on 6/28/21.
//

import SwiftUI

struct BTConnectionView: View {
    
    @StateObject private var model = BTConnectionViewModel()
    @Binding var isVisible: Bool
    var projects: [Project] = ProjectData.projects
    
    
    var body: some View {
        
       // NavigationLink(destination: ProjectCardView(fileTransferClient: AppState.shared.fileTransferClient, project: projects.first!),tag: .fileTransfer, selection: $model.destination) { EmptyView() }
        
        NavigationLink(destination: SelectionView(fileTransferClient: AppState.shared.fileTransferClient),tag: .selectionView,selection: $model.destination) { EmptyView()}
        
     //   NavigationLink(destination: ProjectCardView(fileTransferClient: AppState.shared.fileTransferClient, project: ProjectState.shared.projectSingleton ?? ProjectData.helloWorld),tag: .projectView,selection: $model.destination) { EmptyView()}
        
        
        
        ZStack{
            
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
                    Text(model.detailText)
                        .bold()
                }
                .font(.custom("SF Pro", size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            
        }
        .onChange(of: isVisible) { isVisible in
            // onAppear doesn't work on navigationItem so pass the onAppear/onDissapear via binding variable: https://developer.apple.com/forums/thread/655338

            if isVisible {
                model.onAppear()
                print("is Visible")
            }
            else {
                model.onDissapear()
                print("not Visible")
            }
        }
        .navigationBarHidden(false)
        .foregroundColor(Color.white)
    }
}



struct ScanningAnimation_Previews: PreviewProvider {
    static var previews: some View {
        BTConnectionView(isVisible: .constant(true))
    }
}


