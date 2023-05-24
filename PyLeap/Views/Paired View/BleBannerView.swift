//
//  BleBannerView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 5/22/23.
//

import SwiftUI

struct BleBannerView: View {
    var deviceName: String
    var disconnectAction: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Image("bluetoothLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                
                Text(deviceName)
                    .font(Font.custom("ReadexPro-Regular", size: 14))
                
                Button(action: disconnectAction) {
                    Text("Disconnect")
                        .font(Font.custom("ReadexPro-Bold", size: 14))
                        .underline()
                }
            }
            
            
//            .background(GeometryReader {
//                Color.clear.preference(key: ViewHeightKey.self,
//                                       value: $0.frame(in: .local).size.height)
//            })
        }
    }
}

struct BleBannerView_Previews: PreviewProvider {
    static var previews: some View {
        BleBannerView(deviceName: "Test", disconnectAction: {
            print("Dismiss Action")
        })
    }
}
