//
//  PassActionTests.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import XCTest
import MessagePack
@testable import DiceLogicEngine

class PassActionTests: XCTestCase
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
        let action1 = PassAction(player: "Alice", pushedDice: [], newDice: [], correct: true)
        let action2 = PushAction(player: "Alice", pushedDice: [], newDice: [], correct: true, type: .passAction)
        let action3 = PushAction(player: "Alice", pushedDice: [], newDice: [], correct: true, type: .pushAction)
        let action4 = PassAction(player: "Alice", pushedDice: [], newDice: [], correct: true)
        
        XCTAssertFalse(action1 == action2)
        XCTAssertFalse(action1 == action3)
        XCTAssertTrue(action1 == action4)
    }
    
    func testSerialization()
    {
        Handlers.Error = { _ in }

        let action = PassAction(player: "Alice", pushedDice: [], newDice: [], correct: true)
        let action_restored = PassAction(data: action.asData())

        XCTAssertTrue(action == action_restored)
        
        XCTAssertNil(PassAction(data: [
            .uInt(HistoryItem.HIType.invalid.rawValue),
            .string("Alice"),
            .bool(true),
            [],
            []
            ]))
        
        XCTAssertNotNil(PassAction(data: [
            .uInt(HistoryItem.HIType.passAction.rawValue),
            .string("Alice"),
            .bool(true),
            [],
            []
            ]))
    }
}
