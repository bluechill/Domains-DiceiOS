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
    static let specialMaxKey: Int = itemMaxKey+1
    static private let playerKey: Int = itemMaxKey+1

    public internal(set) var player: String = ""

    public init(player: String)
    {
        super.init(type: .specialRulesInEffect)

        self.player = player
    }

    required public init?(data: MessagePackValue)
    {
        super.init(data: data)

        guard self.type == .specialRulesInEffect else {
            ErrorHandling.error("Must be a SpecialRulesInEffect to initialize as such")
            return nil
        }

        let array = data.arrayValue!

        guard let player = array[SpecialRulesInEffect.playerKey].stringValue else {
            ErrorHandling.error("Must have the player who caused special rules")
            return nil
        }

        self.player = player
    }

    public override func asData() -> MessagePackValue
    {
        var array = super.asData().arrayValue!

        array.append(.string(player))

        return .array(array)
    }

    public override func isEqual(_ item: Any?) -> Bool
    {
        guard super.isEqual(item) else {
            return false
        }

        guard let item = (item as? SpecialRulesInEffect) else {
            return false
        }
        
        return item.player == player
    }
}
