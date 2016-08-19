//
//  ExactAction.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import MessagePack

public class ExactAction: HistoryAction
{
    public init(player: String, correct: Bool)
    {
        super.init(player: player, correct: correct, type: .exactAction)
    }
    
    required public init?(data: MessagePackValue)
    {
        super.init(data: data)
        
        guard self.type == .exactAction else {
            ErrorHandling.error("Must be a ExactAction to initialize as such")
            return nil
        }
    }
    
    public override func isEqualTo(_ item: HistoryItem) -> Bool
    {
        guard super.isEqualTo(item) else {
            return false
        }
        
        return (item as? ExactAction) != nil
    }
}
