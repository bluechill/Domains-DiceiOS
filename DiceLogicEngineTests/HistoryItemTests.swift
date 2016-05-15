//
//  HistoryItemTests.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import XCTest
@testable import DiceLogicEngine

class HistoryItemTests: XCTestCase
{
    func testInitialization()
    {
        let item = HistoryItem(type: .Invalid)
        let item2 = HistoryItem(type:  .Action)
        
        XCTAssertTrue(item.type == .Invalid)
        XCTAssertTrue(item2.type == .Action)
    }
    
    func testEquality()
    {
        let item = HistoryItem(type: .Invalid)
        let item2 = HistoryItem(type: .Invalid)
        
        XCTAssertTrue(item == item2)
        
        let item3 = HistoryItem(type: .Action)
        
        XCTAssertFalse(item2 == item3)
    }
    
    func testSerialization()
    {
        let item = HistoryItem(type: .Action)
        let item_restore = HistoryItem(data: item.asData())
        
        XCTAssertTrue(item_restore != nil)
        XCTAssertTrue(item == item_restore!)
        
        XCTAssertNil(HistoryItem(data: .Int(0)))
        XCTAssertNil(HistoryItem(data: []))
        XCTAssertNil(HistoryItem(data: [.Int(-1)]))
        
        let typeInt = HistoryItem.HIType.PlayerWon.rawValue + 1
        XCTAssertNil(HistoryItem(data: [.UInt(typeInt)]))
    }
}
