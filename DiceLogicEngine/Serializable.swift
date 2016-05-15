//
//  Serializable.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import MessagePack

public protocol Serializable
{
    init(data: MessagePackValue)
    func asData() -> MessagePackValue
}
