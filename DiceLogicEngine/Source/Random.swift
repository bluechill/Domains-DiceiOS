//
//  Random.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import GameplayKit

public enum Random
{
    public static var random = Random.newGenerator(0)

    public static func newGenerator(_ seed: UInt64) -> GKShuffledDistribution
    {
        return GKShuffledDistribution(randomSource: GKMersenneTwisterRandomSource(seed: seed),
                                      lowestValue: 1,
                                      highestValue: Int(Die.sides))
    }
}
