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
            
            for item in engine.currentRoundHistory.reverse()
            {
                let bid = (item as? BidAction)
                
                if bid != nil && bid?.player == name
                {
                    return bid
                }
            }
            
            return nil
        }
    }
    
    public var hasExacted: Bool
    {
        get
        {
            guard let engine = engine else {
                return false
            }
            
            for round in engine.history.reverse()
            {
                for item in round.reverse()
                {
                    let action = (item as? ExactAction)
                    
                    if action != nil && action?.player == name
                    {
                        return true
                    }
                }
            }
            
            return false
        }
    }
    
    public var lastAction: HistoryAction?
    {
        get
        {
            guard let engine = engine else {
                return nil
            }
            
            for item in engine.currentRoundHistory.reverse()
            {
                let action = (item as? HistoryAction)
                
                if action != nil && action?.player == name
                {
                    return action
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
            
            for item in engine.currentRoundHistory.reverse()
            {
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
            error("Cannot pass with no engine")
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
    
    public func canExact() -> Bool
    {
        guard !hasExacted else {
            error("Cannot exact twice in one game")
            return false
        }
        
        guard let engine = engine else {
            error("Cannot exact with no engine")
            return false
        }
        
        guard let lastBid = engine.lastBid else {
            error("Can only exact if there is a bid")
            return false
        }
        
        guard lastBid.player != self.name else {
            error("Cannot exact yourself")
            return false
        }
        
        return true
    }
    
    public func exact()
    {
        guard let engine = engine else {
            error("Cannot exact with no engine")
            return
        }
        
        guard engine.currentTurn == self else {
            error("It is not your turn")
            return
        }
        
        guard canExact() else {
            return
        }
        
        let lastBid = engine.lastBid!
        
        let correct = (lastBid.count == engine.countDice(lastBid.face))
        
        let action = ExactAction(player: self.name, correct: correct)
        engine.appendHistoryItem(action)
        
        if correct
        {
            self.dice.append(Die(face: 1))
            engine.createNewRound()
        }
        else
        {
            engine.playerLosesRound(self.name)
        }
    }
    
    public func canChallenge(player: String) -> Bool
    {
        guard let engine = engine else {
            error("Cannot challenge with no engine")
            return false
        }
        
        guard player != self.name else {
            error("Cannot challenge yourself")
            return false
        }
        
        let myIndex = engine.players.indexOf({ $0.name == self.name })!
        var challenge1Index = myIndex-1
        var challenge2Index = myIndex-2
        
        if challenge1Index < 0
        {
            challenge1Index = engine.players.count-1
        }
        
        if challenge2Index < 0
        {
            challenge2Index = engine.players.count-2
        }
        
        let challenge1Player = engine.players[challenge1Index]
        let challenge2Player = engine.players[challenge2Index]
        
        guard challenge1Player.name == player || challenge2Player.name == player else {
            error("Cannot challenge a player other than the last two")
            return false
        }
        
        let challenge1Action = challenge1Player.lastAction
        let challenge2Action = challenge2Player.lastAction
        
        let bidAction1 = challenge1Action as? BidAction
        let passAction1 = challenge1Action as? PassAction
        
        if challenge1Player.name == player
        {
            guard bidAction1 != nil || passAction1 != nil else {
                error("Cannot challenge something other than a bid or pass")
                return false
            }
            
            return true
        }
        
        guard passAction1 != nil else {
            error("Cannot challenge through anything but a pass")
            return false
        }
        
        let bidAction2 = challenge2Action as? BidAction
        let passAction2 = challenge2Action as? PassAction
        
        guard bidAction2 != nil || passAction2 != nil else {
            error("Cannot challenge something other than a bid or pass")
            return false
        }
        
        return true
    }
    
    public func challenge(player: String)
    {
        guard let engine = engine else {
            error("Cannot challenge with no engine")
            return
        }
        
        guard engine.currentTurn == self else {
            error("It is not your turn")
            return
        }
        
        guard canChallenge(player) else {
            return
        }
        
        let lastAction = engine.player(player)!.lastAction!
        
        let correct = !lastAction.correct
        
        let index = engine.currentRoundHistory.indexOf(lastAction)!
        
        let action = ChallengeAction(player: self.name,
                                     challengee: player,
                                     challengeActionIndex: index,
                                     correct: correct)
        engine.appendHistoryItem(action)
        
        if correct
        {
            engine.playerLosesRound(player)
        }
        else
        {
            engine.playerLosesRound(self.name)
        }
    }
}

public func ==(lhs: Player, rhs: Player) -> Bool
{
    // engine === to check whether it is the same instance of the class
    return lhs.dice == rhs.dice && lhs.name == rhs.name && lhs.engine === rhs.engine
}
