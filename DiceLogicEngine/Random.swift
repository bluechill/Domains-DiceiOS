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
    static var dieFaceGenerator = Random.newDieFaceGenerator(0)
    
    static func newDieFaceGenerator(seed: UInt64) -> GKShuffledDistribution
    {
        return GKShuffledDistribution(randomSource: GKMersenneTwisterRandomSource(seed: seed), lowestValue: 1, highestValue: Int(Die.sides))
    }
}
