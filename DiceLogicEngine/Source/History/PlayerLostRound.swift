//
//  PlayerLostRound.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/16/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import MessagePack

public class PlayerLostRound: PlayerInfoItem
{
    public init(player: String)
    {
        super.init(player: player, type: .playerLostRound)
    }

    required public init?(data: MessagePackValue)
    {
        super.init(data: data)

        guard self.type == .playerLostRound else {
            ErrorHandling.error("Must be a PlayerLostRound to initialize as such")
            return nil
        }
    }

    public override func isEqualTo(_ item: HistoryItem) -> Bool
    {
        guard super.isEqualTo(item) else {
            return false
        }

        return (item as? PlayerLostRound) != nil
    }
}
