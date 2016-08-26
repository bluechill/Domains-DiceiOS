//
//  GameTest.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/20/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import XCTest
import MessagePack
@testable import DiceLogicEngine

class GameTest: XCTestCase
{
    var catchErrors: Bool = true
    var error: Bool = false

    override func setUp()
    {
        super.setUp()

        Random.random = Random.newGenerator(0)
        Handlers.Error = {
            if self.catchErrors
            {
                XCTFail($0)
                self.error = true
            }
        }
        Handlers.Warning = {
            if (self.catchErrors && $0 != "No last bid, therefore valid")
            {
                XCTFail($0)
                self.error = true
            }
        }
    }

    func test2Players()
    {
        let engine = DiceLogicEngine(players: ["Alice","Bob"])

        guard let alice = engine.player("Alice") else { XCTFail(); return }
        guard let bob = engine.player("Bob") else { XCTFail(); return }

        for i in (3...10).reversed()
        {
            engine.printState()

            for j in 1...i
            {
                engine.currentTurn?.bid(UInt(j), face: 2)
            }

            if let currentTurn = engine.currentTurn, currentTurn.dice.count > 1
            {
                engine.currentTurn?.pass()
            }

            if let currentTurn = engine.currentTurn, currentTurn.dice.count > 1
            {
                engine.currentTurn?.pass()
            }

            var index = engine.players.index(of: engine.currentTurn!)!

            index = (index == 1 ? 0 : 1)

            engine.currentTurn?.challenge(engine.players[index].name)
        }

        engine.printState()

        bob.bid(1, face: 4)
        alice.exact()
        engine.printState()

        alice.bid(2, face: 2)
        bob.exact()
        engine.printState()

        bob.bid(1, face: 2)
        alice.bid(2, face: 2)
        bob.bid(3, face: 2)
        alice.bid(4, face: 2)
        bob.pass()
        alice.pass()
        bob.challenge("Alice")
        engine.printState()

        alice.bid(1, face: 2)
        bob.bid(2, face: 2)
        alice.bid(3, face: 2)
        bob.pass()
        alice.challenge("Bob")
        engine.printState()

        bob.bid(1, face: 2)
        alice.bid(2, face: 2)
        bob.challenge("Alice")
        engine.printState()

        XCTAssertTrue(engine.winner == bob)
    }

    func doAction(_ player: Player, diceCount: UInt, lastBid: BidAction?, lastAction: HistoryAction?)
    {
        guard let lastBid = lastBid else {
            player.bid(1, face: 2)
            return
        }

        guard let lastAction = lastAction else {
            player.bid(1, face: 2)
            return
        }

        let nextCount = lastBid.count+1

        self.catchErrors = false

        if player.dice.count < 5 && player.canExact() && lastBid.correct
        {
            self.catchErrors = true
            player.exact()
        }
        else if nextCount < diceCount
        {
            self.catchErrors = true
            player.bid(nextCount, face: 2)
        }
        else if player.canPass()
        {
            self.catchErrors = true
            player.pass()
        }
        else
        {
            self.catchErrors = true
            player.challenge(lastAction.player)
        }
    }

    func test3Players()
    {
        let engine = DiceLogicEngine(players: (1...3).map({String($0)}))

        while engine.winner == nil
        {
            var count: UInt = 0

            for player in engine.players
            {
                count += UInt(player.dice.count)
            }

            doAction(engine.currentTurn!, diceCount: count, lastBid: engine.lastBid, lastAction: engine.lastAction)

            if error
            {
                return
            }
        }
    }

    func test4Players()
    {
        let engine = DiceLogicEngine(players: (1...4).map({String($0)}))

        while engine.winner == nil
        {
            var count: UInt = 0

            for player in engine.players
            {
                count += UInt(player.dice.count)
            }

            doAction(engine.currentTurn!, diceCount: count, lastBid: engine.lastBid, lastAction: engine.lastAction)

            if error
            {
                return
            }
        }
    }

    func test5Players()
    {
        let engine = DiceLogicEngine(players: (1...5).map({String($0)}))

        while engine.winner == nil
        {
            var count: UInt = 0

            for player in engine.players
            {
                count += UInt(player.dice.count)
            }

            doAction(engine.currentTurn!, diceCount: count, lastBid: engine.lastBid, lastAction: engine.lastAction)

            if error
            {
                return
            }
        }
    }

    func test6Players()
    {
        let engine = DiceLogicEngine(players: (1...6).map({String($0)}))

        while engine.winner == nil
        {
            var count: UInt = 0

            for player in engine.players
            {
                count += UInt(player.dice.count)
            }

            doAction(engine.currentTurn!, diceCount: count, lastBid: engine.lastBid, lastAction: engine.lastAction)

            if error
            {
                return
            }
        }
    }

    func test7Players()
    {
        let engine = DiceLogicEngine(players: (1...7).map({String($0)}))

        while engine.winner == nil
        {
            var count: UInt = 0

            for player in engine.players
            {
                count += UInt(player.dice.count)
            }

            doAction(engine.currentTurn!, diceCount: count, lastBid: engine.lastBid, lastAction: engine.lastAction)

            if error
            {
                return
            }
        }
    }

    func packAndCheckEngine(_ engine: DiceLogicEngine) -> Bool
    {
        let data = engine.asData()

        print("Size: \(Double(data.count) / 1024.0) kb")

        var bytesUnpacked: MessagePackValue

        do
        {
            bytesUnpacked = try unpack(data)
        }
        catch
        {
            XCTFail()
            return false
        }

        guard let engine2 = DiceLogicEngine(data: bytesUnpacked) else {
            XCTFail()
            return false
        }

        XCTAssertTrue(engine == engine2)
        return true
    }

    func test8Players()
    {
        measure({
            let engine = DiceLogicEngine(players: (1...8).map({String($0)}))

            while engine.winner == nil
            {
                var count: UInt = 0

                for player in engine.players
                {
                    count += UInt(player.dice.count)
                }

                self.doAction(engine.currentTurn!, diceCount: count, lastBid: engine.lastBid, lastAction: engine.lastAction)

                if self.error
                {
                    return
                }
            }

            guard self.packAndCheckEngine(engine) else {
                XCTFail()
                return
            }
        })
    }

    // Very Time Consuming on my mbp, disabled
//    func test16Players()
//    {
//        measureBlock({
//            let engine = DiceLogicEngine(players: (1...16).map({String($0)}))
//
//            while engine.winner == nil
//            {
//                var count: UInt = 0
//
//                for player in engine.players
//                {
//                    count += UInt(player.dice.count)
//                }
//
//                self.doAction(engine.currentTurn!, diceCount: count, lastBid: engine.lastBid, lastAction: engine.lastAction)
//
//                if self.error
//                {
//                    return
//                }
//            }
//
//            guard self.packAndCheckEngine(engine) else {
//                XCTFail()
//                return
//            }
//        })
//    }
}
