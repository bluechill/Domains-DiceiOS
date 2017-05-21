//
//  SoarPlayerTests.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/21/17.
//  Copyright © 2017 Alex Turner. All rights reserved.
//

import XCTest
import DiceLogicEngine

@testable import SoarPlayer

class SoarTests: XCTestCase
{
    var engine = DiceLogicEngine(players: ["One", "Two"], start: false)

    override func setUp()
    {
        super.setUp()

        Random.random = Random.newGenerator(0)
        engine = DiceLogicEngine(players: ["One", "Two"], start: true)
    }

    override func tearDown()
    {
        super.tearDown()
    }

    func testSoarPlayer()
    {
        let player = SoarPlayer(1)
        let action = player?.performAction(engine.players.first, engine: engine, difficulty: 0)

        XCTAssertTrue(action?.type == .bidAction)
        let bidAction = action as! BidAction

        XCTAssertTrue(bidAction.count == 2)
        XCTAssertTrue(bidAction.face == 5)
    }

    func testSoarPlayer2()
    {
        let player = SoarPlayer(2)
        let action = player?.performAction(engine.players.first, engine: engine, difficulty: 0)

        XCTAssertTrue(action?.type == .bidAction)
        let bidAction = action as! BidAction

        XCTAssertTrue(bidAction.count == 2)
        XCTAssertTrue(bidAction.face == 4)
    }
}
