//
//  BoardDataProvider.swift
//  PyLeap
//
//  Created by Trevor Beaton on 5/17/23.
//

import Foundation

final class BoardDataProvider {

    
    func getBoardID(from prompt: String) -> String? {
        print("getBoardID function: \(prompt)")
        
        let boardIDPrefix = "Board ID:"
         let uidSuffix = "UID"
         
        if let startRange = prompt.range(of: boardIDPrefix) {
               let start = startRange.upperBound
               var end = prompt.endIndex
               if let endRange = prompt.range(of: uidSuffix) {
                   end = endRange.lowerBound
               }
               
               let range = start..<end
               let boardID = prompt[range].trimmingCharacters(in: .whitespacesAndNewlines)
             
             let boardIDWithSpaces = boardID.replacingOccurrences(of: "_", with: " ")
                       
             let capitalizedBoardID = boardIDWithSpaces.capitalized
             print("Outgoing: \(capitalizedBoardID)")
             return capitalizedBoardID
         }
         
         return nil
    }
    
    func getCircuitPythonMajorVersion(from prompt: String) -> String? {
        print("From getCircuitPythonMajorVersion function: \(prompt)")
        let regexPattern = "CircuitPython (\\d+)"
          if let regex = try? NSRegularExpression(pattern: regexPattern) {
              let range = NSRange(location: 0, length: prompt.utf16.count)
              if let match = regex.firstMatch(in: prompt, options: [], range: range) {
                  if let range = Range(match.range(at: 1), in: prompt) {
                      return String(prompt[range])
                  }
              }
          }
          return nil
    }
    
}
