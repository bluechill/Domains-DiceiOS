//
//  InitialState.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/16/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import MessagePack

public class InitialState: HistoryItem
{
    static let initialStateMaxKey: Int = itemMaxKey+1
    static private let playersKey: Int = itemMaxKey+1
    
    public internal(set) var players: [String: Array<UInt>] = [:]
    
    public init(players: [String: Array<UInt>])
    {
        super.init(type: .InitialState)
        
        self.players = players
    }
    
    required public init?(data: MessagePackValue)
    {
        super.init(data: data)
        
        guard self.type == .InitialState else {
            error("Must be an InitialState to initialize as such")
            return nil
        }
        
        let array = data.arrayValue!
        
        guard array.count >= InitialState.initialStateMaxKey+1 else {
            error("InitialState data must have an array of size \(InitialState.initialStateMaxKey+1)!")
            return nil
        }
        
        guard let packedPlayers = array[InitialState.playersKey].dictionaryValue else {
            error("InitialState data must have a dictionary of pushedDice")
            return nil
        }
        
        guard packedPlayers.count > 0 else {
            error("There will always be at least two players even if they have no dice, in an InitialState")
            return nil
        }
        
        for (packedPlayer, packedDiceArray) in packedPlayers
        {
            guard let player = packedPlayer.stringValue else {
                error("InitialState must have a string player")
                return nil
            }
            
            guard let packedDice = packedDiceArray.arrayValue else {
                error("InitialState must have dice")
                return nil
            }
            
            var dice: [UInt] = []
            
            for packedDie in packedDice
            {
                guard let die = packedDie.unsignedIntegerValue else {
                    error("InitialState dice must consist of UInts")
                    return nil
                }
                
                dice.append(UInt(die))
            }
            
            players[player] = dice
        }
    }
    
    public override func asData() -> MessagePackValue
    {
        var array = super.asData().arrayValue!
        
        var dictionary = [MessagePackValue:MessagePackValue] ()
        
        for (key, value) in players
        {
            dictionary[.String(key)] = .Array(value.map{.UInt(UInt64($0))})
        }
        
        array.append(.Map(dictionary))
        
        return .Array(array)
    }
    
    public override func isEqualTo(item: HistoryItem) -> Bool
    {
        guard super.isEqualTo(item) else {
            return false
        }
        
        guard let item = (item as? InitialState) else {
            return false
        }
        
        return item.players == self.players
    }
}

public func ==(lhs: [String: Array<UInt>], rhs: [String: Array<UInt>]) -> Bool
{
    guard lhs.count == rhs.count else {
        return false
    }
    
    return Array(lhs.keys) == Array(rhs.keys) && Array(lhs.values) == Array(rhs.values)
}
