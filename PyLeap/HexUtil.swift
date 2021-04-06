//
//  HexUtil.swift
//  PyLeap
//
//  Created by Trevor Beaton on 4/2/21.
//

import Foundation

struct HexUtil {
    static func hexDescription(data: Data, prefix: String = "", postfix: String = " ") -> String {
        return data.reduce("") {$0 + String(format: "%@%02X%@", prefix, $1, postfix)}
    }
    
    static func hexDescription(bytes: [UInt8], prefix: String = "", postfix: String = " ") -> String {
        return bytes.reduce("") {$0 + String(format: "%@%02X%@", prefix, $1, postfix)}
    }
    
    static func decimalDescription(data: Data, prefix: String = "", postfix: String = " ") -> String {
        return data.reduce("") {$0 + String(format: "%@%ld%@", prefix, $1, postfix)}
    }
}
