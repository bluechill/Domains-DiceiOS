//
//  DieTests.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import XCTest
import MessagePack

@testable import DiceLogicEngine

class DieTests: XCTestCase
{
    override func setUp()
    {
        super.setUp()

        Random.random = Random.newGenerator(0)
        Handlers.Error = { XCTFail($0) }
        Handlers.Warning = { XCTFail($0) }
    }

    override func tearDown()
    {
        Handlers.Error = { _ in }

        super.tearDown()
    }

    func testDie_InvalidFace_Below1()
    {
        var error = String()
        Handlers.Error = { (string) in error = string }

        let die = Die(face: 0)

        XCTAssertTrue(error == "Invalid Die Face.  Setting it to 1.")
        XCTAssertTrue(die.face == 1)
    }

    func testDie_InvalidFace_AboveSides()
    {
        var error = String()
        Handlers.Error = { (string) in error = string }

        let die = Die(face: Die.sides+1)

        XCTAssertTrue(error == "Invalid Die Face.  Setting it to \(Die.sides).")
        XCTAssertTrue(die.face == Die.sides)
    }

    func testDie_ValidFace()
    {
        for face in 1...Die.sides
        {
            let die = Die(face: face)
            XCTAssertTrue(die.face == face)
        }
    }

    func testDie_Pushing()
    {
        let die = Die(face: 1, pushed: false)

        XCTAssertTrue(die.face == 1)
        XCTAssertFalse(die.pushed)

        die.pushed = true

        XCTAssertTrue(die.pushed)
    }

    func testDie_Equality()
    {
        XCTAssertTrue(Die(face: 1) == Die(face: 1))

        XCTAssertTrue(Die(face: 1, pushed: false) == Die(face: 1, pushed: false))
        XCTAssertTrue(Die(face: 1, pushed: true) == Die(face: 1, pushed: true))

        XCTAssertFalse(Die(face: 1, pushed: true) == Die(face: 1, pushed: false))
        XCTAssertFalse(Die(face: Die.sides, pushed: false) == Die(face: 1, pushed: false))

        XCTAssertFalse(Die(face: 1, pushed: false) == Die(face: 1, pushed: true))
        XCTAssertFalse(Die(face: 1, pushed: false) == Die(face: Die.sides, pushed: false))

        XCTAssertTrue(Die(face: 1, pushed: false) == 1)
        XCTAssertTrue(Die(face: Die.sides, pushed: false) == Die.sides)
        XCTAssertTrue(Die(face: 1) == 1)
        XCTAssertTrue(Die(face: Die.sides) == Die.sides)

        XCTAssertTrue(1 == Die(face: 1, pushed: false))
        XCTAssertTrue(Die.sides == Die(face: Die.sides, pushed: false))
        XCTAssertTrue(1 == Die(face: 1))
        XCTAssertTrue(Die.sides == Die(face: Die.sides))

        XCTAssertFalse(Die(face: 1, pushed: true) == 1)
        XCTAssertFalse(1 == Die(face: 1, pushed: true))

        XCTAssertFalse(Die(face: Die.sides, pushed: true) == Die.sides)
        XCTAssertFalse(Die.sides == Die(face: Die.sides, pushed: true))
    }

    func testDie_Roll()
    {
        Random.random = Random.newGenerator(0)

        let die = Die()

        XCTAssertTrue(die.face == 4)
        XCTAssertFalse(die.pushed)

        die.roll()

        XCTAssertTrue(die.face == 2)
        XCTAssertFalse(die.pushed)

        die.roll()

        XCTAssertTrue(die.face == 3)
        XCTAssertFalse(die.pushed)
    }

    func testDie_Serialization()
    {
        let die1 = Die(face: 1, pushed: false)
        let die2 = Die(face: 3, pushed: true)
        let die3 = Die(face: Die.sides, pushed: false)

        let die1_restored = Die(data: die1.asData())
        let die2_restored = Die(data: die2.asData())
        let die3_restored = Die(data: die3.asData())

        XCTAssertEqual(die1, die1_restored)
        XCTAssertEqual(die2, die2_restored)
        XCTAssertEqual(die3, die3_restored)
    }

    func testDie_InvalidSerialization()
    {
        var error = String()
        Handlers.Error = { (string) in error = string }

        _ = Die(data: .bool(false))
        XCTAssertTrue(error == "Bad data passed to Die initializer: data is not an array")
        error = ""

        _ = Die(data: .array([.bool(false)]))
        XCTAssertTrue(error == "Die data is not an array of size 2")
        error = ""

        _ = Die(data: .array([.int(0)]))
        XCTAssertTrue(error == "Die data is not an array of size 2")
        error = ""

        _ = Die(data: .array([.int(1)]))
        XCTAssertTrue(error == "Die data is not an array of size 2")
        error = ""

        _ = Die(data: .array([.int(1), .int(0)]))
        XCTAssertTrue(error == "Die has no pushed key")
        error = ""

        _ = Die(data: .array([.bool(false), .int(1)]))
        XCTAssertTrue(error == "Die has no face key")
        error = ""

        let die = Die(data: .array([.int(1), .bool(true)]))
        XCTAssertTrue(error.isEmpty)
        XCTAssertTrue(die.face == 1)
        XCTAssertTrue(die.pushed)
    }
}
