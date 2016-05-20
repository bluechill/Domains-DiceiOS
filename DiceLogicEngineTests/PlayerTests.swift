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
    override func setUp()
    {
        super.setUp()
        
        Random.random = Random.newGenerator(0)
        
        Handlers.Error = { XCTFail($0) }
        Handlers.Warning = { XCTFail($0) }
    }
    
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
        
        XCTAssertNil(Player(name: "Test").lastBid)
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
    
    func testIsValidBid()
    {
        let engine = DiceLogicEngine(players: ["Alice","Bob"])
        
        guard let alice = engine.player("Alice") else { XCTFail(); return }
        guard let bob = engine.player("Bob")  else { XCTFail(); return }
        
        var warning = String()
        Handlers.Warning = { warning = $0 }
        
        XCTAssertTrue(alice.isValidBid(1, face: 2))
        XCTAssertTrue(warning == "No last bid, therefore valid")
        Handlers.Warning = { XCTFail($0) }
        
        engine.appendHistoryItem(BidAction(player: "Bob", count: 3, face: 3, pushedDice: [], newDice: [], correct: true))
        
        XCTAssertTrue(alice.isValidBid(4, face: 2))
        XCTAssertTrue(alice.isValidBid(3, face: 4))
        XCTAssertTrue(alice.isValidBid(3, face: 1))
        XCTAssertFalse(alice.isValidBid(2, face: 1))
        XCTAssertFalse(alice.isValidBid(3, face: 2))
        XCTAssertFalse(alice.isValidBid(3, face: 3))
        XCTAssertFalse(alice.isValidBid(2, face: 4))
        
        engine.appendHistoryItem(BidAction(player: "Bob", count: 2, face: 1, pushedDice: [], newDice: [], correct: true))
        
        XCTAssertTrue(alice.isValidBid(5, face: 2))
        XCTAssertTrue(alice.isValidBid(3, face: 1))
        XCTAssertFalse(alice.isValidBid(4, face: 2))
        XCTAssertFalse(alice.isValidBid(2, face: 1))
        
        engine.appendHistoryItem(BidAction(player: "Bob", count: 3, face: 3, pushedDice: [], newDice: [], correct: true))
        
        engine.appendHistoryItem(SpecialRulesInEffect(player: "Bob"))
        bob.dice.removeRange(0..<4)
        
        XCTAssertTrue(alice.isValidBid(4, face: 3))
        XCTAssertFalse(alice.isValidBid(4, face: 2))
        XCTAssertFalse(alice.isValidBid(3, face: 4))
        XCTAssertFalse(alice.isValidBid(3, face: 1))
        
        XCTAssertTrue(bob.isValidBid(4, face: 3))
        XCTAssertTrue(bob.isValidBid(3, face: 4))
        XCTAssertTrue(bob.isValidBid(4, face: 2))
        XCTAssertTrue(bob.isValidBid(4, face: 1))
        XCTAssertFalse(bob.isValidBid(3, face: 1))
        
        alice.engine = nil
        
        var error = String()
        Handlers.Error = { error = $0 }
    
        XCTAssertFalse(alice.isValidBid(1, face: 2))
        XCTAssertTrue(error == "Cannot bid with no engine")
        error = ""
        alice.engine = engine
        
        XCTAssertFalse(alice.isValidBid(0, face: 2))
        XCTAssertTrue(error == "Cannot bid zero dice")
        error = ""
        
        XCTAssertFalse(alice.isValidBid(1, face: 0))
        XCTAssertTrue(error == "Cannot bid invalid die face 0")
        error = ""
        
        XCTAssertFalse(alice.isValidBid(1, face: Die.sides+1))
        XCTAssertTrue(error == "Cannot bid invalid die face \(Die.sides+1)")
        error = ""
    }
    
    func testCanPushDice()
    {
        let engine = DiceLogicEngine(players: ["Alice","Bob"])
        
        guard let alice = engine.player("Alice") else { XCTFail(); return }
        
        // 3,2,4,5,3

        XCTAssertTrue(alice.canPushDice([3]))
        XCTAssertTrue(alice.canPushDice([3,2]))
        XCTAssertTrue(alice.canPushDice([3,2,4]))
        XCTAssertTrue(alice.canPushDice([3,2,4,5]))
        XCTAssertTrue(alice.canPushDice([2,4,5,3]))
        XCTAssertTrue(alice.canPushDice([3,2,5,3]))
        XCTAssertTrue(alice.canPushDice([3,5,2,4]))
        XCTAssertTrue(alice.canPushDice([2,5,3,3]))
        
        var error = String()
        Handlers.Error = { error = $0 }
        
        XCTAssertFalse(alice.canPushDice([1]))
        XCTAssertTrue(error == "Cannot push die you do not have 1")
        error = ""
        
        XCTAssertFalse(alice.canPushDice([6]))
        XCTAssertTrue(error == "Cannot push die you do not have 6")
        error = ""
        
        XCTAssertFalse(alice.canPushDice([3,2,4,5,3]))
        XCTAssertTrue(error == "Cannot push all your dice")
    }
    
    func testBid()
    {
        let engine = DiceLogicEngine(players: ["Alice", "Bob"])
        
        guard let alice = engine.player("Alice") else { XCTFail(); return }
        guard let bob = engine.player("Bob") else { XCTFail(); return }
        
        var error = String()
        var warning = String()
        
        Handlers.Error = {error = $0}
        Handlers.Warning = {warning = $0}
        
        alice.engine = nil
        alice.bid(1, face: 2)
        XCTAssertTrue(error == "Cannot bid with no engine")
        error = ""
        
        alice.engine = engine
        
        bob.bid(1, face: 2)
        XCTAssertTrue(error == "It is not your turn")
        error = ""
        
        alice.bid(0, face: 2)
        XCTAssertTrue(error == "Cannot bid zero dice")
        error = ""
        
        alice.bid(1, face: 2, pushDice: [0])
        XCTAssertTrue(warning == "No last bid, therefore valid")
        XCTAssertTrue(error == "Cannot push die you do not have 0")
        error = ""
        warning = ""
        
        alice.bid(1, face: 2, pushDice: [3,3])
        XCTAssertTrue(error.isEmpty)
        XCTAssertTrue(warning == "No last bid, therefore valid")
        warning = ""
        
        let correct = BidAction(player: "Alice",
                                count: 1,
                                face: 2,
                                pushedDice: [3,3],
                                newDice: [6,4,1],
                                correct: true)
        
        XCTAssertTrue(engine.currentRoundHistory.last == correct)
        XCTAssertTrue(engine.lastBid == correct)
    }
}