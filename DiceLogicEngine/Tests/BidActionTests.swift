//
//  BidActionTests.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import XCTest
import MessagePack
@testable import DiceLogicEngine

class BidActionTests: XCTestCase
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
        let item = BidAction(player: "Alice", count: 1, face: 2, pushedDice: [1,2,3], newDice: [0,1], correct: true)
        
        XCTAssertTrue(item.count == 1)
        XCTAssertTrue(item.face == 2)
    }
    
    func testEquality()
    {
        let item1 = BidAction(player: "Alice", count: 1, face: 2, pushedDice: [], newDice: [], correct: true)
        let item2 = BidAction(player: "Alice", count: 1, face: 2, pushedDice: [], newDice: [], correct: true)
        let item3 = BidAction(player: "Alice", count: 2, face: 2, pushedDice: [], newDice: [], correct: true)
        let item4 = BidAction(player: "Alice", count: 2, face: 3, pushedDice: [], newDice: [], correct: true)
        
        XCTAssertTrue(item1 == item2)
        XCTAssertFalse(item2 == item3)
        XCTAssertFalse(item2 == item4)
        XCTAssertFalse(item3 == item4)
        
        let action = PushAction(player: "Alice", pushedDice: [], newDice: [], correct: true, type: .bidAction)
        XCTAssertFalse(item1 == action)
        
        let action2 = HistoryItem(type: .action)
        XCTAssertFalse(item1 == action2)
    }
    
    func testSerialization()
    {
        Handlers.Error = { _ in }
        
        let item = BidAction(player: "Alice", count: 1, face: 2, pushedDice: [], newDice: [], correct: true)
        let item_restore = BidAction(data: item.asData())
        
        XCTAssertTrue(item == item_restore)
        
        XCTAssertNil(BidAction(data: [.UInt(HistoryItem.HIType.bidAction.rawValue),"Alice",.Bool(false),[],[]]))
        XCTAssertNil(BidAction(data: [.UInt(HistoryItem.HIType.bidAction.rawValue),"Alice",.Bool(false),[],[],1]))
        XCTAssertNil(BidAction(data: [.UInt(HistoryItem.HIType.bidAction.rawValue),"Alice",.Bool(false),[],[],-1]))
        
        XCTAssertNil(BidAction(data: [.UInt(HistoryItem.HIType.bidAction.rawValue),"Alice",.Bool(false),[],[],1,-1]))
        XCTAssertNil(BidAction(data: [.UInt(HistoryItem.HIType.bidAction.rawValue),"Alice",.Bool(false),[],[],-1,-1]))
        XCTAssertNil(BidAction(data: [.UInt(HistoryItem.HIType.bidAction.rawValue),"Alice",.Bool(false),[],[],-1,1]))
        
        XCTAssertNil(BidAction(data: [.UInt(HistoryItem.HIType.invalid.rawValue),"Alice",.Bool(false),[],[],1,2]))
        
        XCTAssertNotNil(BidAction(data: [.UInt(HistoryItem.HIType.bidAction.rawValue),"Alice",.Bool(false),[],[],1,2]))
        
        XCTAssertNil(BidAction(data: [
            .UInt(HistoryItem.HIType.invalid.rawValue),
            .String("Alice"),
            .Bool(true),
            [],
            .UInt(1),
            .UInt(1)
            ]))
    }
}