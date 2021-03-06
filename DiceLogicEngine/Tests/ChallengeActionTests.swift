//
//  ChallengeActionTests.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import XCTest
@testable import DiceLogicEngine

class ChallengeActionTests: XCTestCase
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
        let item = ChallengeAction(player: "Alice", challengee: "Bob", challengeActionIndex: 1, correct: true)

        XCTAssertTrue(item.challengee == "Bob")
        XCTAssertTrue(item.challengeActionIndex == 1)
    }

    func testEquality()
    {
        let item1 = ChallengeAction(player: "Alice", challengee: "Bob", challengeActionIndex: 1, correct: true)
        let item2 = ChallengeAction(player: "Alice", challengee: "Bob", challengeActionIndex: 1, correct: true)
        let item3 = ChallengeAction(player: "Alice", challengee: "Eve", challengeActionIndex: 1, correct: true)

        XCTAssertTrue(item1 == item2)
        XCTAssertFalse(item2 == item3)

        let action = HistoryAction(player: "Alice", correct: true, type: .challengeAction)
        XCTAssertFalse(item1 == action)

        let action2 = HistoryAction(player: "Alice", correct: true, type: .action)
        XCTAssertFalse(item1 == action2)
    }

    func testSerialization()
    {
        Handlers.Error = { _ in }

        let item = ChallengeAction(player: "Alice", challengee: "Bob", challengeActionIndex: 1, correct: true)
        let item_restore = ChallengeAction(data: item.asData())

        XCTAssertTrue(item == item_restore)

        XCTAssertNil(ChallengeAction(data: [.uint(HistoryItem.HIType.challengeAction.rawValue), "Alice", .bool(false)]))
        XCTAssertNil(ChallengeAction(data: [.uint(HistoryItem.HIType.challengeAction.rawValue), "Alice", .bool(false), "Bob"]))
        XCTAssertNil(ChallengeAction(data: [.uint(HistoryItem.HIType.challengeAction.rawValue), "Alice", .bool(false), .int(5), .int(1)]))
        XCTAssertNil(ChallengeAction(data: [.uint(HistoryItem.HIType.challengeAction.rawValue), "Alice", .bool(false), "Bob", "a"]))

        XCTAssertNotNil(ChallengeAction(data: [.uint(HistoryItem.HIType.challengeAction.rawValue), "Alice", .bool(false), "Bob", .int(1)]))

        XCTAssertNil(ChallengeAction(data: [
            .uint(HistoryItem.HIType.invalid.rawValue),
            .string("Alice"),
            .bool(true),
            .string("Bob"),
            .int(0)
            ]))
    }
}
