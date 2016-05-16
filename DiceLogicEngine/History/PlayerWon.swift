//
//  PlayerWon.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/16/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import MessagePack

public class PlayerWon: PlayerInfoItem
{
    public init(player: String)
    {
        super.init(player: player, type: .PlayerWon)
    }
    
    required public init?(data: MessagePackValue)
    {
        super.init(data: data)
        
        guard self.type == .PlayerWon else {
            error("Must be a PlayerWon to initialize as such")
            return nil
        }
    }
    
    public override func isEqualTo(item: HistoryItem) -> Bool
    {
        guard super.isEqualTo(item) else {
            return false
        }
        
        return (item as? PlayerWon) != nil
    }
}
