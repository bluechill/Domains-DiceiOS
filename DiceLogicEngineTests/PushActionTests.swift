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
    func testInitialization()
    {
        let item = PushAction(player: "Alice", pushedDice: [1,2,3], correct: true, type: .PushAction)
        
        XCTAssertTrue(item.pushedDice == [1,2,3])
    }
    
    func testEquality()
    {
        let item1 = PushAction(player: "Alice", pushedDice: [0,1,2,3,4,5,6,7,8,9,10], correct: true)
        let item2 = PushAction(player: "Alice", pushedDice: [0,1,2,3,4,5,6,7,8,9,10], correct: true)
        let item3 = PushAction(player: "Alice", pushedDice: [0,2,2,3,4,5,6,7,8,9,11], correct: true)
        
        XCTAssertTrue(item1 == item2)
        XCTAssertFalse(item2 == item3)
        
        let action = HistoryAction(player: "Alice", correct: true, type: .PushAction)
        XCTAssertFalse(item1 == action)
        
        let action2 = HistoryAction(player: "Alice", correct: true, type: .Action)
        XCTAssertFalse(item1 == action2)
    }
    
    func testSerialization()
    {
        let item = PushAction(player: "Alice", pushedDice: [0,1,2,3,4,5,6,7,8,9,10], correct: true)
        let item_restore = PushAction(data: item.asData())
        
        XCTAssertTrue(item == item_restore)
        
        XCTAssertNil(PushAction(data: [.UInt(HistoryItem.HIType.PushAction.rawValue),"Alice",.Bool(false)]))
        XCTAssertNil(PushAction(data: [.UInt(HistoryItem.HIType.PushAction.rawValue),"Alice",.Bool(false),-1]))
        XCTAssertNil(PushAction(data: [.UInt(HistoryItem.HIType.PushAction.rawValue),"Alice",.Bool(false),[-1,-2,-3]]))
       
        XCTAssertNotNil(PushAction(data: [.UInt(HistoryItem.HIType.PushAction.rawValue),"Alice",.Bool(false),[]]))
        XCTAssertNotNil(PushAction(data: [.UInt(HistoryItem.HIType.PushAction.rawValue),"Alice",.Bool(false),[0,1,2,3]]))
    }
}
