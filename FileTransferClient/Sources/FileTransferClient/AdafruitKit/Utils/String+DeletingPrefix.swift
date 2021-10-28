//
//  String+DeletingPrefix.swift
//  GliderFileProvider
//
//  Created by Antonio García on 27/6/21.
//

import Foundation

extension String {
    public func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
