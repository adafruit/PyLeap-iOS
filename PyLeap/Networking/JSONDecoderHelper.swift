//
//  JSONDecoderHelper.swift
//  PyLeap
//
//  Created by Trevor Beaton on 1/11/23.
//

import Foundation

class JSONDecoderHelper {
    static func decode<T: Decodable>(data: Data) -> T? {
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }
}
