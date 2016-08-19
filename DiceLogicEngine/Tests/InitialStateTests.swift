//
//  InitialStateTests.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/16/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import XCTest
@testable import DiceLogicEngine

class InitialStateTests: XCTestCase
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
        let item = InitialState(players: ["Alice": [0,1,2], "Bob": [3,4,5]])
        XCTAssertTrue(item.players == ["Alice": [0,1,2], "Bob": [3,4,5]])
    }
    
    func testEquality()
    {
        let item1 = InitialState(players: ["Alice": [0,1,2], "Bob": [3,4,5]])
        let item2 = InitialState(players: ["Alice": [0,1,2], "Bob": [3,4,5]])
        let item3 = InitialState(players: ["Alice": [0,1,2], "John": [3,4,5]])
        let item4 = InitialState(players: ["Alice": [0,1,2], "Bob": [4,5,6]])
        let item5 = InitialState(players: ["John": [0,1,2], "Bob": [3,4,5]])
        let item6 = InitialState(players: ["Alice": [4,5,6]])

        XCTAssertTrue(item1 == item2)
        XCTAssertFalse(item1 == item3)
        XCTAssertFalse(item1 == item4)
        XCTAssertFalse(item1 == item5)
        XCTAssertFalse(item1 == item6)
        
        let action = HistoryItem(type: .initialState)
        XCTAssertFalse(item1 == action)
        
        let action2 = HistoryItem(type: .invalid)
        XCTAssertFalse(item1 == action2)
    }
    
    func testSerialization()
    {
        Handlers.Error = { _ in }

        let item = InitialState(players: ["Alice": [0,1,2], "Bob": [3,4,5]])
        let item_restore = InitialState(data: item.asData())
        
        XCTAssertTrue(item == item_restore)
        
        XCTAssertNil(InitialState(data: [
            .UInt(HistoryItem.HIType.invalid.rawValue),
        ]))
        
        XCTAssertNil(InitialState(data: [
            .UInt(HistoryItem.HIType.initialState.rawValue),
        ]))
        
        XCTAssertNil(InitialState(data: [
            .UInt(HistoryItem.HIType.initialState.rawValue),
            []
        ]))
        XCTAssertNil(InitialState(data: [
            .UInt(HistoryItem.HIType.initialState.rawValue),
            [:]
        ]))
        XCTAssertNil(InitialState(data: [
            .UInt(HistoryItem.HIType.initialState.rawValue),
            ["Alice":"A"]
        ]))
        XCTAssertNil(InitialState(data: [
            .UInt(HistoryItem.HIType.initialState.rawValue),
            [.Int(1):"A"]
        ]))
        XCTAssertNil(InitialState(data: [
            .UInt(HistoryItem.HIType.initialState.rawValue),
            ["Alice":[-1]]
        ]))
        
        XCTAssertNotNil(InitialState(data: [
            .UInt(HistoryItem.HIType.initialState.rawValue),
            ["Alice":[]]
        ]))
        XCTAssertNotNil(InitialState(data: [
            .UInt(HistoryItem.HIType.initialState.rawValue),
            ["Alice":[0,1,2]]
        ]))
    }
}
