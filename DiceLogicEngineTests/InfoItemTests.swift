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
    func testInitialization()
    {
        let item = PlayerInfoItem(player: "Alice")
        XCTAssertTrue(item.player == "Alice")
        XCTAssertTrue(item.type == .PlayerInfoItem)
    }
    
    func testSerialization()
    {
        let action = PlayerInfoItem(player: "Alice")
        let action_restore = PlayerInfoItem(data: action.asData())
        
        XCTAssertTrue(action == action_restore)
        
        XCTAssertNil(PlayerInfoItem(data: []))
        XCTAssertNil(PlayerInfoItem(data: [.Int(-1)]))
        XCTAssertNil(PlayerInfoItem(data: [.UInt(HistoryItem.HIType.Invalid.rawValue)]))
        XCTAssertNil(PlayerInfoItem(data: [.UInt(HistoryItem.HIType.PlayerInfoItem.rawValue)]))
        XCTAssertNil(PlayerInfoItem(data: [.UInt(HistoryItem.HIType.PlayerInfoItem.rawValue),.Int(0)]))
        XCTAssertNotNil(PlayerInfoItem(data: [.UInt(HistoryItem.HIType.PlayerInfoItem.rawValue),"Alice"]))
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
        
        XCTAssertFalse(HistoryItem(type: .Invalid) == action)
        
        let action9 = PlayerInfoItem(player: "Alice", type: .Invalid)
        XCTAssertFalse(action == action9)
        
        let action10 = HistoryItem(type: .PlayerInfoItem)
        XCTAssertFalse(action == action10)
    }
}
