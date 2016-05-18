//
//  PlayerTests.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/18/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import XCTest
@testable import DiceLogicEngine

class PlayerTests: XCTestCase
{
    func testInitialization()
    {
        let player = Player(name: "Alice", dice: [  Die(face: 1),
                                                    Die(face: 2),
                                                    Die(face: 3),
                                                    Die(face: 4),
                                                    Die(face: 5)
        ])
        
        XCTAssertTrue(player.name == "Alice")
        XCTAssertTrue(player.dice.count == 5)
        XCTAssertTrue(player.dice[0].face == 1)
        XCTAssertTrue(player.dice[1].face == 2)
        XCTAssertTrue(player.dice[2].face == 3)
        XCTAssertTrue(player.dice[3].face == 4)
        XCTAssertTrue(player.dice[4].face == 5)
    }
    
    func testLastBid()
    {
        let engine = DiceLogicEngine(players: ["Alice", "Bob"])
        
        guard engine.history.count == 1 else {
            XCTFail()
            return
        }
        
        guard engine.player("Alice")?.lastBid == nil else {
            XCTFail()
            return
        }
        
        engine.history[0].append(BidAction(player: "Bob", count: 1, face: 2, pushedDice: [], newDice: [], correct: true))
        engine.history[0].append(BidAction(player: "Alice", count: 2, face: 2, pushedDice: [], newDice: [], correct: true))
        engine.history[0].append(BidAction(player: "Bob", count: 3, face: 2, pushedDice: [], newDice: [], correct: true))
        
        guard let bid = engine.player("Alice")?.lastBid else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(bid.player == "Alice")
        XCTAssertTrue(bid.face == 2)
        XCTAssertTrue(bid.count == 2)
    }
    
    func testEquality()
    {
        let engine = DiceLogicEngine(players: ["Alice", "Bob"])
        
        guard let alice = engine.player("Alice") else {
            XCTFail()
            return
        }
        
        guard let bob = engine.player("Bob") else {
            XCTFail()
            return
        }
        
        XCTAssertFalse(alice == bob)
        
        let alice2 = Player(name: "Alice", dice: [], engine: engine)
        XCTAssertFalse(alice == alice2)
        
        let alice3 = Player(name: "Alice", dice: alice.dice, engine: engine)
        XCTAssertTrue(alice == alice3)
    }
}