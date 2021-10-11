//
//  UIColor+LightAndDark.swift
//
//  Created by Antonio García on 08/12/15.
//

// http://stackoverflow.com/questions/11598043/get-slightly-lighter-and-darker-color-from-uicolor

#if os(OSX)
    
    import Cocoa
    public typealias PXColor = NSColor
    
#else
    
    import UIKit
    public typealias PXColor = UIColor
    
#endif
import SwiftUI

extension PXColor {
    
    func lighter(by amount: CGFloat = 0.25) -> PXColor {
        return hueColorWithBrightnessAmount(1 + amount)
    }
    
    func darker(by amount: CGFloat = 0.25) -> PXColor {
        return hueColorWithBrightnessAmount(1 - amount)
    }
    
    fileprivate func hueColorWithBrightnessAmount(_ amount: CGFloat) -> PXColor {
        var hue         : CGFloat = 0
        var saturation  : CGFloat = 0
        var brightness  : CGFloat = 0
        var alpha       : CGFloat = 0
        
        #if os(iOS)
            
            if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
                return PXColor( hue: hue,
                    saturation: saturation,
                    brightness: brightness * amount,
                    alpha: alpha )
            } else {
                return self
            }
            
        #else
            
            getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            return PXColor( hue: hue,
                saturation: saturation,
                brightness: brightness * amount,
                alpha: alpha )
            
        #endif
        
    }
    
}

// from: https://stackoverflow.com/questions/38435308/get-lighter-and-darker-color-variations-for-a-given-uicolor
extension Color {
    public func lighter(by amount: CGFloat = 0.2) -> Self { Self(UIColor(self).lighter(by: amount)) }
    public func darker(by amount: CGFloat = 0.2) -> Self { Self(UIColor(self).darker(by: amount)) }
}
