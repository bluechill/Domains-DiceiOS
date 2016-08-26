//
//  SpecialRulesInEffectTests.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/16/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import XCTest
import MessagePack
@testable import DiceLogicEngine

class SpecialRulesInEffectTests: XCTestCase
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
        let action1 = SpecialRulesInEffect(player: "Alice")
        let action2 = SpecialRulesInEffect(player: "Alice")
        let action3 = HistoryItem(type: .invalid)
        let action4 = HistoryItem(type: .specialRulesInEffect)

        XCTAssertFalse(action1 == action3)
        XCTAssertFalse(action1 == action4)
        XCTAssertTrue(action1 == action2)
    }

    func testSerialization()
    {
        Handlers.Error = { _ in }

        let action = SpecialRulesInEffect(player: "Alice")
        let action_restored = SpecialRulesInEffect(data: action.asData())

        XCTAssertTrue(action == action_restored)
        XCTAssertTrue(action.player == "Alice")

        XCTAssertNil(SpecialRulesInEffect(data: [
            .UInt(HistoryItem.HIType.invalid.rawValue)
        ]))
        XCTAssertNil(SpecialRulesInEffect(data: [
            .UInt(HistoryItem.HIType.invalid.rawValue),
            .Int(1)
        ]))
        XCTAssertNil(SpecialRulesInEffect(data: [
            .UInt(HistoryItem.HIType.specialRulesInEffect.rawValue),
            .Int(1)
        ]))
        XCTAssertNotNil(SpecialRulesInEffect(data: [
            .UInt(HistoryItem.HIType.specialRulesInEffect.rawValue),
            "Alice"
        ]))
    }
}
