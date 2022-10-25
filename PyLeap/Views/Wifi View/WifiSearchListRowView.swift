//
//  WifiSearchListRowView.swift
//  PyLeap
//
//  Created by Trevor Beaton on 10/24/22.
//

import SwiftUI

struct WifiRowView: View {
 @State var wifiService: ResolvedService
  
  var body: some View {

      VStack(alignment: .leading) {
          Text(wifiService.hostName)
              .font(.headline)
          Text(wifiService.device)
          .font(.subheadline)
          Text("IP: \(wifiService.ipAddress)")
              .font(.subheadline)
          Spacer()
      }
      .padding(.vertical)
  }
}
