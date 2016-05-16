//
//  SpecialRulesInEffectTests.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/16/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import XCTest
import MessagePack
@testable import DiceLogicEngine

class SpecialRulesInEffectTests: XCTestCase
{
    func testEquality()
    {
        let action1 = SpecialRulesInEffect()
        let action2 = SpecialRulesInEffect()
        let action3 = HistoryItem(type: .Invalid)
        let action4 = HistoryItem(type: .SpecialRulesInEffect)
        
        XCTAssertFalse(action1 == action3)
        XCTAssertFalse(action1 == action4)
        XCTAssertTrue(action1 == action2)
    }
    
    func testSerialization()
    {
        let action = SpecialRulesInEffect()
        let action_restored = SpecialRulesInEffect(data: action.asData())
        
        XCTAssertTrue(action == action_restored)
        
        XCTAssertNil(SpecialRulesInEffect(data: [
            .UInt(HistoryItem.HIType.Invalid.rawValue)
            ]))
    }
}
