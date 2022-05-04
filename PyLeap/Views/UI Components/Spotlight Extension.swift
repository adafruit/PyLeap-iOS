//
//  Spotlight Extension.swift
//  PyLeap
//
//  Created by Trevor Beaton on 5/4/22.
//

import SwiftUI

// MARK: - Custom Spotlight Modifier

extension View {
    
    func spotlight(enabled: Bool, title: String = "") -> some View {
        return self
            .overlay {
                if enabled {
                    SpotlightView(title: title) {
                        self
                    }
                }
            }
    }
    
    // MARK: - Screen Bounds
    func screenBounds()->CGRect {
        return UIScreen.main.bounds
    }
    
    func rootController()->UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        return root
        
    }
}

struct SpotlightView<Content: View>: View {
    var content: Content

    var title: String
    
    init(title: String, @ViewBuilder content: @escaping()->Content) {

        self.title = title
        self.content = content()
    }
    
    @State var tag: Int = 1009
    
    var body: some View {
        Rectangle()
            .fill(.clear)
            .onAppear {
                addOverlayView()
            }
    }
    
    func addOverlayView() {
        let hostingView = UIHostingController(rootView: overlaySwiftView())
        hostingView.view.frame = screenBounds()
        hostingView.view.backgroundColor = .clear
        // To ID which View added , adding a tag for the View
        //self.tag = generateRandom()
        
        if self.tag == 1009 {
            self.tag == generateRandom()
        }
        
        hostingView.view.tag = self.tag
        
        rootController().view.subviews.forEach { view in
            if view.tag == self.tag{return}
        }
        
        rootController().view.addSubview(hostingView.view)
        
    }
    // MARK: Adding an Extra View over the Current View
    
    @ViewBuilder
    func overlaySwiftView()->some View {
        Rectangle()
             .fill(Color("pyleap_spotlight"))
             .opacity(0.8)
             .mask({
                 Rectangle()
                     .overlay {
                         content
                             .blendMode(.destinationOut)
                     }
             })
             .frame(width: screenBounds().width, height: screenBounds().height)
             .ignoresSafeArea()
    }
    
    func generateRandom()->Int {
        let random = Int(UUID().uuid.0)
        let subViews = rootController().view.subviews
        
        for index in subViews.indices {
            if subViews[index].tag == random {
                return generateRandom()
            }
        }
        return random
    }

}
