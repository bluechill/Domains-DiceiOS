//
//  GameCenterHelper.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/26/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import GameKit

class GameCenterHelper
{
    static var playerMap = [String:String]()
    
    static func isAuthenticated() -> Bool
    {
        return GKLocalPlayer.localPlayer().isAuthenticated
    }
        
    static func playerIDToDisplayName(_ playerID: String) -> String
    {
        guard let player = playerMap[playerID] else {
            return playerID
        }
        
        return player
    }
}
