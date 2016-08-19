//
//  PushAction.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import MessagePack

public class PushAction: HistoryAction
{
    static let pushMaxKey = HistoryAction.actionMaxKey+2
    static private let pushKey: Int = HistoryAction.actionMaxKey+1
    static private let newKey: Int = HistoryAction.actionMaxKey+2
    
    public internal(set) var pushedDice = [UInt]()
    public internal(set) var newDice = [UInt]()
    
    public init(player: String, pushedDice: [UInt], newDice: [UInt], correct: Bool, type: HIType = .pushAction)
    {
        super.init(player: player, correct: correct, type: type)
        
        self.pushedDice = pushedDice
        self.newDice = newDice
    }
    
    required public init?(data: MessagePackValue)
    {
        super.init(data: data)
        
        let array = data.arrayValue!
        
        guard array.count >= PushAction.pushMaxKey+1 else {
            ErrorHandling.error("PushAction data must have an array of size \(PushAction.pushMaxKey+1)!")
            return nil
        }
        
        guard let packedDice = array[PushAction.pushKey].arrayValue else {
            ErrorHandling.error("PushAction data must have an array of pushedDice")
            return nil
        }
        
        guard let packedNewDice = array[PushAction.newKey].arrayValue else {
            ErrorHandling.error("PushAction data must have an array of newDice")
            return nil
        }
        
        for packedDie in packedDice
        {
            guard let die = packedDie.unsignedIntegerValue else {
                ErrorHandling.error("PushAction data must consist of UInts")
                return nil
            }
            
            pushedDice.append(UInt(die))
        }
        
        for packedDie in packedNewDice
        {
            guard let die = packedDie.unsignedIntegerValue else {
                ErrorHandling.error("PushAction data must consist of UInts")
                return nil
            }
            
            newDice.append(UInt(die))
        }
    }
    
    public override func asData() -> MessagePackValue
    {
        var array = super.asData().arrayValue!
        
        array.append(.Array(pushedDice.map{ .UInt(UInt64($0)) }))
        array.append(.Array(newDice.map{ .UInt(UInt64($0)) }))
        
        return .Array(array)
    }
    
    public override func isEqualTo(_ item: HistoryItem) -> Bool
    {
        guard super.isEqualTo(item) else {
            return false
        }
        
        guard let item = (item as? PushAction) else {
            return false
        }
        
        return pushedDice == item.pushedDice && newDice == newDice
    }
}
