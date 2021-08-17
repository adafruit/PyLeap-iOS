//
//  Data+ScanValues.swift
//  Bluefruit
//
//  Created by Antonio García on 17/11/2016.
//  Copyright © 2016 Adafruit. All rights reserved.
//

import Foundation

// MARK: - Data Scan
extension Data {
    func scanValue<T>(start: Int, length: Int) -> T {
        let subdata = self.subdata(in: (self.startIndex + start)..<(self.startIndex + start + length))
        return subdata.withUnsafeBytes { $0.load(as: T.self) }
    }
}
