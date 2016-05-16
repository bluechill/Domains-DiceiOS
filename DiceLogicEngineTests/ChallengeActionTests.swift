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
        
        let action = HistoryAction(player: "Alice", correct: true, type: .ChallengeAction)
        XCTAssertFalse(item1 == action)
        
        let action2 = HistoryAction(player: "Alice", correct: true, type: .Action)
        XCTAssertFalse(item1 == action2)
    }
    
    func testSerialization()
    {
        let item = ChallengeAction(player: "Alice", challengee: "Bob", challengeActionIndex: 1, correct: true)
        let item_restore = ChallengeAction(data: item.asData())
        
        XCTAssertTrue(item == item_restore)
        
        XCTAssertNil(ChallengeAction(data: [.UInt(HistoryItem.HIType.ChallengeAction.rawValue),"Alice",.Bool(false)]))
        XCTAssertNil(ChallengeAction(data: [.UInt(HistoryItem.HIType.ChallengeAction.rawValue),"Alice",.Bool(false),"Bob"]))
        XCTAssertNil(ChallengeAction(data: [.UInt(HistoryItem.HIType.ChallengeAction.rawValue),"Alice",.Bool(false),"Bob","a"]))
        
        XCTAssertNotNil(ChallengeAction(data: [.UInt(HistoryItem.HIType.ChallengeAction.rawValue),"Alice",.Bool(false),"Bob",1]))
    }
}