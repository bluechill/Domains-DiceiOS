//
//  PlayerLost.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/16/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import MessagePack

public class PlayerLost: PlayerInfoItem
{
    public init(player: String)
    {
        super.init(player: player, type: .PlayerLost)
    }
    
    required public init?(data: MessagePackValue)
    {
        super.init(data: data)
        
        guard self.type == .PlayerLost else {
            error("Must be a PlayerLost to initialize as such")
            return nil
        }
    }
    
    public override func isEqualTo(item: HistoryItem) -> Bool
    {
        guard super.isEqualTo(item) else {
            return false
        }
        
        return (item as? PlayerLost) != nil
    }
}
