//
//  Queue.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/25/22.
//

import Foundation

class Queue<T> {
    var array = [T]()
    
    func enQueue(value: T) {
        array.append(value)
    }
    
    func deQueue() -> T? {
        if array.isEmpty {
            return nil
        } else {
            return array.remove(at:0)
        }
        
        
    }
}
