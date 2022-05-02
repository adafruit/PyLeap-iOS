//
//  DemoSubCellView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/23/22.
//

import SwiftUI
import FileTransferClient

class GlobalString: ObservableObject {
    @Published var projectString = ""
    @Published var compatibilityString = ""
    
    @Published var counterG = 0
    @Published var numberOfFilesG = 0
    @Published var isSendingG = false
    @Published var bundleHasBeenDownloaded = false
    @Published var numberOfTimesDownloaded = 0
}

struct DemoSubview: View {
    @State var transferInProgress = false
    @State var isDownloaded = false
    
    @EnvironmentObject var globalString : GlobalString
    
    @Binding var bindingString: String
    
    @Binding var downloadStateBinder: DownloadState
    
    @State private var toggleView: Bool = false
    
    let title: String
    let image: String
    let description: String
    let learnGuideLink: URLRequest
    let downloadLink: String
    let compatibility: [String]
    
    @EnvironmentObject var rootViewModel: RootViewModel
    @StateObject var downloadModel = DownloadViewModel()
    @StateObject var viewModel = SubCellViewModel()
    @StateObject var selectionModel = SelectionViewModel()
    
    @Binding var isConnected : Bool
    
    @State private var showWebViewPopover: Bool = false
    @State var errorOccured = false
    
    
    var body: some View {
        
        VStack {
            ImageWithURL(image)
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .cornerRadius(14)
                .padding(.leading, 30)
                .padding(.trailing, 30)
            
            
            
//            AsyncImage(url: URL(string: image)) { image in
//                image.resizable()
//                    .scaledToFit()
//                    .frame(maxWidth: .infinity)
//                    .cornerRadius(14)
//                    .padding(.leading, 30)
//                    .padding(.trailing, 30)
//            } placeholder: {
//                ProgressView()
//                    .frame(width: 100, height: 100)
//            }

            
            VStack(alignment: .leading, spacing: 10) {
                Text(description)
                    .font(Font.custom("ReadexPro-Regular", size: 18))
                    .fontWeight(.regular)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.1)
                Text("Compatible with:")
                    .font(Font.custom("ReadexPro-SemiBold", size: 18))
                
                ForEach(compatibility, id: \.self) { string in
                    if string == "circuitplayground_bluefruit" {
                        
                        HStack {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 25, height: 22, alignment: .center)
                                .foregroundColor(.green)
                            Text("Circuit Playground Bluefruit")
                                .font(Font.custom("ReadexPro-Regular", size: 18))
                                .foregroundColor(.black)
                        }
                    }
                    
                    if string  == "clue_nrf52840_express" {
                        
                        HStack {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 25, height: 22, alignment: .center)
                                .foregroundColor(.green)
                            Text("Adafruit CLUE")
                                .font(Font.custom("ReadexPro-Regular", size: 18))
                                .foregroundColor(.black)
                            Spacer()
                        }
                    }
                }
            }
            .padding(.top, 10)
            .padding(.horizontal, 20)
            
            Button(action: {
                showWebViewPopover = true
                
            }) {
                Text("Learn Guide")
                    .font(.custom("ReadexPro-Regular", size: 25))
                    .foregroundColor(Color("pyleap_purple"))
                    .padding(.leading, 60)
                    .padding(.trailing, 60)
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke((Color("pyleap_purple")), lineWidth: 3.5))
            }
            .sheet(isPresented: $showWebViewPopover, content: {
                WebView(URLRequest(url: learnGuideLink.url!))
            })
            
            
            
            
            if isConnected {
                
                if compatibility.contains(bindingString) {
                    
                    if downloadStateBinder == .idle {
                        Button(action: {
                            downloadModel.startDownload(urlString: downloadLink, projectTitle: title)

                        }) {
                            
                            RunItButton()
                        }
                    }
                    
                    
                    
                    if downloadStateBinder == .transferring {
                        
                        Button(action: {
                            print("Project Selected: \(title) - DemoSubView")
                            
                            globalString.projectString = title
                            globalString.numberOfTimesDownloaded += 1
                            
                        }) {
                            
                            DownloadingButton()
                        }
                        .disabled(true)
                        

                        
                        if globalString.isSendingG {
                            ProgressView("", value: CGFloat(globalString.counterG), total: CGFloat(globalString.numberOfFilesG) )
                                .padding(.horizontal, 90)
                                .padding(.top, -8)
                                .padding(.bottom, 10)
                                .accentColor(Color.gray)
                                .scaleEffect(x: 1, y: 2, anchor: .center)             .cornerRadius(10)
                                .frame(height: 10)
                            
                            
                        }else {
                            
                        }
                        
                    }
                    
                    if downloadStateBinder == .downloading {
                        
                        Button(action: {
                            print("Download Button Pressed!")
                        //    downloadModel.startDownload(urlString: downloadLink, projectTitle: title)
                          //  DownloadViewModel.shared.startDownload(urlString: downloadLink, projectTitle: title)
                        }) {
                            
                           DownloadingButton()
                        }
                        .disabled(true)
                    }
                    
                    if downloadStateBinder == .complete {
                    
                    CompleteButton()
                    }
                    Spacer()
                        .frame(height: 40)
                }
                
                
            } else {
                
                Button  {
                    rootViewModel.goTobluetoothPairing()
                } label: {
                    Text("Connect")
                        .font(Font.custom("ReadexPro-Regular", size: 25))
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 60)
                        .frame(height: 50)
                        .background(Color("adafruit_blue"))
                        .clipShape(Capsule())
                    
                }
                
            }
        }
                
        .onChange(of: downloadModel.isDownloading, perform: { newValue in
            viewModel.getProjectForSubClass(nameOf: title)
        })
        
        .onChange(of: downloadModel.didDownloadBundle, perform: { newValue in
            print("For project: \(title), project download is \(newValue)")
            
            globalString.projectString = title
            
            if newValue {
                DispatchQueue.main.async {
                    viewModel.getProjectForSubClass(nameOf: title)
                    isDownloaded = true
                }
            }else {
                isDownloaded = false
            }
            
        })
        .onAppear(perform: {
            viewModel.getProjectForSubClass(nameOf: title)
            if viewModel.projectDownloaded {
                isDownloaded = true
            } else {
                isDownloaded = false
            }
            print("is downloaded? \(isDownloaded)")
        })
        .padding(.top, 8)
        
    }
}
