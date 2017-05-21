//
//  InfoItemTests.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/16/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import XCTest
@testable import DiceLogicEngine

class PlayerInfoItemTests: XCTestCase
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
        let item = PlayerInfoItem(player: "Alice")
        XCTAssertTrue(item.player == "Alice")
        XCTAssertTrue(item.type == .playerInfoItem)
    }

    func testSerialization()
    {
        Handlers.Error = { _ in }

        let action = PlayerInfoItem(player: "Alice")
        let action_restore = PlayerInfoItem(data: action.asData())

        XCTAssertTrue(action == action_restore)

        XCTAssertNil(PlayerInfoItem(data: []))
        XCTAssertNil(PlayerInfoItem(data: [.int(-1)]))
        XCTAssertNil(PlayerInfoItem(data: [.uint(HistoryItem.HIType.invalid.rawValue)]))
        XCTAssertNil(PlayerInfoItem(data: [.uint(HistoryItem.HIType.playerInfoItem.rawValue)]))
        XCTAssertNil(PlayerInfoItem(data: [.uint(HistoryItem.HIType.playerInfoItem.rawValue), .int(0)]))
        XCTAssertNotNil(PlayerInfoItem(data: [.uint(HistoryItem.HIType.playerInfoItem.rawValue), "Alice"]))
    }

    func testEquality()
    {
        let action = PlayerInfoItem(player: "Alice")
        let action2 = PlayerInfoItem(player: "Alice")
        let action3 = PlayerInfoItem(player: "Bob")

        XCTAssertTrue(action == action2)
        XCTAssertFalse(action == action3)

        XCTAssertTrue(action == (action2 as HistoryItem))
        XCTAssertTrue((action as HistoryItem) == action2)

        XCTAssertFalse(action == (action3 as HistoryItem))
        XCTAssertFalse((action as HistoryItem) == action3)

        XCTAssertFalse(HistoryItem(type: .invalid) == action)

        let action9 = PlayerInfoItem(player: "Alice", type: .invalid)
        XCTAssertFalse(action == action9)

        let action10 = HistoryItem(type: .playerInfoItem)
        XCTAssertFalse(action == action10)
    }
}
