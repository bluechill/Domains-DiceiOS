//
//  Random.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import GameplayKit

enum Random
{
    static var random = Random.newGenerator(0)
    
    static func newGenerator(seed: UInt64) -> GKShuffledDistribution
    {
        return GKShuffledDistribution(randomSource: GKMersenneTwisterRandomSource(seed: seed), lowestValue: 1, highestValue: Int(Die.sides))
    }
}
