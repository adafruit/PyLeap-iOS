//
//  DownloadState.swift
//  PyLeap
//
//  Created by Trevor Beaton on 4/28/22.
//

import Foundation

enum DownloadState {
    case idle
    case downloading
    case transferring
    case complete
    case failed
    
}

enum InternetState {
    case noInternetConnection
    case connectedToInternet
}

enum ErrorConnecting {
    case noError
    case peerInformationError
}
