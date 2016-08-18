//
//  HandlersTests.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/18/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import XCTest
@testable import DiceLogicEngine

class HandlersTests: XCTestCase
{
    override func setUp()
    {
        Handlers.Error = { _ in }
        Handlers.Warning = { _ in }
    }
    
    override func tearDown()
    {
        Handlers.Error = { _ in }
        Handlers.Warning = { _ in }
    }
    
    func testError()
    {
        var e = false
        Handlers.Error = { _ in e = true }
        
        XCTAssertFalse(e)
        ErrorHandling.error("test")
        XCTAssertTrue(e)
        e = false
        XCTAssertFalse(e)
        ErrorHandling.error("test2")
        XCTAssertTrue(e)
    }
    
    func testWarning()
    {
        var w = false
        Handlers.Warning = { _ in w = true }
        
        XCTAssertFalse(w)
        ErrorHandling.warning("test")
        XCTAssertTrue(w)
        w = false
        XCTAssertFalse(w)
        ErrorHandling.warning("test2")
        XCTAssertTrue(w)
    }
}
