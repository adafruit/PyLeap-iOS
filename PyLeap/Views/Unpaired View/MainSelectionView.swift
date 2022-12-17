//
//  MainSelectionView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 10/16/21.
//

import SwiftUI
import FileTransferClient

enum AdafruitDevices {
    case clue_nrf52840_express
    case circuitplayground_bluefruit
    case esp32s2
}

struct MainSelectionView: View {
    
    @State private var showWebViewPopover: Bool = false
    
    @State private var inConnectedInSelectionView = true
    @State private var boardBootInfo = ""
    @EnvironmentObject var expandedState : ExpandedBLECellState
    
    @ObservedObject var networkModel = NetworkService()
    @ObservedObject var viewModel = MainSelectionViewModel()
    
    
    @State private var isConnected = false
    
    @State private var test = ""
    
    @State private var nilBinder = DownloadState.idle
    @EnvironmentObject var rootViewModel: RootViewModel
   
    @AppStorage("shouldShowOnboarding") var shouldShowOnboarding: Bool = true
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0) {
            MainHeaderView()

            HStack(alignment: .center, spacing: 8, content: {
                Text("Not Connected to a Device.")
                    .font(Font.custom("ReadexPro-Regular", size: 16))
                Button {
                    rootViewModel.goToSelection()
                } label: {
                    Text("Connect Now")
                        .font(Font.custom("ReadexPro-Regular", size: 16))
                        .underline()
                }
                
            })
            .padding(.all, 0.0)
            .frame(maxWidth: .infinity)
            .frame(maxHeight: 40)
            .background(Color("pyleap_burg"))
            .foregroundColor(.white)
            
            ScrollView {
                
                MainSubHeaderView(device: "Adafruit device")
                
                if networkModel.pdemos.isEmpty {
                    HStack{
                        Spacer()
                        ProgressView()
                            .scaleEffect(2)
                        Spacer()
                    }
                    .padding(0)
                    
                }
                
                ScrollViewReader { scroll in
                    

                    
                    
                    ForEach(networkModel.pdemos) { demo in
                        
                        if demo.bundleLink == expandedState.currentCell {
                            
                            DemoViewCell(result: demo, isExpanded: true, isConnected: $inConnectedInSelectionView, deviceInfo: $boardBootInfo, onViewGeometryChanged: {
                            })
                            .onAppear(){
                                print("Cell Appeared")
                                withAnimation {
                                    scroll.scrollTo(demo.id)
                                }
                                
                            }
                            
                        } else {
                            
                            DemoViewCell(result: demo, isExpanded: false, isConnected: $inConnectedInSelectionView, deviceInfo: $boardBootInfo, onViewGeometryChanged: {
                                
                                
                            })
                            
                        }
                        
                    }
                    
                    
                }
            }
        }
        
        .onDisappear() {
            
        }
        
        /// **Pull down to Refresh feature**
        //            ScrollRefreshableView(title: "Refresh", tintColor: .purple) {
        //                HStack{
        //                    Spacer()
        //                    MainSubHeaderView()
        //                    Spacer()
        //                }
        //                .padding(0)
        //
        //                if networkModel.pdemos.isEmpty {
        //                    HStack{
        //                        Spacer()
        //                        ProgressView()
        //                            .scaleEffect(2)
        //                        Spacer()
        //                    }
        //                    .padding(0)
        //
        //                }
        //
        //        }//            } onRefresh: {
        //                self.networkModel.fetch()
        //            }
        //
        //            }
        
        
        .onChange(of: viewModel.pdemos, perform: { newValue in
            print("Update")
            
            
        })
        .onAppear() {
            
          //  networkModel.fetch()
            print("Opened MainSelectionView")
        }
        
        .fullScreenCover(isPresented: $shouldShowOnboarding, content: {
            ExampleView(shouldShowOnboarding: $shouldShowOnboarding)
        })
        .preferredColorScheme(.light)
        .background(Color.white)
        .navigationBarColor(UIColor(named: "pyleap_gray"))
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    
}


struct MainSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        MainSelectionView()
    }
}

