//
//  FileTransferCommand.swift
//  PyLeap
//
//  Created by Trevor Beaton on 5/3/21.
//

import Foundation

struct FileTransferCommand {
    static let Invalid = 0x00
    static let Read = 0x10
    static let ReadData = 0x11
    static let ReadPacing = 0x12
    static let Write = 0x20
    static let WritePacing = 0x21
    static let WriteData = 0x22
    static let Delete = 0x30
    static let DeleteStatus = 0x31
    static let MkDir = 0x40
    static let MkDirStatus = 0x41
    static let ListDir = 0x50
    static let ListDirEntry = 0x51
    
    static let OK = 0x01  // pylint: disable=invalid-name
    static let ERROR = 0x02
    static let ERROR_NO_FILE = 0x03
    static let ERROR_PROTOCOL = 0x04

    // Flags
    static let DIRECTORY = 0x01
}
