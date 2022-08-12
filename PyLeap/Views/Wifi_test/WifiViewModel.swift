//
//  WifiViewModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/9/22.
//

import SwiftUI
import Foundation

class WifiViewModel: ObservableObject {
    
    var wifiNetworkService = WifiNetworkService()
    
    func putRequest() {
        guard let url = URL(string: "https://api.lucidtech.ai/v0/receipts"),
            let payload = "{\"documentId\": \"a50920e1-214b-4c46-9137-2c03f96aad56\"}".data(using: .utf8) else
        {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("your_api_key", forHTTPHeaderField: "x-api-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = payload

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else { print(error!.localizedDescription); return }
            guard let data = data else { print("Empty data"); return }

            if let str = String(data: data, encoding: .utf8) {
                print(str)
            }
        }.resume()
    }
    

    
}

