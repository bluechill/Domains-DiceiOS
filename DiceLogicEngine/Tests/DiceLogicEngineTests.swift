//
//  DiceLogicEngineTests.swift
//  DiceLogicEngineTests
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import XCTest
import MessagePack
@testable import DiceLogicEngine

class DiceLogicEngineTests: XCTestCase
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
        let engine = DiceLogicEngine(players: ["Alice", "Bob"])

        XCTAssertTrue(engine.players.count == 2)
        XCTAssertTrue(engine.players[0].name == "Bob")
        XCTAssertTrue(engine.players[1].name == "Alice")
        XCTAssertTrue(engine.history.count == 1)
        XCTAssertTrue(engine.history[0].count == 1)
        XCTAssertNotNil(engine.history[0][0] as? InitialState)

        guard let state = engine.history[0][0] as? InitialState else {
            XCTFail()
            return
        }

        let aliceDice = engine.player("Alice")!.dice.map{ $0.face }
        let bobDice = engine.player("Bob")!.dice.map{ $0.face }

        XCTAssertTrue(state.players == ["Alice": aliceDice, "Bob": bobDice])
        XCTAssertTrue(state.players == ["Alice": [6, 2, 5, 3, 6], "Bob": [2, 4, 5, 3, 1]])

        XCTAssertTrue(engine.currentTurn?.name == "Bob")
    }

    func testCreateNewRound()
    {
        let engine = DiceLogicEngine(players: ["Alice", "Bob"])

        var error = String()
        Handlers.Error = { (string) in error = string }

        XCTAssertTrue(engine.history.count == 1)
        engine.history[0].append(PlayerLostRound(player: "Eve"))

        engine.createNewRound()
        XCTAssertTrue(error == "Invalid player who lost the round.")
    }

    func testPlayerGetter()
    {
        let engine = DiceLogicEngine(players: ["Alice", "Alice"])

        var error = String()
        Handlers.Error = { (string) in error = string }

        XCTAssertNil(engine.player("Eve"))
        XCTAssertTrue(error == "No player with name 'Eve'")
        error = ""

        XCTAssertNil(engine.player("Alice"))
        XCTAssertTrue(error == "More than one player with the same name 'Alice'")
    }

    func testLastBid()
    {
        let engine = DiceLogicEngine(players: ["Alice", "Bob"])

        XCTAssertNil(engine.lastBid)

        XCTAssertTrue(engine.history.count == 1)
        engine.history[0].append(BidAction(player: "Alice", count: 1, face: 2, pushedDice: [1, 2], newDice: [3, 4, 5], correct: true))

        XCTAssertNotNil(engine.lastBid)

        XCTAssertTrue(engine.lastBid?.player == "Alice")

        engine.history[0].append(BidAction(player: "Bob", count: 1, face: 2, pushedDice: [1, 2], newDice: [3, 4, 5], correct: true))

        XCTAssertTrue(engine.lastBid?.player == "Bob")
    }

    func testCurrentRoundHistory()
    {
        let engine = DiceLogicEngine(players: ["Alice", "Bob"])

        XCTAssertTrue(engine.currentRoundHistory.count == 1)

        var error = String()
        Handlers.Error = { (string) in error = string }

        engine.history.removeAll()

        XCTAssertTrue(engine.currentRoundHistory.count == 0)
        XCTAssertTrue(error == "No current round, returning empty array")
    }

    func testSpecialRules()
    {
        let engine = DiceLogicEngine(players: ["Alice", "Bob", "Eve"])

        XCTAssertFalse(engine.isSpecialRules)
        XCTAssertTrue(engine.history.count == 1)

        engine.history[0].append(PlayerLostRound(player: "Bob"))
        engine.players[0].dice = [Die(face: 1)]

        engine.createNewRound()

        XCTAssertTrue(engine.history.count == 2)
        XCTAssertTrue(engine.history[1].count == 2)
        XCTAssertNotNil(engine.history[1][1] as? SpecialRulesInEffect)

        guard let special = engine.history[1][1] as? SpecialRulesInEffect else {
            XCTFail()
            return
        }

        XCTAssertTrue(special.player == "Bob")
        XCTAssertTrue(engine.isSpecialRules)

        let engine2 = DiceLogicEngine(players: ["Alice", "Bob", "Eve"])
        engine2.history[0].append(PlayerLostRound(player: "Bob"))
        engine2.players[2].dice = [Die(face: 1)]

        engine2.createNewRound()
        XCTAssertTrue(engine2.isSpecialRules)
        engine2.history[1].append(PlayerLostRound(player: "Bob"))
        engine2.players[2].dice = [Die(face: 1)]

        engine2.createNewRound()

        XCTAssertFalse(engine2.isSpecialRules)

        let engine3 = DiceLogicEngine(players: ["Alice", "Bob", "Eve"])
        engine3.playerLosesRound("Alice")
        XCTAssertFalse(engine3.isSpecialRules)

        engine3.playerLosesRound("Alice")
        XCTAssertFalse(engine3.isSpecialRules)

        engine3.playerLosesRound("Alice")
        XCTAssertFalse(engine3.isSpecialRules)

        engine3.playerLosesRound("Alice")
        XCTAssertTrue(engine3.isSpecialRules)

        engine3.player("Alice")!.dice.append(Die(face: 1))
        engine3.createNewRound()

        engine3.playerLosesRound("Alice")
        XCTAssertFalse(engine3.isSpecialRules)

        engine3.playerLosesRound("Alice")
        XCTAssertFalse(engine3.isSpecialRules)
    }

    func testFunctionallySpecialRules()
    {
        Handlers.Warning = {_ in }

        let engine = DiceLogicEngine(players: ["Alice", "Bob", "Eve"])

        XCTAssertFalse(engine.isSpecialRules)
        XCTAssertTrue(engine.history.count == 1)

        let alice = engine.player("Alice")!
        let bob = engine.player("Bob")!
        let eve = engine.player("Eve")!

        bob.bid(1, face: 2)
        alice.challenge("Bob")

        XCTAssertFalse(engine.isSpecialRules)

        alice.bid(40, face: 2)
        eve.challenge("Alice")

        XCTAssertFalse(engine.isSpecialRules)

        alice.bid(40, face: 2)
        eve.challenge("Alice")

        XCTAssertFalse(engine.isSpecialRules)

        alice.bid(40, face: 2)
        eve.challenge("Alice")

        XCTAssertTrue(engine.isSpecialRules)

        alice.bid(40, face: 2)
        eve.challenge("Alice")

        XCTAssertFalse(engine.isSpecialRules)

        eve.bid(40, face: 2)
        bob.challenge("Eve")

        XCTAssertFalse(engine.isSpecialRules)

        eve.bid(40, face: 2)
        bob.challenge("Eve")

        XCTAssertFalse(engine.isSpecialRules)

        eve.bid(40, face: 2)
        bob.challenge("Eve")

        XCTAssertFalse(engine.isSpecialRules)

        eve.bid(40, face: 2)
        bob.challenge("Eve")

        XCTAssertFalse(engine.isSpecialRules)

        eve.bid(40, face: 2)
        bob.challenge("Eve")

        XCTAssertFalse(engine.isSpecialRules)

        Handlers.Warning = { XCTFail($0) }
    }

    func testEquality()
    {
        let engine = DiceLogicEngine(players: ["Alice", "Bob"])

        let engine2 = DiceLogicEngine(players: ["Alice", "Bob"])
        engine2.history.removeAll()

        let engine3 = DiceLogicEngine(players: ["Alice", "Bob"])
        guard engine3.history.count == 1 else {
            XCTFail()
            return
        }
        engine3.history[0].append(HistoryItem(type: .invalid))

        let engine4 = DiceLogicEngine(players: ["Alice", "Bob"])
        guard engine4.history.count == 1 else {
            XCTFail()
            return
        }
        engine4.history[0].removeAll()
        engine4.history[0].append(HistoryItem(type: .invalid))

        let engine5 = DiceLogicEngine(players: ["Alice", "Bob"])
        engine5.history.removeAll()
        engine5.history.append(contentsOf: engine.history)
        engine5.players.removeAll()
        engine5.players.append(contentsOf: engine.players)

        XCTAssertFalse(engine == engine2)
        XCTAssertFalse(engine == engine3)
        XCTAssertFalse(engine == engine4)

        XCTAssertTrue(engine == engine5)

        XCTAssertTrue([[HistoryItem(type: .invalid)]] == [[HistoryItem(type: .invalid)]])
        XCTAssertFalse([[HistoryItem(type: .invalid)]] == [[HistoryItem(type: .invalid)], [HistoryItem(type: .invalid)]])
        XCTAssertFalse([[HistoryItem(type: .invalid)]] == [[HistoryItem(type: .invalid), HistoryItem(type: .invalid)]])
        XCTAssertFalse([[HistoryItem(type: .invalid)]] == [[HistoryItem(type: .bidAction)]])
    }

    func testSerialization()
    {
        let engine = DiceLogicEngine(players: ["Alice", "Bob"])

        engine.players[0].userData["AI"] = true
        engine.players[1].userData["GCID"] = "-1"

        let restored = DiceLogicEngine(data: engine.asData())

        XCTAssertTrue(engine == restored)

        var error = String()
        Handlers.Error = { error = $0 }

        XCTAssertNil(DiceLogicEngine(data: .int(0)))
        XCTAssertTrue(error == "DiceLogicEngine data is not an array")
        error = ""

        XCTAssertNil(DiceLogicEngine(data: [.int(0)]))
        XCTAssertTrue(error == "Invalid DiceLogicEngine data array")
        error = ""

        XCTAssertNil(DiceLogicEngine(data: [.int(0), .int(0), .int(0), .int(0)]))
        XCTAssertTrue(error == "No players array in DiceLogicEngine data")
        error = ""

        XCTAssertNil(DiceLogicEngine(data: [[.int(0)], .int(0), .int(0), .int(0)]))
        XCTAssertTrue(error == "No players userData in DiceLogicEngine data")
        error = ""

        XCTAssertNil(DiceLogicEngine(data: [[.int(0)], [.int(0)], .int(0), .int(0)]))
        XCTAssertTrue(error == "No currentTurn string in DiceLogicEngine data")
        error = ""

        XCTAssertNil(DiceLogicEngine(data: [[.int(0)], [.int(0)], .string(""), .int(0)]))
        XCTAssertTrue(error == "No history array in DiceLogicEngine data")
        error = ""

        XCTAssertNil(DiceLogicEngine(data: [[.int(0)], [.int(0)], .string(""), [.int(0)]]))
        XCTAssertTrue(error == "DiceLogicEngine sub-array data is not an array")
        error = ""

        XCTAssertNil(DiceLogicEngine(data: [[.int(0)], [.int(0)], .string(""), [[]]]))
        XCTAssertTrue(error == "Empty DiceLogicEngine sub-array data")
        error = ""

        XCTAssertNil(DiceLogicEngine(data: [
            [],
            [[.int(0)]]
        ]))
        error = ""

        XCTAssertNil(DiceLogicEngine(data: [
            [.int(0)],
            [.int(0)],
            .string(""),
            [[ExactAction(player: "Alice", correct: true).asData()]]
        ]))
        XCTAssertTrue(error == "Player in players array is not a player name")
        error = ""

        XCTAssertNil(DiceLogicEngine(data: [[.string("Alice")], [[:], [:]], .string(""), []]))
        XCTAssertTrue(error == "Player User Data and Players Array are not the same size!")
        error = ""

        XCTAssertNil(DiceLogicEngine(data: [
            [.string("Alice")],
            [.int(0)],
            .string(""),
            []]))
        XCTAssertTrue(error == "Data in player userData array is not a dictionary of data")
        error = ""

        XCTAssertNil(DiceLogicEngine(data: [
            [.string("Alice")],
            [[.int(0):""]],
            .string(""),
            []]))
        XCTAssertTrue(error == "Key is not a string!")
        error = ""

        XCTAssertNil(DiceLogicEngine(data: [
            [.string("Alice")],
            [["":""]],
            .string(""),
            []]))
        XCTAssertTrue(error == "Unknown key found in user data.  Are you sure this data is for this version of Liar's Dice?")
        error = ""

        XCTAssertNil(DiceLogicEngine(data: [
            [.string("Alice")],
            [["AI":""]],
            .string(""),
            []]))
        XCTAssertTrue(error == "AI Value is not a bool!")
        error = ""

        XCTAssertNil(DiceLogicEngine(data: [
            [.string("Alice")],
            [["GCID":.int(0)]],
            .string(""),
            []]))
        XCTAssertTrue(error == "GCID Key is not a string!")
        error = ""

        XCTAssertNil(DiceLogicEngine(data: [
            [.string("Alice")],
            [[:]],
            .string(""),
            [[ExactAction(player: "Alice", correct: true).asData()]]
            ]))
        XCTAssertTrue(error == "Cannot find player whose turn it is")
        error = ""

        XCTAssertNil(DiceLogicEngine(data: [
            [.string("Alice")],
            [[:]],
            .string(""),
            [[HistoryItem(type: .invalid).asData()]]
            ]))
        XCTAssertTrue(error == "Non-Standalone history item")
        error = ""

        XCTAssertNotNil(DiceLogicEngine(data: [
            [.string("Alice")],
            [[:]],
            .string("Alice"),
            [[InitialState(players: ["Bob": [1, 2]]).asData()]]
            ]))
        XCTAssertTrue(error == "Corrupted Player Data for player Alice")
    }

    func testCurrentPlayerDiceExtractor()
    {
        let engine = DiceLogicEngine(players: ["Alice", "Bob"])

        guard (engine.history.last != nil) else {
            XCTFail()
            return
        }

        engine.history[0].removeAll()

        var error = String()
        Handlers.Error = { error = $0 }

        XCTAssertTrue(engine.currentPlayerDiceCalculatedViaHistory("Alice").isEmpty)
        XCTAssertTrue(error == "No history to extract player dice from")

        engine.history[0].append(HistoryItem(type: .invalid))
        XCTAssertTrue(engine.currentPlayerDiceCalculatedViaHistory("Alice").isEmpty)
        XCTAssertTrue(error == "Invalid formatted history")

        engine.history[0].removeAll()
        engine.history[0].append(InitialState(players: ["Alice": [6, 6, 6, 6, 6]]))
        engine.history[0].append(PushAction(player: "Alice", pushedDice: [4, 4], newDice: [3, 3,3], correct: true))
        engine.history[0].append(PushAction(player: "Alice", pushedDice: [2, 2], newDice: [1, 2,5], correct: true))
        engine.history[0].append(PushAction(player: "Bob", pushedDice: [4, 4], newDice: [3, 3, 3], correct: true))
        engine.history[0].append(HistoryItem(type: .invalid))

        XCTAssertFalse(engine.currentPlayerDiceCalculatedViaHistory("Alice").isEmpty)

        let dice = engine.currentPlayerDiceCalculatedViaHistory("Alice")
        XCTAssertTrue(dice == [ Die(face: 2, pushed: true),
                                Die(face: 2, pushed: true),
                                Die(face: 1, pushed: false),
                                Die(face: 2, pushed: false),
                                Die(face: 5, pushed: false)
        ])
    }

    func testPlayerLosesRound()
    {
        let engine = DiceLogicEngine(players: ["Alice", "Bob"])

        var error = String()
        Handlers.Error = { error = $0 }

        XCTAssertTrue(engine.player("Alice")?.dice.count == 5)

        engine.playerLosesRound("Alice")
        XCTAssertTrue(error.isEmpty, error)

        XCTAssertTrue(engine.player("Alice")?.dice.count == 4)

        guard engine.history.count == 2 else {
            XCTFail()
            return
        }

        guard engine.history[0].count == 2 else {
            XCTFail()
            return
        }

        XCTAssertTrue(engine.history[0][1].type == .playerLostRound)

        guard let lostRound = (engine.history[0][1] as? PlayerLostRound) else {
            XCTFail()
            return
        }

        XCTAssertTrue(lostRound.player == "Alice")

        engine.playerLosesRound("Alice")
        XCTAssertTrue(error.isEmpty, error)
        XCTAssertNil(engine.winner)

        engine.playerLosesRound("Alice")
        XCTAssertTrue(error.isEmpty, error)

        engine.playerLosesRound("Alice")
        XCTAssertTrue(error.isEmpty, error)

        engine.playerLosesRound("Alice")
        XCTAssertTrue(error.isEmpty, error)

        XCTAssertTrue(engine.currentRoundHistory.count == 4)

        let playerLost = engine.currentRoundHistory[2] as? PlayerLost
        let playerWon = engine.currentRoundHistory[3] as? PlayerWon

        XCTAssertNotNil(playerLost)
        XCTAssertNotNil(playerWon)

        XCTAssertTrue(playerLost?.player == "Alice")
        XCTAssertTrue(playerWon?.player == "Bob")

        XCTAssertNotNil(engine.winner)
        XCTAssertTrue(engine.winner?.name == "Bob")

        engine.playerLosesRound("Bob")
        XCTAssertTrue(error == "Cannot lose round when the game is over")
        error = ""

        engine.playerLosesRound("Alice")
        XCTAssertTrue(error == "Cannot lose round when the game is over")
        error = ""

        let engine2 = DiceLogicEngine(players: ["Alice", "Bob", "Eve"])
        engine2.player("Alice")?.dice.removeAll()

        engine2.playerLosesRound("Alice")
        XCTAssertTrue(error == "Player cannot lose the round when they already have zero dice.")
        error = ""

        engine2.playerLosesRound("John")
        XCTAssertTrue(error == "Invalid player lost the round")
        error = ""

        let engine3 = DiceLogicEngine(players: ["Alice", "Bob", "Eve"])
        engine3.player("Alice")?.dice.removeSubrange(0..<4)
        engine3.playerLosesRound("Alice")
        XCTAssertTrue(error.isEmpty)
    }

    func testCountDice()
    {
        let engine = DiceLogicEngine(players: ["Alice", "Bob"])

        XCTAssertTrue(engine.countDice(1) == 1)
        XCTAssertTrue(engine.countDice(2) == 3)
        XCTAssertTrue(engine.countDice(3) == 3)
        XCTAssertTrue(engine.countDice(4) == 2)
        XCTAssertTrue(engine.countDice(5) == 3)
        XCTAssertTrue(engine.countDice(6) == 3)

        let total = engine.countDice(1) +
            engine.countDice(2) +
            engine.countDice(3) +
            engine.countDice(4) +
            engine.countDice(5) +
            engine.countDice(6)

        XCTAssertTrue(total <= 60)
        XCTAssertTrue(total >= 10)

        engine.appendHistoryItem(SpecialRulesInEffect(player: "Alice"))

        XCTAssertTrue(engine.countDice(1) == 1)
        XCTAssertTrue(engine.countDice(2) == 2)
        XCTAssertTrue(engine.countDice(3) == 2)
        XCTAssertTrue(engine.countDice(4) == 1)
        XCTAssertTrue(engine.countDice(5) == 2)
        XCTAssertTrue(engine.countDice(6) == 2)

        let specialRulesTotal = engine.countDice(1) +
            engine.countDice(2) +
            engine.countDice(3) +
            engine.countDice(4) +
            engine.countDice(5) +
            engine.countDice(6)

        XCTAssertTrue(specialRulesTotal == 10)
    }
}
