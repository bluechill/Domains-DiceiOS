//
//  SpecialRulesInEffect.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/16/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import MessagePack

public class SpecialRulesInEffect: HistoryItem
{
    public init()
    {
        super.init(type: .SpecialRulesInEffect)
    }
    
    required public init?(data: MessagePackValue)
    {
        super.init(data: data)
        
        guard self.type == .SpecialRulesInEffect else {
            error("Must be a SpecialRulesInEffect to initialize as such")
            return nil
        }
    }
    
    public override func isEqualTo(item: HistoryItem) -> Bool
    {
        guard super.isEqualTo(item) else {
            return false
        }
        
        return (item as? SpecialRulesInEffect) != nil
    }
}
