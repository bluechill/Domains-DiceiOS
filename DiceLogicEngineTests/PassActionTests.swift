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
    func testEquality()
    {
        let action1 = PassAction(player: "Alice", pushedDice: [], correct: true)
        let action2 = PushAction(player: "Alice", pushedDice: [], correct: true, type: .PassAction)
        let action3 = PushAction(player: "Alice", pushedDice: [], correct: true, type: .PushAction)
        let action4 = PassAction(player: "Alice", pushedDice: [], correct: true)
        
        XCTAssertFalse(action1 == action2)
        XCTAssertFalse(action1 == action3)
        XCTAssertTrue(action1 == action4)
    }
    
    func testSerialization()
    {
        let action = PassAction(player: "Alice", pushedDice: [], correct: true)
        let action_restored = PassAction(data: action.asData())
        
        XCTAssertTrue(action == action_restored)
    }
}
