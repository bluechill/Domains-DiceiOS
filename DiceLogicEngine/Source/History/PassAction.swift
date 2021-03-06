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
    public init(player: String, pushedDice: [UInt], newDice: [UInt], correct: Bool)
    {
        super.init(player: player,
                   pushedDice: pushedDice,
                   newDice: newDice,
                   correct: correct,
                   type: .passAction)
    }

    required public init?(data: MessagePackValue)
    {
        super.init(data: data)

        guard self.type == .passAction else {
            ErrorHandling.error("Must be a PassAction to initialize as such")
            return nil
        }
    }

    public override func isEqual(_ item: Any?) -> Bool
    {
        guard super.isEqual(item) else {
            return false
        }

        return (item as? PassAction) != nil
    }
}
