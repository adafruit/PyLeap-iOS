//
//  Networking.swift
//  PyLeap
//
//  Created by Trevor Beaton on 11/23/22.
//

import Foundation


enum HTTPMethod: String {
    case delete = "DELETE"
    case get = "GET"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
    case options = "OPTIONS"
}

enum HTTPScheme: String {
    case http
    case https
}

/// The API protocol allows us to separate the task of constructing a URL,
/// its parameters, and HTTP method from the act of executing the URL request
/// and parsing the response.
///

protocol API {

    var scheme: HTTPScheme { get }

    var baseURL: String { get }

    var path: String { get }
    // [URLQueryItem(name: "api_key", value: API_KEY)]
    var parameters: [URLQueryItem] { get }
    
    var method: HTTPMethod { get }
}
