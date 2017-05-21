//
//  SoarPlayerActionController.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 8/12/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import DiceLogicEngine

class SoarPlayerActionController: PlayerActionController
{
    func performAction(_ player: Player)
    {
        let soarPlayer = SoarPlayer(Int32(Random.random.nextInt()))

        let difficulty = UserDefaults.standard.integer(forKey: "difficulty");
        let action = soarPlayer?.performAction(player, engine: player.engine, difficulty: Int32(difficulty))!

        if (action is BidAction)
        {
            let bidAction = action as! BidAction
            player.bid(bidAction.count, face: bidAction.face, pushDice: bidAction.pushedDice)
        }
        else if (action is PassAction)
        {
            player.pass()
        }
        else if (action is ExactAction)
        {
            player.exact()
        }
        else if (action is ChallengeAction)
        {
            let challengeAction = action as! ChallengeAction
            player.challenge(challengeAction.challengee)
        }
    }
}
