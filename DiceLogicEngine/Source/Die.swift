//
//  Die.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import MessagePack

public class Die: NSObject, Serializable
{
    static private let faceKey = 0
    static private let pushedKey = 1

    static public let sides: UInt = 6

    private var _face: UInt = 1
    public internal(set) var face: UInt
    {
        get
        {
            return _face
        }

        set
        {
            if newValue < 1
            {
                ErrorHandling.error("Invalid Die Face.  Setting it to 1.")
                _face = 1
            }
            else if newValue > Die.sides
            {
                ErrorHandling.error("Invalid Die Face.  Setting it to \(Die.sides).")
                _face = Die.sides
            }
            else
            {
                _face = newValue
            }
        }
    }

    public var pushed: Bool = false

    override init()
    {
        super.init()

        self.face = UInt(Random.random.nextInt())
        self.pushed = false
    }

    init(face: UInt, pushed: Bool = false)
    {
        super.init()

        self.face = face
        self.pushed = pushed
    }

    required public init(data: MessagePackValue)
    {
        super.init()

        guard let dieArray = data.arrayValue else {
            ErrorHandling.error("Bad data passed to Die initializer: data is not an array")
            return
        }

        guard dieArray.count == 2 else {
            ErrorHandling.error("Die data is not an array of size 2")
            return
        }

        guard let face = dieArray[Die.faceKey].unsignedIntegerValue else
        {
            ErrorHandling.error("Die has no face key")
            return
        }

        guard let pushed = dieArray[Die.pushedKey].boolValue else
        {
            ErrorHandling.error("Die has no pushed key")
            return
        }

        self.face = UInt(face)
        self.pushed = pushed
    }

    public func asData() -> MessagePackValue
    {
        let array: [MessagePackValue] = [.uint(UInt64(self.face)), .bool(self.pushed)]
        return .array(array)
    }

    func roll()
    {
        self.face = UInt(Random.random.nextInt())
        self.pushed = false
    }

    override public func isEqual(_ object: Any?) -> Bool {
        let lhs = self

        if (object is Die)
        {
            let rhs = (object as! Die)

            return lhs.face == rhs.face && lhs.pushed == rhs.pushed
        }
        else if (object is UInt)
        {
            let rhs = (object as! UInt)

            return lhs.face == rhs && lhs.pushed == false
        }

        return false;
    }
}

public func == (lhs: Die, rhs: Die) -> Bool
{
    return lhs.isEqual(rhs)
}

public func == (lhs: Die, rhs: UInt) -> Bool
{
    return lhs.isEqual(rhs)
}

public func == (lhs: UInt, rhs: Die) -> Bool
{
    return rhs == lhs
}
