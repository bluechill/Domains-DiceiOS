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
    static let itemMaxKey: Int = 0
    static private let typeKey: Int = 0
    
    public enum HIType: UInt64
    {
        case Invalid = 0
        
        case InitialState
        case SpecialRulesInEffect
        
        case Action
        
        case PushAction
        case BidAction
        case PassAction
        
        case ExactAction
        case ChallengeAction
        
        case PlayerInfoItem
        case PlayerLostRound
        case PlayerWon
    }
    
    public private(set) var type: HIType = .Invalid
    
    init(type: HIType)
    {
        self.type = type
    }
    
    required public init?(data: MessagePackValue)
    {
        guard let array = data.arrayValue else {
            error("HistoryItem data is not an array")
            return nil
        }
        
        guard array.count >= HistoryItem.itemMaxKey+1 else {
            error("HistoryItem data has to have an array of size \(HistoryItem.itemMaxKey+1)")
            return nil
        }
        
        guard let typeRawValue = array[HistoryItem.typeKey].unsignedIntegerValue else {
            error("HistoryItem data has no type")
            return nil
        }
        
        guard let type = HIType(rawValue: typeRawValue) else {
            error("HistoryItem data has an invalid type")
            return nil
        }
        
        self.type = type
    }
    
    public func asData() -> MessagePackValue
    {
        return .Array([.UInt(self.type.rawValue)])
    }
    
    public func isEqualTo(item: HistoryItem) -> Bool
    {
        return self.type == item.type
    }
}

public func ==(lhs: HistoryItem, rhs: HistoryItem) -> Bool
{
    return lhs.isEqualTo(rhs)
}
