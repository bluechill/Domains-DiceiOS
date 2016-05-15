//
//  Player.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation

public class Player
{
    static public let startingDice = 5
    
    public var dice: Array<Die> = []
    public var name: String = ""
    
    private weak var engine: DiceLogicEngine?
    
    init(name: String, dice: Array<Die> = [])
    {
        self.name = name
        self.dice = dice
        
        if self.dice.count < 5
        {
            self.dice.appendContentsOf(Array(count: Player.startingDice - self.dice.count, repeatedValue: Die()))
        }
    }
}