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
    
    public var lastBid: BidAction?
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
    
    public var hasPassedThisRound: Bool
    {
        get
        {
            guard let engine = engine else {
                return false
            }
            
            for index in (0..<engine.currentRoundHistory.count).reverse()
            {
                let item = engine.currentRoundHistory[index]
                let pass = (item as? PassAction)
                
                if pass != nil && pass?.player == name
                {
                    return true
                }
            }
            
            return false
        }
    }
    
    func isValidSpecialRulesBid(count: UInt, face: UInt, lastBid: BidAction) -> Bool
    {
        if dice.count == 1
        {
            return count > lastBid.count || face > lastBid.face
        }
       
        return count > lastBid.count && face == lastBid.face
    }
    
    func isValidNonSpecialRulesBid(count: UInt, face: UInt, lastBid: BidAction) -> Bool
    {
        if face == 1 && lastBid.face != 1
        {
            return Double(count) > ceil(Double(lastBid.count)/2.0)
        }
        else if face != 1 && lastBid.face == 1
        {
            return count > lastBid.count*2
        }
       
        return  count > lastBid.count ||
                (count == lastBid.count && face > lastBid.face)
    }
    
    public func isValidBid(count: UInt, face: UInt) -> Bool
    {
        guard let engine = engine else {
            error("Cannot bid with no engine")
            return false
        }
        
        guard count > 0 else {
            error("Cannot bid zero dice")
            return false
        }
        
        guard face > 0 && face <= Die.sides else {
            error("Cannot bid invalid die face \(face)")
            return false
        }
        
        guard let lastBid = engine.lastBid else {
            warning("No last bid, therefore valid")
            return true
        }
        
        if engine.isSpecialRules
        {
            return isValidSpecialRulesBid(count, face: face, lastBid: lastBid)
        }
        
        return isValidNonSpecialRulesBid(count, face: face, lastBid: lastBid)
    }
    
    public func canPushDice(pushDice: [UInt]) -> Bool
    {
        var dice = self.dice.filter{ $0.pushed == false }
        
        for die in pushDice
        {
            if let index = dice.indexOf({ $0.face == die })
            {
                dice.removeAtIndex(index)
            }
            else
            {
                error("Cannot push die you do not have \(die)")
                return false
            }
        }
        
        if dice.count >= 1
        {
            return true
        }
        
        error("Cannot push all your dice")
        return false
    }
    
    func pushDice(dice: [UInt]) -> Bool
    {
        guard canPushDice(dice) else {
            return false
        }
        
        guard dice.count > 0 else {
            return true
        }
        
        for die in dice
        {
            let index = self.dice.indexOf({
                $0.face == die && $0.pushed == false
            })!
            
            self.dice[index].pushed = true
        }
        
        for die in self.dice.filter({ $0.pushed == false })
        {
            die.roll()
        }
        
        return true
    }
    
    public func bid(count: UInt, face: UInt, pushDice: [UInt] = [UInt]())
    {
        guard let engine = engine else {
            error("Cannot bid with no engine")
            return
        }
        
        guard engine.currentTurn == self else {
            error("It is not your turn")
            return
        }
        
        guard isValidBid(count, face: face) else {
            return
        }
        
        guard self.pushDice(pushDice) else {
            return
        }
        
        let correct = engine.countDice(face) >= count
        
        let action = BidAction(player: self.name,
                               count: count,
                               face: face,
                               pushedDice: pushDice,
                               newDice: self.dice.filter({ $0.pushed == false }).map({ $0.face }),
                               correct: correct)
        
        engine.appendHistoryItem(action)
        engine.advancePlayer()
    }
    
    public func canPass() -> Bool
    {
        guard !hasPassedThisRound else {
            error("You cannot pass more than once per round")
            return false
        }
        
        guard self.dice.count > 1 else {
            error("You cannot pass with only one die")
            return false
        }
        
        return true
    }
    
    public func pass(pushDice: [UInt] = [UInt]())
    {
        guard let engine = engine else {
            error("Cannot bid with no engine")
            return
        }
        
        guard engine.currentTurn == self else {
            error("It is not your turn")
            return
        }
        
        guard canPass() else {
            return
        }
        
        guard self.pushDice(pushDice) else {
            return
        }
        
        let correct = (self.dice.filter({ $0.face == self.dice[0].face}).count == self.dice.count)
        
        let action = PassAction(player: self.name,
                                pushedDice: pushDice,
                                newDice: self.dice.filter({ $0.pushed == false }).map({ $0.face }),
                                correct: correct)
        
        engine.appendHistoryItem(action)
        engine.advancePlayer()
    }
}

public func ==(lhs: Player, rhs: Player) -> Bool
{
    // engine === to check whether it is the same instance of the class
    return lhs.dice == rhs.dice && lhs.name == rhs.name && lhs.engine === rhs.engine
}
