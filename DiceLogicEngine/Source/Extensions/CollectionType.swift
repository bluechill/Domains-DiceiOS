//
//  CollectionType.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/19/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation

// From: http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift
extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        let size: Int = self.endIndex
        
        if count < 2 { return }
        
        for i in 0..<(size - 1)
        {
            let j = Int(Random.random.nextInt() % Int(size - i)) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
