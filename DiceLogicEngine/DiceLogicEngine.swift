//
//  DiceLogicEngine.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import MessagePack

public class DiceLogicEngine: Serializable, Equatable
{    
    public internal(set) var players = [Player]()
    public internal(set) var history = [[HistoryItem]]()

    public var currentRoundHistory: [HistoryItem]
    {
        get
        {
            guard let currentRound = history.last else {
                error("No current round, returning empty array")
                return []
            }
            
            return currentRound
        }
    }
    
    public var lastBid: BidAction?
    {
        get
        {
            for index in (0..<currentRoundHistory.count).reverse()
            {
                let item = currentRoundHistory[index]
                
                if let bid = (item as? BidAction)
                {
                    return bid
                }
            }
            
            return nil
        }
    }
    
    public var isSpecialRules: Bool
    {
        get
        {
            for index in 0..<currentRoundHistory.count
            {
                let item = currentRoundHistory[index]
                
                if (item as? SpecialRulesInEffect) != nil
                {
                    return true
                }
            }
            
            return false
        }
    }
    
    public var playersLeft: [Player]
    {
        get
        {
            return players.filter{ $0.dice.count > 0 }
        }
    }
    
    public var winner: Player?
    {
        get
        {
            let playersLeft = self.playersLeft
            
            guard playersLeft.count == 1 else {
                return nil
            }
            
            return playersLeft.first!
        }
    }
    
    init(players: [String])
    {
        self.players = players.map{ Player(name: $0, engine: self) }
        
        createNewRound()
    }
    
    func currentPlayerDiceCalculatedViaHistory(name: String) -> [Die]
    {
        let currentRound = self.currentRoundHistory
        
        guard currentRound.count > 0 else {
            error("No history to extract player dice from")
            return []
        }
        
        guard let initialState = currentRound.first as? InitialState else {
            error("Invalid formatted history")
            return []
        }
        
        guard let player = initialState.players[name] else {
            error("Corrupted Player Data for player \(name)")
            return []
        }
        
        var dice = player.map{ Die(face: $0) }
        
        for index in (0..<currentRound.count).reverse()
        {
            let item = currentRound[index]
            
            guard let action = (item as? PushAction) else {
                continue
            }
            
            guard action.player == name else {
                continue
            }
            
            dice.removeAll()
            dice.appendContentsOf(action.pushedDice.map{ Die(face: UInt($0), pushed: true) })
            dice.appendContentsOf(action.newDice.map{ Die(face: UInt($0)) })
            
            break
        }
        
        return dice
    }
    
    required public init?(data: MessagePackValue)
    {
        guard let array = data.arrayValue else {
            error("DiceLogicEngine data is not an array")
            return nil
        }
        
        guard array.count == 2 else {
            error("Invalid DiceLogicEngine data array")
            return nil
        }
        
        guard let players = array[0].arrayValue else {
            error("No players array in DiceLogicEngine data")
            return nil
        }
        
        guard let history = array[1].arrayValue else {
            error("No history array in DiceLogicEngine data")
            return nil
        }
        
        for item in history
        {
            guard let item = item.arrayValue else {
                error("DiceLogicEngine sub-array data is not an array")
                return nil
            }
            
            guard item.count > 0 else {
                error("Empty DiceLogicEngine sub-array data")
                return nil
            }
            
            var round = [HistoryItem]()
            
            for hItem in item
            {
                guard let newItem = HistoryItem.makeHistoryItem(hItem) else {
                    return nil
                }
                
                round.append(newItem)
            }
            
            self.history.append(round)
        }
        
        for player in players
        {
            guard let player = player.stringValue else {
                error("Player in players array is not a player name")
                return nil
            }
            
            self.players.append(Player( name: player,
                                        dice: currentPlayerDiceCalculatedViaHistory(player),
                                        engine: self))
        }
    }
    
    public func asData() -> MessagePackValue
    {
        let playersMap: [MessagePackValue] = self.players.map{ .String($0.name) }
        let historyMap: [MessagePackValue] = self.history.map{ .Array($0.map{ $0.asData() }) }
        
        return .Array([.Array(playersMap),
                      .Array(historyMap)])
    }
    
    func player(name: String) -> Player?
    {
        let array = players.filter{ $0.name == name }
        
        guard array.count > 0 else {
            error("No player with name '\(name)'")
            return nil
        }
        guard array.count == 1 else {
            error("More than one player with the same name '\(name)'")
            return nil
        }
        
        return array.first!
    }
    
    func hasPlayerBeenInSpecialRulesBefore(player: String) -> Bool
    {
        for round in history.reverse()
        {
            for item in round.reverse()
            {
                if  (item as? SpecialRulesInEffect) != nil &&
                    (item as! SpecialRulesInEffect).player == player
                {
                    return true
                }
            }
        }
        
        return false
    }
    
    func createNewRound()
    {
        var playerWhoLostRound = String?()
        
        if let round = history.last
        {
            var lostItem = (round.last as? PlayerLostRound)
            
            if lostItem == nil
            {
                for item in round.reverse()
                {
                    if let item = (item as? PlayerLostRound)
                    {
                        lostItem = item
                        break
                    }
                }
            }
            
            if let item = lostItem
            {
                playerWhoLostRound = item.player
            }
        }
        
        history.append([])
        
        for player in players
        {
            for die in player.dice
            {
                die.roll()
            }
        }
        
        let currentRoundIndex = history.count-1
        
        var playerStringUInts = [String:[UInt]]()
        for player in players
        {
            playerStringUInts[player.name] = player.dice.map{ $0.face }
        }
        
        history[currentRoundIndex].append(InitialState(players: playerStringUInts))
        
        if let playerWhoLostRound = playerWhoLostRound
        {
            guard let player = self.player(playerWhoLostRound) else {
                error("Invalid player who lost the round.")
                return
            }
            
            if player.dice.count == 1 && !hasPlayerBeenInSpecialRulesBefore(player.name)
            {
                history[currentRoundIndex].append(SpecialRulesInEffect(player: playerWhoLostRound))
            }
        }
    }
    
    func playerLosesRound(player: String)
    {
        guard self.winner == nil else {
            error("Cannot lose round when the game is over")
            return
        }
        
        guard let player = self.player(player) else {
            error("Invalid player lost the round")
            return
        }
        
        guard player.dice.count > 0 else {
            error("Player cannot lose the round when they already have zero dice.")
            return
        }
        
        let index = history.count-1
        history[index].append(PlayerLostRound(player: player.name))
        
        player.dice.removeLast()
        
        if player.dice.count == 0
        {
            history[index].append(PlayerLost(player: player.name))
            
            let playersLeft = self.playersLeft
            if playersLeft.count == 1
            {
                history[index].append(PlayerWon(player: playersLeft.first!.name))
                return
            }
        }
        
        createNewRound()
    }
}

public func ==(lhs: [[HistoryItem]], rhs: [[HistoryItem]]) -> Bool
{
    guard lhs.count == rhs.count else {
        return false
    }
    
    for (r1, r2) in zip(lhs, rhs)
    {
        guard r1.count == r2.count else {
            return false
        }
        
        for (item1, item2) in zip(r1, r2)
        {
            guard item1 == item2 else {
                return false
            }
        }
    }
    
    return true
}

public func ==(lhs: DiceLogicEngine, rhs: DiceLogicEngine) -> Bool
{
    // Player == will fail for two different engines, special case it since it will definitely fail here
    for (p1, p2) in zip(lhs.players, rhs.players)
    {
        if p1.name != p2.name || p1.dice != p2.dice
        {
            return false
        }
    }
    
    return lhs.history == rhs.history
}
