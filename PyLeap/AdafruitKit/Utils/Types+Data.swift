//
//  Types+Data.swift
//  BluefruitPlayground
//
//  Created by Antonio García on 13/11/2019.
//  Copyright © 2019 Adafruit. All rights reserved.
//

import Foundation

// from: https://stackoverflow.com/questions/38023838/round-trip-swift-number-types-to-from-data

protocol DataConvertible {
    init?(data: Data)
    var data: Data { get }
}

extension DataConvertible where Self: ExpressibleByIntegerLiteral {

    init?(data: Data) {
        var value: Self = 0
        guard data.count == MemoryLayout.size(ofValue: value) else { return nil }
        _ = withUnsafeMutableBytes(of: &value, { data.copyBytes(to: $0)})
        self = value
    }

    var data: Data {
        return withUnsafeBytes(of: self) { Data($0) }
    }
}

// Declare conformance to all types which can safely be converted to Data and back
extension Int: DataConvertible { }
extension UInt8: DataConvertible { }
extension Int16: DataConvertible { }
extension UInt16: DataConvertible { }
extension Int32: DataConvertible { }
extension UInt32: DataConvertible { }
extension Float: DataConvertible { }
extension Double: DataConvertible { }

// Convert from [UInt8] to Data and from Data to [UInt8]
// from: https://stackoverflow.com/questions/31821709/nsdata-to-uint8-in-swift/31821838
extension Data {
    var bytes: [UInt8] {
        return [UInt8](self)
    }
}

extension Array where Element == UInt8 {
    var data: Data {
        return Data(self)
    }
}
