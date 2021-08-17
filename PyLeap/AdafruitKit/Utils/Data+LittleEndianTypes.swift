//
//  Data+LittleEndianTypes.swift
//  BluefruitPlayground
//
//  Created by Antonio García on 13/11/2019.
//  Copyright © 2019 Adafruit. All rights reserved.
//

import Foundation

extension Data {
    func toFloatFrom32Bits() -> Float {
        return Float(bitPattern: UInt32(littleEndian: self.withUnsafeBytes { $0.load(as: UInt32.self) }))
    }

    func toIntFrom32Bits() -> Int {
        return Int(Int32(bitPattern: UInt32(littleEndian: self.withUnsafeBytes { $0.load(as: UInt32.self) })))
    }

    func toInt32From32Bits() -> Int32 {
        return Int32(bitPattern: UInt32(littleEndian: self.withUnsafeBytes { $0.load(as: UInt32.self) }))
    }

}
