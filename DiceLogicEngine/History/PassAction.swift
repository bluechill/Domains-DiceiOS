//
//  PassAction.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import MessagePack

public class PassAction: PushAction
{
    public init(player: String, pushedDice: Array<UInt64>, correct: Bool)
    {
        super.init(player: player, pushedDice: pushedDice, correct: correct, type: .PassAction)
    }
    
    required public init?(data: MessagePackValue)
    {
        super.init(data: data)
        
        guard self.type == .PassAction else {
            error("Must be a PassAction to initialize as such")
            return nil
        }
    }
    
    public override func isEqualTo(item: HistoryItem) -> Bool
    {
        guard super.isEqualTo(item) else {
            return false
        }

        return (item as? PassAction) != nil
    }
}
