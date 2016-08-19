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
        case invalid = 0
        
        case initialState
        case specialRulesInEffect
        
        case action
        
        case pushAction
        case bidAction
        case passAction
        
        case exactAction
        case challengeAction
        
        case playerInfoItem
        case playerLostRound
        case playerLost
        case playerWon
    }
    
    public internal(set) var type: HIType = .invalid
    
    static public func makeHistoryItem(_ data: MessagePackValue) -> HistoryItem?
    {
        guard let item = HistoryItem(data: data) else {
            ErrorHandling.error("Invalid History Item")
            return nil
        }
        
        switch item.type
        {
        case .invalid:
            ErrorHandling.error("Non-Standalone history item")
            return nil
        case .pushAction:
            ErrorHandling.error("Non-Standalone history item")
            return nil
        case .action:
            ErrorHandling.error("Non-Standalone history item")
            return nil
        case .playerInfoItem:
            ErrorHandling.error("Non-Standalone history item")
            return nil
        
        case .initialState:
            return InitialState(data: data)
        case .specialRulesInEffect:
            return SpecialRulesInEffect(data: data)
        
        case .bidAction:
            return BidAction(data: data)
        case .passAction:
            return PassAction(data: data)
            
        case .exactAction:
            return ExactAction(data: data)
        case .challengeAction:
            return ChallengeAction(data: data)
        
        case .playerLostRound:
            return PlayerLostRound(data: data)
        case .playerLost:
            return PlayerLost(data: data)
        case .playerWon:
            return PlayerWon(data: data)
        }
    }
    
    init(type: HIType)
    {
        self.type = type
    }
    
    required public init?(data: MessagePackValue)
    {
        guard let array = data.arrayValue else {
            ErrorHandling.error("HistoryItem data is not an array")
            return nil
        }
        
        guard array.count >= HistoryItem.itemMaxKey+1 else {
            ErrorHandling.error("HistoryItem data has to have an array of size \(HistoryItem.itemMaxKey+1)")
            return nil
        }
        
        guard let typeRawValue = array[HistoryItem.typeKey].unsignedIntegerValue else {
            ErrorHandling.error("HistoryItem data has no type")
            return nil
        }
        
        guard let type = HIType(rawValue: typeRawValue) else {
            ErrorHandling.error("HistoryItem data has an invalid type")
            return nil
        }
        
        self.type = type
    }
    
    public func asData() -> MessagePackValue
    {
        return .array([.uInt(self.type.rawValue)])
    }
    
    public func isEqualTo(_ item: HistoryItem) -> Bool
    {
        return self.type == item.type
    }
}

public func ==(lhs: HistoryItem, rhs: HistoryItem) -> Bool
{
    return lhs.isEqualTo(rhs)
}
