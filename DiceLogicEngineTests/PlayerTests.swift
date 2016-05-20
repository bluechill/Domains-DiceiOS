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
    
    func testHasPassedThisRound()
    {
        let engine = DiceLogicEngine(players: ["Alice", "Bob"])
        
        guard let alice = engine.player("Alice") else { XCTFail(); return }
 
        XCTAssertFalse(alice.hasPassedThisRound)
        
        engine.appendHistoryItem(PassAction(player: "Alice", pushedDice: [], newDice: [], correct: false))
        XCTAssertTrue(alice.hasPassedThisRound)
        
        alice.engine = nil
        XCTAssertFalse(alice.hasPassedThisRound)
        alice.engine = engine
    }
    
    func testCanPass()
    {
        let engine = DiceLogicEngine(players: ["Alice", "Bob"])
        
        guard let alice = engine.player("Alice") else { XCTFail(); return }
        
        var error = String()
        Handlers.Error = {error = $0}
        
        alice.dice.removeRange(0..<4)
        
        XCTAssertFalse(alice.canPass())
        XCTAssertTrue(error == "You cannot pass with only one die")
        alice.dice.append(Die(face: 3))
        
        XCTAssertTrue(alice.canPass())
        alice.pass()

        XCTAssertFalse(alice.canPass())
        XCTAssertTrue(error == "You cannot pass more than once per round")
        error = ""
    }
    
    func testPass()
    {
        let engine = DiceLogicEngine(players: ["Alice", "Bob"])
        
        guard let alice = engine.player("Alice") else { XCTFail(); return }
        guard let bob = engine.player("Bob") else { XCTFail(); return }
        
        var error = String()
        Handlers.Error = {error = $0}
        
        alice.engine = nil
        alice.pass()
        XCTAssertTrue(error == "Cannot pass with no engine")
        error = ""
        
        alice.engine = engine
        
        bob.pass()
        XCTAssertTrue(error == "It is not your turn")
        error = ""
        
        alice.dice.removeRange(0..<4)
        alice.pass()
        XCTAssertTrue(error == "You cannot pass with only one die")
        error = ""
        
        alice.dice.insertContentsOf([   Die(face: 3),
                                        Die(face: 2),
                                        Die(face: 4),
                                        Die(face: 5)], at: 0)
        
        alice.pass([0])
        XCTAssertTrue(error == "Cannot push die you do not have 0")
        error = ""
        
        alice.pass([3,3])
        XCTAssertTrue(error.isEmpty)
        
        let correct = PassAction(player: "Alice",
                                pushedDice: [3,3],
                                newDice: [6,4,1],
                                correct: false)
        
        XCTAssertTrue(engine.currentRoundHistory.last == correct)
        
        bob.dice.removeAll()
        bob.dice.appendContentsOf([Die(face: 3),Die(face: 3),Die(face: 3),Die(face: 3),Die(face: 3)])
        bob.pass()
        XCTAssertTrue(error.isEmpty)
        
        let correct2 = PassAction(player: "Bob",
                                 pushedDice: [],
                                 newDice: [3,3,3,3,3],
                                 correct: true)
        
        XCTAssertTrue(engine.currentRoundHistory.last == correct2)
    }
    
    func testHasExacted()
    {
        let engine = DiceLogicEngine(players: ["Alice", "Bob"])
        
        guard let alice = engine.player("Alice") else { XCTFail(); return }
        
        XCTAssertFalse(alice.hasExacted)
        
        engine.appendHistoryItem(ExactAction(player: "Alice", correct: true))
        XCTAssertTrue(alice.hasExacted)
        engine.createNewRound()
        engine.createNewRound()
        XCTAssertTrue(alice.hasExacted)
        
        alice.engine = nil
        XCTAssertFalse(alice.hasExacted)
    }
    
    func testCanExact()
    {
        let engine = DiceLogicEngine(players: ["Alice", "Bob"])
        
        guard let alice = engine.player("Alice") else { XCTFail(); return }

        var error = String()
        Handlers.Error = { error = $0 }
        
        XCTAssertFalse(alice.canExact())
        XCTAssertTrue(error == "Can only exact if there is a bid")
        error = ""
        
        alice.engine = nil
        XCTAssertFalse(alice.canExact())
        XCTAssertTrue(error == "Cannot exact with no engine")
        error = ""
        
        alice.engine = engine
        
        engine.appendHistoryItem(BidAction(player: "Bob", count: 1, face: 2, pushedDice: [], newDice: [], correct: true))
        
        XCTAssertTrue(alice.canExact())
        XCTAssertTrue(error.isEmpty)
        
        engine.appendHistoryItem(BidAction(player: "Alice", count: 1, face: 2, pushedDice: [], newDice: [], correct: true))
        
        XCTAssertFalse(alice.canExact())
        XCTAssertTrue(error == "Cannot exact yourself")
        error = ""
        
        engine.appendHistoryItem(ExactAction(player: "Alice", correct: true))
        
        XCTAssertFalse(alice.canExact())
        XCTAssertTrue(error == "Cannot exact twice in one game")
    }
    
    func testExact()
    {
        let engine = DiceLogicEngine(players: ["Alice", "Bob"])
        
        guard let alice = engine.player("Alice") else { XCTFail(); return }
        guard let bob = engine.player("Bob") else { XCTFail(); return }
        
        var error = String()
        Handlers.Error = { error = $0 }
        
        alice.exact()
        XCTAssertTrue(error == "Can only exact if there is a bid")
        error = ""
        
        bob.exact()
        XCTAssertTrue(error == "It is not your turn")
        error = ""
        
        alice.engine = nil
        alice.exact()
        XCTAssertTrue(error == "Cannot exact with no engine")
        error = ""
        
        alice.engine = engine
        
        engine.appendHistoryItem(BidAction(player: "Bob", count: 4, face: 3, pushedDice: [], newDice: [], correct: true))
        
        alice.exact()
        XCTAssertTrue(error.isEmpty)
        
        let action = ExactAction(player: "Alice", correct: true)
        
        XCTAssertTrue(engine.history[0].last == action)
        
        engine.appendHistoryItem(BidAction(player: "Alice", count: 1, face: 2, pushedDice: [], newDice: [], correct: true))
        engine.currentTurn = bob
        bob.exact()
        
        let action2 = ExactAction(player: "Bob", correct: false)
        
        guard engine.history.count == 3 else {
            XCTFail()
            return
        }
        
        guard engine.history[1].count == 4 else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(engine.history[1][2] == action2)
    }
    
    func testCanChallenge()
    {
        let engine = DiceLogicEngine(players: ["Alice","Bob","Eve","Mary"])
        
        guard let alice = engine.player("Alice") else { XCTFail(); return }
        
        var error = String()
        Handlers.Error = { error = $0 }
        
        alice.engine = nil
        XCTAssertFalse(alice.canChallenge("Mary"))
        XCTAssertTrue(error == "Cannot challenge with no engine")
        error = ""
        alice.engine = engine
        
        XCTAssertFalse(alice.canChallenge("Alice"))
        XCTAssertTrue(error == "Cannot challenge yourself")
        error = ""
        
        XCTAssertFalse(alice.canChallenge("Bob"))
        XCTAssertTrue(error == "Cannot challenge a player other than the last two")
        error = ""
        
        engine.appendHistoryItem(PassAction(player: "Mary", pushedDice: [], newDice: [], correct: true))
        XCTAssertTrue(alice.canChallenge("Mary"))
        
        engine.appendHistoryItem(HistoryAction(player: "Mary", correct: true))
        
        XCTAssertFalse(alice.canChallenge("Mary"))
        XCTAssertTrue(error == "Cannot challenge something other than a bid or pass")
        error = ""
        
        XCTAssertFalse(alice.canChallenge("Eve"))
        XCTAssertTrue(error == "Cannot challenge through anything but a pass")
        error = ""
        
        engine.appendHistoryItem(HistoryAction(player: "Eve", correct: true))
        engine.appendHistoryItem(PassAction(player: "Mary", pushedDice: [], newDice: [], correct: true))
        
        XCTAssertFalse(alice.canChallenge("Eve"))
        XCTAssertTrue(error == "Cannot challenge something other than a bid or pass")
        error = ""
        
        engine.appendHistoryItem(PassAction(player: "Eve", pushedDice: [], newDice: [], correct: true))
        engine.appendHistoryItem(PassAction(player: "Mary", pushedDice: [], newDice: [], correct: true))
        XCTAssertTrue(alice.canChallenge("Eve"))
    }
    
    func testChallenge()
    {
        let engine = DiceLogicEngine(players: ["Alice","Bob"])
        
        guard let alice = engine.player("Alice") else { XCTFail(); return }
        guard let bob = engine.player("Bob") else { XCTFail(); return }
        
        var error = String()
        Handlers.Error = { error = $0 }
        
        alice.engine = nil
        alice.challenge("Bob")
        XCTAssertTrue(error == "Cannot challenge with no engine")
        error = ""
        alice.engine = engine
        
        bob.challenge("Alice")
        XCTAssertTrue(error == "It is not your turn")
        error = ""
        
        alice.challenge("Bob")
        XCTAssertTrue(error == "Cannot challenge something other than a bid or pass")
        error = ""
        
        engine.appendHistoryItem(BidAction(player: "Bob", count: 1, face: 2, pushedDice: [], newDice: [], correct: true))
        
        alice.challenge("Bob")
        XCTAssertTrue(error.isEmpty)
        
        guard engine.history.count == 2 else {
            XCTFail()
            return
        }
        
        guard engine.history[0].count == 4 else {
            XCTFail()
            return
        }
        
        let action = ChallengeAction(player: "Alice", challengee: "Bob", challengeActionIndex: 1, correct: false)
        XCTAssertTrue(engine.history[0][2] == action)
        
        engine.appendHistoryItem(BidAction(player: "Bob", count: 1, face: 2, pushedDice: [], newDice: [], correct: false))
        
        alice.challenge("Bob")
        XCTAssertTrue(error.isEmpty)
        
        guard engine.history.count == 3 else {
            XCTFail()
            return
        }
        
        guard engine.history[1].count == 4 else {
            XCTFail()
            return
        }
        
        let action2 = ChallengeAction(player: "Alice", challengee: "Bob", challengeActionIndex: 1, correct: true)
        XCTAssertTrue(engine.history[1][2] == action2)
    }
}