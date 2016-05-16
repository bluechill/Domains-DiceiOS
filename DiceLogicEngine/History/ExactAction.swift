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
        super.init(player: player, correct: correct, type: .ExactAction)
    }
    
    required public init?(data: MessagePackValue)
    {
        super.init(data: data)
    }
    
    public override func isEqualTo(item: HistoryItem) -> Bool
    {
        guard super.isEqualTo(item) else {
            return false
        }
        
        return (item as? ExactAction) != nil
    }
}
