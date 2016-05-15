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
    func testInitialization()
    {
        let action = HistoryAction(player: "test", correct: true)
        XCTAssertTrue(action.player == "test")
        XCTAssertTrue(action.correct)
        
        let action2 = HistoryAction(player: "test2", correct: false)
        XCTAssertTrue(action2.player == "test2")
        XCTAssertFalse(action2.correct)
    }
    
    func testSerialization()
    {
        let action = HistoryAction(player: "test", correct: true)
        let action_restore = HistoryAction(data: action.asData())
        
        XCTAssertTrue(action == action_restore)
        
        XCTAssertNil(HistoryAction(data: []))
        XCTAssertNil(HistoryAction(data: [.Int(-1)]))
        XCTAssertNil(HistoryAction(data: [.UInt(HistoryItem.HIType.Invalid.rawValue)]))
        XCTAssertNil(HistoryAction(data: [.UInt(HistoryItem.HIType.Action.rawValue)]))
        XCTAssertNil(HistoryAction(data: [.UInt(HistoryItem.HIType.Action.rawValue),.Int(0)]))
        XCTAssertNil(HistoryAction(data: [.UInt(HistoryItem.HIType.Action.rawValue),.Int(0),.Int(0)]))
        XCTAssertNil(HistoryAction(data: [.UInt(HistoryItem.HIType.Action.rawValue),"test",.Int(0)]))
        XCTAssertNotNil(HistoryAction(data: [.UInt(HistoryItem.HIType.Action.rawValue),"test",.Bool(false)]))
    }
    
    func testEquality()
    {
        let action = HistoryAction(player: "test", correct: false)
        let action2 = HistoryAction(player: "test", correct: true)
        let action3 = HistoryAction(player: "test2", correct: false)
        let action4 = HistoryAction(player: "test2", correct: true)
        
        let action5 = HistoryAction(player: "test", correct: false)
        let action6 = HistoryAction(player: "test", correct: true)
        let action7 = HistoryAction(player: "test2", correct: false)
        let action8 = HistoryAction(player: "test2", correct: true)
        
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
        
        XCTAssertFalse(HistoryItem(type: .Invalid) == action)
    }
}
