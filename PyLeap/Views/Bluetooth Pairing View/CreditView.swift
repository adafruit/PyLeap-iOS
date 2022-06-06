//
//  CreditView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 5/16/22.
//

import SwiftUI

struct CreditView: View {
    
    @State private var alertVisible: Bool = false
    @Binding var isPresented: Bool
    
    
    var body: some View {
        ScrollView {
            HStack {
                Spacer()
                Button {
                    isPresented = false
                    print("Dismiss")
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .foregroundColor(.black)
                        
                        .frame(width: 24, height: 24, alignment: .center)
                        .padding(.top, 30)
                        .padding(.trailing, 30)
                }

            }
        
        VStack {

            Image("adafruitLogoBlack")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 201, height: 67, alignment: .center)
                .padding(.top, 70)
                .padding(.bottom, 40)
            
            VStack (alignment: .leading, spacing: 20) {
                
                Text("""
    PyLeap is designed for use with specific devices using the CircuitPython BLE FileTransfer service.

    Follow the links below to purchase a compatible device from the Adafruit shop:
    """)
                
                Text("""
    [• Circuit Playground Bluefruit](https://www.adafruit.com/product/4333)
    [• Adafruit CLUE](https://www.adafruit.com/product/4500)
    """)
                .underline()
               
                Text("""
    Before you can use this app, you'll need to update your uf2 firmware file onto your device. Learn more in the [PyLeap Learn Guide](https://learn.adafruit.com/pyleap-app).

    **Acknowledgements**

    Portions of this Software may utilize the following copyrighted material, the use of which is hereby acknowledged.

    Zip
    Copyright(c) 2019 Nathan Moinvaziri
    """)
                Text("https://github.com/nmoinvaz/minizip")
                    .underline()
                    .padding(.top, -10)
            }
            
//            Text("")
//            Text("""
//
//
//Follow the links below to purchase a compatible device from the Adafruit shop:
//
//• [Circuit Playground Bluefruit](https://www.adafruit.com/product/4333)
//• [Adafruit CLUE](https://www.adafruit.com/product/4500)
//
//Before you can use this app, you'll need to update your uf2 firmware file onto your device. Learn more in the [PyLeap Learn Guide](https://learn.adafruit.com/pyleap-app).
//
//**Acknowledgements**
//
//Portions of this Software may utilize the following copyrighted material, the use of which is hereby acknowledged.
//
//Zip
//Copyright(c) 2019 Nathan Moinvaziri
//https://github.com/nmoinvaz/minizip
//""")
            
        }
        .font(Font.custom("ReadexPro-Regular", size: 16))
        .padding(.horizontal, 30)
        .preferredColorScheme(.light)
    }
}
}
struct CreditView_Previews: PreviewProvider {
    static var previews: some View {
        CreditView(isPresented: .constant(true))
    }
}
