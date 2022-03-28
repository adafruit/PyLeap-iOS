//
//  WebView Content.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/15/22.
//

import Foundation
import SwiftUI
import WebKit

struct WebView : UIViewRepresentable {
    
    private let learnGuideLink: URLRequest

    init(_ name: URLRequest) {
        self.learnGuideLink = name
    }
    
    var request: URLRequest {
        get {
            return URLRequest(url: learnGuideLink.url!)
        }
    }
    
    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
    
}
