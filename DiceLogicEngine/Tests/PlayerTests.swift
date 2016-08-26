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
        bob.dice.removeSubrange(0..<4)
        
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
        
        // 6,2,5,3,6
        //
        // 6,2,5,3
        // 6,5,3,6
        // 6,2,3,6
        // 6,2,5,6
        // 2,5,3,6

        XCTAssertTrue(alice.canPushDice([6]))
        XCTAssertTrue(alice.canPushDice([6,2]))
        XCTAssertTrue(alice.canPushDice([6,2,5]))
        XCTAssertTrue(alice.canPushDice([6,2,5,3]))
        XCTAssertTrue(alice.canPushDice([6,5,3,6]))
        XCTAssertTrue(alice.canPushDice([6,2,3,6]))
        XCTAssertTrue(alice.canPushDice([6,2,5,6]))
        XCTAssertTrue(alice.canPushDice([2,5,3,6]))
        
        var error = String()
        Handlers.Error = { error = $0 }
        
        XCTAssertFalse(alice.canPushDice([1]))
        XCTAssertTrue(error == "Cannot push die you do not have 1")
        error = ""
        
        XCTAssertFalse(alice.canPushDice([4]))
        XCTAssertTrue(error == "Cannot push die you do not have 4")
        error = ""
        
        XCTAssertFalse(alice.canPushDice([6,2,5,3,6]))
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
        
        alice.bid(1, face: 2)
        XCTAssertTrue(error == "It is not your turn")
        error = ""
        
        bob.bid(0, face: 2)
        XCTAssertTrue(error == "Cannot bid zero dice")
        error = ""
        
        bob.bid(1, face: 2, pushDice: [0])
        XCTAssertTrue(warning == "No last bid, therefore valid")
        XCTAssertTrue(error == "Cannot push die you do not have 0")
        error = ""
        warning = ""
        
        bob.bid(1, face: 2, pushDice: [3,1])
        XCTAssertTrue(error.isEmpty)
        XCTAssertTrue(warning == "No last bid, therefore valid")
        warning = ""
        
        let correct = BidAction(player: "Bob",
                                count: 1,
                                face: 2,
                                pushedDice: [3,1],
                                newDice: [2,4,5],
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
        
        guard let bob = engine.player("Bob") else { XCTFail(); return }
        
        var error = String()
        Handlers.Error = {error = $0}
        
        bob.dice.removeSubrange(0..<4)
        
        XCTAssertFalse(bob.canPass())
        XCTAssertTrue(error == "You cannot pass with only one die")
        bob.dice.append(Die(face: 3))
        
        XCTAssertTrue(bob.canPass())
        bob.pass()

        XCTAssertFalse(bob.canPass())
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
        
        alice.pass()
        XCTAssertTrue(error == "It is not your turn")
        error = ""
        
        bob.dice.removeSubrange(0..<4)
        bob.pass()
        XCTAssertTrue(error == "You cannot pass with only one die")
        error = ""
        
        bob.dice.insert(contentsOf: [   Die(face: 3),
                                        Die(face: 2),
                                        Die(face: 4),
                                        Die(face: 5)], at: 0)
        
        bob.pass([0])
        XCTAssertTrue(error == "Cannot push die you do not have 0")
        error = ""
        
        bob.pass([3,1])
        XCTAssertTrue(error.isEmpty)
        
        let correct = PassAction(player: "Bob",
                                pushedDice: [3,1],
                                newDice: [2,4,5],
                                correct: false)
        
        XCTAssertTrue(engine.currentRoundHistory.last == correct)
        
        alice.dice.removeAll()
        alice.dice.append(contentsOf: [Die(face: 3),Die(face: 3),Die(face: 3),Die(face: 3),Die(face: 3)])
        alice.pass()
        XCTAssertTrue(error.isEmpty)
        
        let correct2 = PassAction(player: "Alice",
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
        
        bob.exact()
        XCTAssertTrue(error == "Can only exact if there is a bid")
        error = ""
        
        alice.exact()
        XCTAssertTrue(error == "It is not your turn")
        error = ""
        
        alice.engine = nil
        alice.exact()
        XCTAssertTrue(error == "Cannot exact with no engine")
        error = ""
        
        alice.engine = engine
        
        engine.appendHistoryItem(BidAction(player: "Alice", count: 3, face: 3, pushedDice: [], newDice: [], correct: true))
        
        bob.exact()
        XCTAssertTrue(error.isEmpty)
        
        let action = ExactAction(player: "Bob", correct: true)
        
        XCTAssertTrue(engine.history[0].last == action)
        
        engine.appendHistoryItem(BidAction(player: "Bob", count: 1, face: 2, pushedDice: [], newDice: [], correct: true))
        engine.currentTurn = alice
        alice.exact()
        
        let action2 = ExactAction(player: "Alice", correct: false)
        
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
        
        guard let eve = engine.player("Eve") else { XCTFail(); return }
        
        var error = String()
        Handlers.Error = { error = $0 }
        
        eve.engine = nil
        XCTAssertFalse(eve.canChallenge("Mary"))
        XCTAssertTrue(error == "Cannot challenge with no engine")
        error = ""
        eve.engine = engine
        
        XCTAssertFalse(eve.canChallenge("Eve"))
        XCTAssertTrue(error == "Cannot challenge yourself")
        error = ""
        
        XCTAssertFalse(eve.canChallenge("Alice"))
        XCTAssertTrue(error == "Cannot challenge a player other than the last two")
        error = ""
        
        engine.appendHistoryItem(PassAction(player: "Bob", pushedDice: [], newDice: [], correct: true))
        XCTAssertTrue(eve.canChallenge("Bob"))
        
        engine.appendHistoryItem(HistoryAction(player: "Bob", correct: true))
        
        XCTAssertFalse(eve.canChallenge("Bob"))
        XCTAssertTrue(error == "Cannot challenge something other than a bid or pass")
        error = ""
        
        XCTAssertFalse(eve.canChallenge("Mary"))
        XCTAssertTrue(error == "Cannot challenge through anything but a pass")
        error = ""
        
        engine.appendHistoryItem(HistoryAction(player: "Mary", correct: true))
        engine.appendHistoryItem(PassAction(player: "Bob", pushedDice: [], newDice: [], correct: true))
        
        XCTAssertFalse(eve.canChallenge("Mary"))
        XCTAssertTrue(error == "Cannot challenge something other than a bid or pass")
        error = ""
        
        engine.appendHistoryItem(PassAction(player: "Mary", pushedDice: [], newDice: [], correct: true))
        engine.appendHistoryItem(PassAction(player: "Bob", pushedDice: [], newDice: [], correct: true))
        XCTAssertTrue(eve.canChallenge("Mary"))
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
        
        alice.challenge("Bob")
        XCTAssertTrue(error == "It is not your turn")
        error = ""
        
        bob.challenge("Alice")
        XCTAssertTrue(error == "Cannot challenge something other than a bid or pass")
        error = ""
        
        engine.appendHistoryItem(BidAction(player: "Alice", count: 1, face: 2, pushedDice: [], newDice: [], correct: true))
        
        bob.challenge("Alice")
        XCTAssertTrue(error.isEmpty)
        
        guard engine.history.count == 2 else {
            XCTFail()
            return
        }
        
        guard engine.history[0].count == 4 else {
            XCTFail()
            return
        }
        
        let action = ChallengeAction(player: "Bob", challengee: "Alice", challengeActionIndex: 1, correct: false)
        XCTAssertTrue(engine.history[0][2] == action)
        
        engine.appendHistoryItem(BidAction(player: "Alice", count: 1, face: 2, pushedDice: [], newDice: [], correct: false))
        
        bob.challenge("Alice")
        XCTAssertTrue(error.isEmpty)
        
        guard engine.history.count == 3 else {
            XCTFail()
            return
        }
        
        guard engine.history[1].count == 4 else {
            XCTFail()
            return
        }
        
        let action2 = ChallengeAction(player: "Bob", challengee: "Alice", challengeActionIndex: 1, correct: true)
        XCTAssertTrue(engine.history[1][2] == action2)
    }
}
