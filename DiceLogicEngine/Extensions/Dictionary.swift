//
//  Dictionary.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/16/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
extension Dictionary
{
    init(_ pairs: [Element])
    {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
    
    func mapPairs<OutKey: Hashable, OutValue>(@noescape transform: Element throws -> (OutKey, OutValue)) rethrows -> [OutKey: OutValue]
    {
        return Dictionary<OutKey, OutValue>(try map(transform))
    }
    
    func filterPairs(@noescape includeElement: Element throws -> Bool) rethrows -> [Key: Value]
    {
        return Dictionary(try filter(includeElement))
    }
    
    func map<OutValue>(@noescape transform: Value throws -> OutValue) rethrows -> [Key: OutValue]
    {
        return Dictionary<Key, OutValue>(try map { (k, v) in (k, try transform(v)) })
    }
}
