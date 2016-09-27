//
//  Set.swift
//  DiabetesCrunchSaga
//
//  Created by Billy Nab on 3/7/15.
//  Copyright (c) 2015 Sucker Punch Ltd. All rights reserved.
//

struct ASet<T: Hashable>: Sequence, CustomStringConvertible {
    fileprivate var dictionary = Dictionary<T, Bool>()
    
    mutating func addElement(_ newElement: T) {
        dictionary[newElement] = true
    }
    
    mutating func removeElement(_ element: T) {
        dictionary[element] = nil
    }
    
    func containsElement(_ element: T) -> Bool {
        return dictionary[element] != nil
    }
    
    func allElements() -> [T] {
        return Array(dictionary.keys)
    }
    
    var count: Int {
        return dictionary.count
    }
    
    func unionSet(_ otherSet: ASet<T>) -> ASet<T> {
        var combined = ASet<T>()
        
        for obj in dictionary.keys {
            combined.dictionary[obj] = true
        }
        
        for obj in otherSet.dictionary.keys {
            combined.dictionary[obj] = true
        }
        
        return combined
    }
    
    func makeIterator() -> IndexingIterator<Array<T>> {
        return allElements().makeIterator()
    }
    
    var description: String {
        return dictionary.description
    }
}
