//
//  HistoryAction.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import MessagePack

public class HistoryAction: HistoryItem
{
    static private let playerKey: Int = 1
    static private let correctKey: Int = 2
    
    public private(set) var player: String = ""
    public private(set) var correct: Bool = false
    
    public init(player: String, correct: Bool)
    {
        super.init(type: .Action)
        
        self.player = player
        self.correct = correct
    }
    
    required public init?(data: MessagePackValue)
    {
        super.init(data: data)
        
        let array = data.arrayValue!
        
        guard array.count >= 3 else {
            error("HistoryAction data must have an array of size 3!")
            return nil
        }
        
        guard let player = array[HistoryAction.playerKey].stringValue else {
            error("HistoryAction data has no player")
            return nil
        }
        
        self.player = player
        
        guard let correct = array[HistoryAction.correctKey].boolValue else {
            error("HistoryAction data has no correct key")
            return nil
        }
        
        self.correct = correct
    }
    
    public override func asData() -> MessagePackValue
    {
        var array = super.asData().arrayValue!
        
        array.append(.String(player))
        array.append(.Bool(correct))
        
        return .Array(array)
    }
}

public func ==(lhs: HistoryAction, rhs: HistoryAction) -> Bool
{
    guard (lhs as HistoryItem) == (rhs as HistoryItem) else {
        return false
    }
    
    return  lhs.player == rhs.player &&
            lhs.correct == rhs.correct
}

public func ==(lhs: HistoryItem, rhs: HistoryAction) -> Bool
{
    guard let action = lhs as? HistoryAction else {
        return false
    }
    
    return action == rhs
}

public func ==(lhs: HistoryAction, rhs: HistoryItem) -> Bool
{
    return rhs == lhs
}
