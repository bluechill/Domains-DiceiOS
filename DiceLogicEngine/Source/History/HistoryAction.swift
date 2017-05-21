//
//  HistoryAction.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import MessagePack

public class HistoryAction: HistoryItem
{
    static let actionMaxKey: Int = itemMaxKey+2
    static private let playerKey: Int = itemMaxKey+1
    static private let correctKey: Int = itemMaxKey+2

    public internal(set) var player: String = ""
    public internal(set) var correct: Bool = false

    public init(player: String, correct: Bool, type: HIType = .action)
    {
        super.init(type: type)

        self.player = player
        self.correct = correct
    }

    required public init?(data: MessagePackValue)
    {
        super.init(data: data)

        let array = data.arrayValue!

        guard array.count >= HistoryAction.actionMaxKey+1 else {
            ErrorHandling.error("HistoryAction data must have an " +
                                "array of size \(HistoryAction.actionMaxKey+1)!")
            return nil
        }

        guard let player = array[HistoryAction.playerKey].stringValue else {
            ErrorHandling.error("HistoryAction data has no player")
            return nil
        }

        self.player = player

        guard let correct = array[HistoryAction.correctKey].boolValue else {
            ErrorHandling.error("HistoryAction data has no correct key")
            return nil
        }

        self.correct = correct
    }

    public override func asData() -> MessagePackValue
    {
        var array = super.asData().arrayValue!

        array.append(.string(player))
        array.append(.bool(correct))

        return .array(array)
    }

    public override func isEqual(_ item: Any?) -> Bool
    {
        guard super.isEqual(item) else {
            return false
        }

        guard let item = (item as? HistoryAction) else {
            return false
        }

        return player == item.player && correct == item.correct
    }
}
