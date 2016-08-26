//
//  BidAction.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import MessagePack

public class BidAction: PushAction
{
    static private let countKey: Int = PushAction.pushMaxKey+1
    static private let faceKey: Int = PushAction.pushMaxKey+2

    public internal(set) var count: UInt = 0
    public internal(set) var face: UInt = 0

    public init(player: String,
                count: UInt,
                face: UInt,
                pushedDice: [UInt],
                newDice: [UInt],
                correct: Bool)
    {
        super.init(player: player,
                   pushedDice: pushedDice,
                   newDice: newDice,
                   correct: correct,
                   type: .bidAction)

        self.count = count
        self.face = face
    }

    required public init?(data: MessagePackValue)
    {
        super.init(data: data)

        guard self.type == .bidAction else {
            ErrorHandling.error("Must be a BidAction to initialize as such")
            return nil
        }

        let array = data.arrayValue!

        guard array.count >= PushAction.pushMaxKey+3 else {
            ErrorHandling.error("BidAction data must have an" +
                                "array of size \(PushAction.pushMaxKey+3)")
            return nil
        }

        guard let count = array[BidAction.countKey].unsignedIntegerValue else {
            ErrorHandling.error("BidAction data must have a count key")
            return nil
        }

        guard let face = array[BidAction.faceKey].unsignedIntegerValue else {
            ErrorHandling.error("BidAction data must have a die face key")
            return nil
        }

        self.count = UInt(count)
        self.face = UInt(face)
    }

    public override func asData() -> MessagePackValue
    {
        var array = super.asData().arrayValue!

        array.append(.UInt(UInt64(count)))
        array.append(.UInt(UInt64(face)))

        return .Array(array)
    }

    public override func isEqualTo(_ item: HistoryItem) -> Bool
    {
        guard super.isEqualTo(item) else {
            return false
        }

        guard let item = (item as? BidAction) else {
            return false
        }

        return count == item.count && face == item.face
    }
}
