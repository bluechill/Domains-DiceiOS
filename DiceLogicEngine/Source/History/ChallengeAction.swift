//
//  ChallengeAction.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import MessagePack

public class ChallengeAction: HistoryAction
{
    static let challengeMaxKey = HistoryAction.actionMaxKey+2
    static private let challengeeKey: Int = HistoryAction.actionMaxKey+1
    static private let challengeActionIndexKey: Int = HistoryAction.actionMaxKey+2
    
    public internal(set) var challengee: String = ""
    public internal(set) var challengeActionIndex: Int = 0
    
    public init(player: String, challengee: String, challengeActionIndex: Int, correct: Bool)
    {
        super.init(player: player, correct: correct, type: .challengeAction)

        self.challengee = challengee
        self.challengeActionIndex = challengeActionIndex
    }
    
    required public init?(data: MessagePackValue)
    {
        super.init(data: data)
        
        guard self.type == .challengeAction else {
            ErrorHandling.error("Must be a ChallengeAction to initialize as such")
            return nil
        }
        
        let array = data.arrayValue!
        
        guard array.count >= ChallengeAction.challengeMaxKey+1 else {
            ErrorHandling.error("ChallengeAction data must have \(ChallengeAction.challengeMaxKey+1) items")
            return nil
        }
        
        guard let challengee = array[ChallengeAction.challengeeKey].stringValue else {
            ErrorHandling.error("ChallengeAction data must have a challengee")
            return nil
        }
        
        guard let challengeActionIndex = array[ChallengeAction.challengeActionIndexKey].integerValue else {
            ErrorHandling.error("ChallengeAction data must have a challenge action index")
            return nil
        }
        
        self.challengee = challengee
        self.challengeActionIndex = Int(challengeActionIndex)
    }
    
    public override func asData() -> MessagePackValue
    {
        var array = super.asData().arrayValue!
        
        array.append(.string(challengee))
        array.append(.int(Int64(challengeActionIndex)))
        
        return .array(array)
    }
    
    public override func isEqualTo(_ item: HistoryItem) -> Bool
    {
        guard super.isEqualTo(item) else {
            return false
        }
        
        guard let item = (item as? ChallengeAction) else {
            return false
        }
        
        return challengee == item.challengee && challengeActionIndex == item.challengeActionIndex
    }
}
