//
//  Die.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import MessagePack

public class Die: Equatable, Serializable
{
    static private let faceKey = 0
    static private let pushedKey = 1
    
    static public let sides: UInt = 6
    
    private var _face: UInt = 1
    public internal(set) var face : UInt
    {
        get
        {
            return _face
        }
        
        set
        {
            if newValue < 1
            {
                error("Invalid Die Face.  Setting it to 1.")
                _face = 1
            }
            else if newValue > Die.sides
            {
                error("Invalid Die Face.  Setting it to \(Die.sides).")
                _face = Die.sides
            }
            else
            {
                _face = newValue
            }
        }
    }
    
    public var pushed: Bool = false
    
    init()
    {
        self.face = UInt(Random.dieFaceGenerator.nextInt())
        self.pushed = false
    }
    
    init(face: UInt, pushed: Bool = false)
    {
        self.face = face
        self.pushed = pushed
    }
    
    required public init(data: MessagePackValue)
    {
        guard let dieArray = data.arrayValue else {
            error("Bad data passed to Die initializer: data is not an array")
            return
        }
        
        guard dieArray.count == 2 else {
            error("Die data is not an array of size 2")
            return
        }
        
        guard let face = dieArray[Die.faceKey].unsignedIntegerValue else
        {
            error("Die has no face key")
            return
        }
        
        guard let pushed = dieArray[Die.pushedKey].boolValue else
        {
            error("Die has no pushed key")
            return
        }
        
        self.face = UInt(face)
        self.pushed = pushed
    }
    
    public func asData() -> MessagePackValue
    {
        let array: [MessagePackValue] = [.UInt(UInt64(self.face)), .Bool(self.pushed)]
        return .Array(array)
    }
    
    func roll()
    {
        self.face = UInt(Random.dieFaceGenerator.nextInt())
        self.pushed = false
    }
}

public func ==(lhs: Die, rhs: Die) -> Bool
{
    return lhs._face == rhs._face && lhs.pushed == rhs.pushed
}

public func ==(lhs: Die, rhs: UInt) -> Bool
{
    return lhs._face == rhs && lhs.pushed == false
}

public func ==(lhs: UInt, rhs: Die) -> Bool
{
    return rhs == lhs
}
