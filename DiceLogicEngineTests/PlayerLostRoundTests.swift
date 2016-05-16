//
//  PlayerLostRoundTests.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/16/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import XCTest
import MessagePack
@testable import DiceLogicEngine

class PlayerLostRoundTests: XCTestCase
{
    func testEquality()
    {
        let action1 = PlayerLostRound(player: "Alice")
        let action2 = PlayerLostRound(player: "Alice")
        let action3 = PlayerLostRound(player: "Bob")
        
        XCTAssertTrue(action1 == action2)
        XCTAssertFalse(action1 == action3)
    }
    
    func testSerialization()
    {
        let action = PlayerLostRound(player: "Alice")
        let action_restored = PlayerLostRound(data: action.asData())
        
        XCTAssertTrue(action == action_restored)
        
        XCTAssertNil(PlayerLostRound(data: [
            .UInt(HistoryItem.HIType.Invalid.rawValue),
            .String("Alice")
            ]))
    }
}
