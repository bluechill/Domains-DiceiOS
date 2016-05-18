//
//  Player.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation

public class Player: Equatable
{
    static public let startingDice = 5
    
    public var dice: Array<Die> = []
    public var name: String = ""
    
    weak var engine: DiceLogicEngine?
    
    init(name: String, dice: Array<Die> = [], engine: DiceLogicEngine? = nil)
    {
        self.name = name
        self.dice = dice
        self.engine = engine
        
        if self.dice.isEmpty
        {
            self.dice = [Die(),Die(),Die(),Die(),Die()]
        }
    }
    
    var lastBid: BidAction?
    {
        get
        {
            guard let engine = engine else {
                return nil
            }
            
            for index in (0..<engine.currentRoundHistory.count).reverse()
            {
                let item = engine.currentRoundHistory[index]
                let bid = (item as? BidAction)
                
                if bid != nil && bid?.player == name
                {
                    return bid
                }
            }
            
            return nil
        }
    }
}

public func ==(lhs: Player, rhs: Player) -> Bool
{
    // engine === to check whether it is the same instance of the class
    return lhs.dice == rhs.dice && lhs.name == rhs.name && lhs.engine === rhs.engine
}
