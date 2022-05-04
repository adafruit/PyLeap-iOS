//
//  Buttons.swift
//  PyLeap
//
//  Created by Trevor Beaton on 4/29/22.
//

import SwiftUI

struct RunItButton: View {
    var body: some View {
        Text("Run it!")
            .font(Font.custom("ReadexPro-Regular", size: 25))
            .foregroundColor(Color.white)
            .padding(.horizontal, 60)
            .frame(height: 50)
            .background(Color("pyleap_pink"))
            .clipShape(Capsule())
    }
}

struct DownloadingButton: View {
    var body: some View {
        Text("Downloading")
            .font(Font.custom("ReadexPro-Regular", size: 25))
            .foregroundColor(Color.white)
            .padding(.horizontal, 60)
            .frame(height: 50)
            .background(Color.gray)
            .clipShape(Capsule())
    }
}

struct CompleteButton: View {
    var body: some View {
        Image("check")
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .padding(.horizontal, 120)
            .frame(height: 50)
            .background(Color("pyleap_green"))
            .clipShape(Capsule())
    }
}

struct FailedButton: View {
    var body: some View {
        Image("x-mark")
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .padding(.horizontal, 120)
            .frame(height: 50)
            .background(Color("pyleap_burg"))
            .clipShape(Capsule())
    }
}

struct Buttons_Previews: PreviewProvider {
    static var previews: some View {
        RunItButton()
        DownloadingButton()
        CompleteButton()
    }
}
