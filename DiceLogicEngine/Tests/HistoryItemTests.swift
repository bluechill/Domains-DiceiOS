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
    override func setUp()
    {
        super.setUp()
        
        Random.random = Random.newGenerator(0)
        Handlers.Error = { XCTFail($0) }
        Handlers.Warning = { XCTFail($0) }
    }
    
    func testInitialization()
    {
        let item = HistoryItem(type: .invalid)
        let item2 = HistoryItem(type:  .action)
        
        XCTAssertTrue(item.type == .invalid)
        XCTAssertTrue(item2.type == .action)
    }
    
    func testFactoryMake()
    {
        Handlers.Error = { _ in }

        XCTAssertNil(HistoryItem.makeHistoryItem([]))
        
        let item01 = HistoryItem(type: .invalid)
        XCTAssertNil(HistoryItem.makeHistoryItem(item01.asData()))
        
        let item02 = HistoryAction(player: "Alice", correct: true)
        XCTAssertNil(HistoryItem.makeHistoryItem(item02.asData()))
        
        let item03 = PlayerInfoItem(player: "Alice")
        XCTAssertNil(HistoryItem.makeHistoryItem(item03.asData()))
        
        let item04 = PushAction(player: "Alice", pushedDice: [0,1,2], newDice: [0,1,2], correct: true)
        XCTAssertNil(HistoryItem.makeHistoryItem(item04.asData()))
        
        
        let item05 = InitialState(players: ["Alice": [0,1,2], "Bob": [0,1,2]])
        XCTAssertTrue(item05 == HistoryItem.makeHistoryItem(item05.asData()))
        
        let item06 = SpecialRulesInEffect(player: "Alice")
        XCTAssertTrue(item06 == HistoryItem.makeHistoryItem(item06.asData()))
        

        let item07 = BidAction(player: "Alice", count: 1, face: 2, pushedDice: [], newDice: [], correct: true)
        XCTAssertTrue(item07 == HistoryItem.makeHistoryItem(item07.asData()))
        
        let item08 = PassAction(player: "Alice", pushedDice: [], newDice: [], correct: true)
        XCTAssertTrue(item08 == HistoryItem.makeHistoryItem(item08.asData()))
        
        
        let item09 = ExactAction(player: "Alice", correct: true)
        XCTAssertTrue(item09 == HistoryItem.makeHistoryItem(item09.asData()))
        
        let item10 = ChallengeAction(player: "Alice", challengee: "Bob", challengeActionIndex: 0, correct: true)
        XCTAssertTrue(item10 == HistoryItem.makeHistoryItem(item10.asData()))
        
        
        let item11 = PlayerLostRound(player: "Alice")
        XCTAssertTrue(item11 == HistoryItem.makeHistoryItem(item11.asData()))
        
        let item12 = PlayerWon(player: "Alice")
        XCTAssertTrue(item12 == HistoryItem.makeHistoryItem(item12.asData()))
        
        let item13 = PlayerLost(player: "Alice")
        XCTAssertTrue(item13 == HistoryItem.makeHistoryItem(item13.asData()))
    }
    
    func testEquality()
    {
        let item = HistoryItem(type: .invalid)
        let item2 = HistoryItem(type: .invalid)
        
        XCTAssertTrue(item == item2)
        
        let item3 = HistoryItem(type: .action)
        
        XCTAssertFalse(item2 == item3)
    }
    
    func testSerialization()
    {
        Handlers.Error = { _ in }

        let item = HistoryItem(type: .action)
        let item_restore = HistoryItem(data: item.asData())
        
        XCTAssertTrue(item_restore != nil)
        XCTAssertTrue(item == item_restore!)
        
        XCTAssertNil(HistoryItem(data: .Int(0)))
        XCTAssertNil(HistoryItem(data: []))
        XCTAssertNil(HistoryItem(data: [.Int(-1)]))
        
        let typeInt = HistoryItem.HIType.playerWon.rawValue + 1
        XCTAssertNil(HistoryItem(data: [.UInt(typeInt)]))
    }
}
