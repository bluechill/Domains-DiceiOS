//
//  InfoItem.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/16/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import MessagePack

public class PlayerInfoItem: HistoryItem
{
    static let infoMaxKey: Int = itemMaxKey+1
    static private let playerKey: Int = itemMaxKey+1

    public internal(set) var player: String = ""

    public init(player: String, type: HIType = .playerInfoItem)
    {
        super.init(type: type)

        self.player = player
    }

    required public init?(data: MessagePackValue)
    {
        super.init(data: data)

        let array = data.arrayValue!

        guard array.count >= PlayerInfoItem.infoMaxKey+1 else {
            ErrorHandling.error("PlayerInfoItem data must have an " +
                                "array of size \(PlayerInfoItem.itemMaxKey+1)!")
            return nil
        }

        guard let player = array[PlayerInfoItem.playerKey].stringValue else {
            ErrorHandling.error("PlayerInfoItem data has no player")
            return nil
        }

        self.player = player
    }

    public override func asData() -> MessagePackValue
    {
        var array = super.asData().arrayValue!

        array.append(.String(player))

        return .Array(array)
    }

    public override func isEqualTo(_ item: HistoryItem) -> Bool
    {
        guard super.isEqualTo(item) else {
            return false
        }

        guard let item = (item as? PlayerInfoItem) else {
            return false
        }

        return player == item.player
    }
}
