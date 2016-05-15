//
//  HistoryItem.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import MessagePack

public class HistoryItem: Equatable, Serializable
{
    static private let typeKey: MessagePackValue = .UInt(0)
    
    public enum HIType: UInt64
    {
        case Invalid = 0
        
        case InitialState
        case SpecialRulesInEffect
        
        case BidAction
        case PassAction
        case ExactAction
        case ChallengeAction
        
        case PlayerLostRound
        case PlayerWon
    }
    
    public private(set) var type: HIType = .Invalid
    
    init(type: HIType)
    {
        self.type = type
    }
    
    required public init(data: MessagePackValue)
    {
        guard let map = data.dictionaryValue else {
            error("HistoryItem data is not a map/dictionary")
            return
        }
        
        guard let typeRawValue = map[HistoryItem.typeKey]?.unsignedIntegerValue else {
            error("HistoryItem data has no type")
            return
        }
        
        guard let type = HIType(rawValue: typeRawValue) else {
            error("HistoryItem data has an invalid type")
            return
        }
        
        self.type = type
    }
    
    public func asData() -> MessagePackValue
    {
        return .Map([HistoryItem.typeKey : .UInt(self.type.rawValue)])
    }
}

public func ==(lhs: HistoryItem, rhs: HistoryItem) -> Bool
{
    return lhs.type == rhs.type
}
