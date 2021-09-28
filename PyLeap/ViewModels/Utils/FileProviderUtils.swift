//
//  FileProviderUtils.swift
//  Glider
//
//  Created by Antonio García on 27/6/21.
//

import Foundation
import FileProvider

struct FileProviderUtils {
    static func signalFileProviderChanges() {
        NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { error in
            DLog("signalFileProviderChanges completed. Error?: \(String(describing: error))")
        }
    }
}
