//
//  PushActionTests.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import XCTest
@testable import DiceLogicEngine

class PushActionTests: XCTestCase
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
        let item = PushAction(player: "Alice", pushedDice: [1,2,3], newDice: [0,1], correct: true, type: .pushAction)
        
        XCTAssertTrue(item.pushedDice == [1,2,3])
        XCTAssertTrue(item.newDice == [0,1])
    }
    
    func testEquality()
    {
        let item1 = PushAction(player: "Alice", pushedDice: [0,1,2], newDice: [0,1], correct: true)
        let item2 = PushAction(player: "Alice", pushedDice: [0,1,2], newDice: [0,1], correct: true)
        let item3 = PushAction(player: "Alice", pushedDice: [0,2,2], newDice: [0,1], correct: true)
        
        XCTAssertTrue(item1 == item2)
        XCTAssertFalse(item2 == item3)
        
        let action = HistoryAction(player: "Alice", correct: true, type: .pushAction)
        XCTAssertFalse(item1 == action)
        
        let action2 = HistoryAction(player: "Alice", correct: true, type: .action)
        XCTAssertFalse(item1 == action2)
    }
    
    func testSerialization()
    {
        Handlers.Error = { _ in }

        let item = PushAction(player: "Alice", pushedDice: [0,1,2], newDice: [0,1], correct: true)
        let item_restore = PushAction(data: item.asData())
        
        XCTAssertTrue(item == item_restore)
        
        XCTAssertNil(PushAction(data: [.UInt(HistoryItem.HIType.pushAction.rawValue),"Alice",.Bool(false)]))
        XCTAssertNil(PushAction(data: [.UInt(HistoryItem.HIType.pushAction.rawValue),"Alice",.Bool(false),-1]))
        XCTAssertNil(PushAction(data: [.UInt(HistoryItem.HIType.pushAction.rawValue),"Alice",.Bool(false),[-1,-2,-3]]))
        XCTAssertNil(PushAction(data: [.UInt(HistoryItem.HIType.pushAction.rawValue),"Alice",.Bool(false),[],-1]))
        XCTAssertNil(PushAction(data: [.UInt(HistoryItem.HIType.pushAction.rawValue),"Alice",.Bool(false),[],[-1,-2,-3]]))
        XCTAssertNil(PushAction(data: [.UInt(HistoryItem.HIType.pushAction.rawValue),"Alice",.Bool(false),"S",[0,1,2,3]]))
        XCTAssertNil(PushAction(data: [.UInt(HistoryItem.HIType.pushAction.rawValue),"Alice",.Bool(false),[-1,1,2,3],[0,1,2,3]]))
        
        XCTAssertNotNil(PushAction(data: [.UInt(HistoryItem.HIType.pushAction.rawValue),"Alice",.Bool(false),[],[]]))
        XCTAssertNotNil(PushAction(data: [.UInt(HistoryItem.HIType.pushAction.rawValue),"Alice",.Bool(false),[0,1,2,3],[0,1,2,3]]))
    }
}
