//
//  ExactActionTests.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import XCTest
import MessagePack
@testable import DiceLogicEngine

class ExactActionTests: XCTestCase
{
    override func setUp()
    {
        super.setUp()
        
        Random.random = Random.newGenerator(0)
        Handlers.Error = { XCTFail($0) }
        Handlers.Warning = { XCTFail($0) }
    }
    
    func testEquality()
    {
        let action1 = ExactAction(player: "Alice", correct: true)
        let action2 = HistoryAction(player: "Alice", correct: true, type: .exactAction)
        let action3 = HistoryAction(player: "Alice", correct: true, type: .pushAction)
        let action4 = ExactAction(player: "Alice", correct: true)
        
        XCTAssertFalse(action1 == action2)
        XCTAssertFalse(action1 == action3)
        XCTAssertTrue(action1 == action4)
    }
    
    func testSerialization()
    {
        Handlers.Error = { _ in }

        
        let action = ExactAction(player: "Alice", correct: true)
        let action_restored = ExactAction(data: action.asData())
        
        XCTAssertTrue(action == action_restored)
        
        XCTAssertNil(ExactAction(data: [
            .UInt(HistoryItem.HIType.invalid.rawValue),
            .String("Alice"),
            .Bool(true)
            ]))
    }
}
