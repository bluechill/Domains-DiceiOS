//
//  HistoryActionTests.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import XCTest
@testable import DiceLogicEngine

class HistoryActionTests: XCTestCase
{
    override func setUp()
    {
        super.setUp()

        Random.random = Random.newGenerator(0)
        Handlers.Error = { XCTFail($0) }
        Handlers.Warning = { XCTFail($0) }
    }

    func testInitialization()
    {
        let action = HistoryAction(player: "Alice", correct: true)
        XCTAssertTrue(action.player == "Alice")
        XCTAssertTrue(action.correct)

        let action2 = HistoryAction(player: "Bob", correct: false)
        XCTAssertTrue(action2.player == "Bob")
        XCTAssertFalse(action2.correct)
    }

    func testSerialization()
    {
        Handlers.Error = { _ in }

        let action = HistoryAction(player: "Alice", correct: true)
        let action_restore = HistoryAction(data: action.asData())

        XCTAssertTrue(action == action_restore)

        XCTAssertNil(HistoryAction(data: []))
        XCTAssertNil(HistoryAction(data: [.int(-1)]))
        XCTAssertNil(HistoryAction(data: [.uint(HistoryItem.HIType.invalid.rawValue)]))
        XCTAssertNil(HistoryAction(data: [.uint(HistoryItem.HIType.action.rawValue)]))
        XCTAssertNil(HistoryAction(data: [.uint(HistoryItem.HIType.action.rawValue), .int(0)]))
        XCTAssertNil(HistoryAction(data: [.uint(HistoryItem.HIType.action.rawValue), .int(0), .int(0)]))
        XCTAssertNil(HistoryAction(data: [.uint(HistoryItem.HIType.action.rawValue), "Alice", .int(0)]))
        XCTAssertNotNil(HistoryAction(data: [.uint(HistoryItem.HIType.action.rawValue), "Alice", .bool(false)]))
    }

    func testEquality()
    {
        let action = HistoryAction(player: "Alice", correct: false)
        let action2 = HistoryAction(player: "Alice", correct: true)
        let action3 = HistoryAction(player: "Bob", correct: false)
        let action4 = HistoryAction(player: "Bob", correct: true)

        let action5 = HistoryAction(player: "Alice", correct: false)
        let action6 = HistoryAction(player: "Alice", correct: true)
        let action7 = HistoryAction(player: "Bob", correct: false)
        let action8 = HistoryAction(player: "Bob", correct: true)

        XCTAssertTrue(action == action5)
        XCTAssertTrue(action2 == action6)
        XCTAssertTrue(action3 == action7)
        XCTAssertTrue(action4 == action8)

        XCTAssertFalse(action == action2)
        XCTAssertFalse(action == action3)
        XCTAssertFalse(action == action4)

        XCTAssertFalse(action2 == action)
        XCTAssertFalse(action2 == action3)
        XCTAssertFalse(action2 == action4)

        XCTAssertFalse(action3 == action2)
        XCTAssertFalse(action3 == action)
        XCTAssertFalse(action3 == action4)

        XCTAssertFalse(action4 == action2)
        XCTAssertFalse(action4 == action3)
        XCTAssertFalse(action4 == action)

        XCTAssertTrue(action == (action5 as HistoryItem))
        XCTAssertTrue((action as HistoryItem) == action5)

        XCTAssertFalse(action == (action2 as HistoryItem))
        XCTAssertFalse((action as HistoryItem) == action2)

        XCTAssertFalse(HistoryItem(type: .invalid) == action)

        let action9 = HistoryAction(player: "Alice", correct: false, type: .bidAction)
        XCTAssertFalse(action == action9)

        let action10 = HistoryItem(type: .action)
        XCTAssertFalse(action == action10)
    }
}
