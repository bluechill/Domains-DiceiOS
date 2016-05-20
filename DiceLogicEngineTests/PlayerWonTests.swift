//
//  PlayerWonTests.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/16/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import XCTest
import MessagePack
@testable import DiceLogicEngine

class PlayerWonTests: XCTestCase
{
    override func setUp()
    {
        super.setUp()
        
        Random.dieFaceGenerator = Random.newGenerator(0)
        Random.random = Random.newGenerator(0)
        Handlers.Error = { XCTFail($0) }
        Handlers.Warning = { XCTFail($0) }
    }
    
    func testEquality()
    {
        let action1 = PlayerWon(player: "Alice")
        let action2 = PlayerWon(player: "Alice")
        let action3 = PlayerWon(player: "Bob")
        
        XCTAssertTrue(action1 == action2)
        XCTAssertFalse(action1 == action3)
    }
    
    func testSerialization()
    {
        Handlers.Error = { _ in }

        let action = PlayerWon(player: "Alice")
        let action_restored = PlayerWon(data: action.asData())
        
        XCTAssertTrue(action == action_restored)
        
        XCTAssertNil(PlayerWon(data: [
            .UInt(HistoryItem.HIType.Invalid.rawValue),
            .String("Alice")
            ]))
    }
}
