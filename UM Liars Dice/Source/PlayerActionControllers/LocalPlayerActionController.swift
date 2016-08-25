//
//  LocalPlayerActionController.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 8/13/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import DiceLogicEngine

class LocalPlayerActionController : PlayerActionController
{
    weak var playerController: LocalPlayerViewController!
    weak var gameController: GameViewController!
    
    weak var player: Player!
    
    func performAction(_ player: Player)
    {
        playerController.localPlayerActionController = self
        
        self.player = player
        
        enableUI()
    }
    
    func enableUI()
    {
        enableDie(die: playerController.die1, index: 0)
        enableDie(die: playerController.die2, index: 1)
        enableDie(die: playerController.die3, index: 2)
        enableDie(die: playerController.die4, index: 3)
        enableDie(die: playerController.die5, index: 4)
        
        let lamdba = { (die: DieView, index: Int) in
            if self.player.dice.count >= (index + 1)
            {
                die.face = self.player.dice[index].face
                
                if die.isHidden
                {
                    UIView.transition(with: die,
                                      duration: GameViewController.animationLength,
                                      options: UIViewAnimationOptions.transitionCrossDissolve,
                                      animations: {
                                        die.isHidden = false
                                      },
                                      completion: nil)
                }
            }
            else
            {
                UIView.transition(with: die,
                                  duration: GameViewController.animationLength,
                                  options: UIViewAnimationOptions.transitionCrossDissolve,
                                  animations: { die.isHidden = true },
                                  completion: nil)
            }
        }
        
        lamdba(playerController.die1, 0)
        lamdba(playerController.die2, 1)
        lamdba(playerController.die3, 2)
        lamdba(playerController.die4, 3)
        lamdba(playerController.die5, 4)
        
        let buttonAnimateEnable = { (button: UIButton, state: Bool) in
            if state && !button.isEnabled
            {
                UIView.animate(withDuration: GameViewController.animationLength, animations: {
                    button.tintColor = LiarsDiceColors.michiganMaize()
                })
            }
            else if !state && button.isEnabled
            {
                UIView.animate(withDuration: GameViewController.animationLength, animations: {
                    button.tintColor = UIColor.lightGray
                })
            }
            
            button.isEnabled = state
        }
        
        buttonAnimateEnable(playerController.exactButton, player.canExact())
        buttonAnimateEnable(playerController.passButton, player.canPass())
        buttonAnimateEnable(playerController.bidButton, true)
        
        playerController.countPicker.tableView.isScrollEnabled = true
        playerController.facePicker.tableView.isScrollEnabled = true
        playerController.countPicker.tableView.allowsSelection = true
        playerController.facePicker.tableView.allowsSelection = true
        
        UIView.animate(withDuration: GameViewController.animationLength, animations: {
            if let index = self.playerController.countPicker.tableView.indexPathForSelectedRow {
                self.playerController.countPicker.tableView.cellForRow(at: index)?.selectedBackgroundView!.backgroundColor = LiarsDiceColors.michiganSelectionBlue()
            }
            
            if let index = self.playerController.facePicker.tableView.indexPathForSelectedRow {
                self.playerController.facePicker.tableView.cellForRow(at: index)?.selectedBackgroundView!.backgroundColor = LiarsDiceColors.michiganSelectionBlue()
            }
        })
    }
    
    func bid()
    {
        disableUI()
    }
    
    func pass()
    {
        enableUI()
    }
    
    func exact()
    {
        disableUI()
    }
    
    func challenge(id: Int)
    {
        disableUI()
    }
    
    func isPushed(die: DieView) -> Bool
    {
        let constraint = self.playerController.view.constraints.filter({ $0.firstAttribute == NSLayoutAttribute.top && $0.secondAttribute == NSLayoutAttribute.bottom && $0.firstItem as! NSObject == die })
        
        guard constraint.count == 1 else {
            return false
        }
        
        if constraint[0].constant == 0
        {
            return true
        }
        
        return false
    }
    
    func push(die: Int)
    {
        let dice = [playerController.die1,
                    playerController.die2,
                    playerController.die3,
                    playerController.die4,
                    playerController.die5]
        
        let unpushedDice = dice.filter({ !isPushed(die: $0!) })
        
        if unpushedDice.count == 1
        {
            if unpushedDice[0]! == playerController.die1
            {
                disableDie(die: playerController.die1, index: 0)
            }
            else if unpushedDice[0]! == playerController.die2
            {
                disableDie(die: playerController.die2, index: 1)
            }
            else if unpushedDice[0]! == playerController.die3
            {
                disableDie(die: playerController.die3, index: 2)
            }
            else if unpushedDice[0]! == playerController.die4
            {
                disableDie(die: playerController.die4, index: 3)
            }
            else if unpushedDice[0]! == playerController.die5
            {
                disableDie(die: playerController.die5, index: 4)
            }
        }
        else if unpushedDice.count > 1
        {
            for die in unpushedDice
            {
                if die! == playerController.die1
                {
                    enableDie(die: playerController.die1, index: 0)
                }
                else if die! == playerController.die2
                {
                    enableDie(die: playerController.die2, index: 1)
                }
                else if die! == playerController.die3
                {
                    enableDie(die: playerController.die3, index: 2)
                }
                else if die! == playerController.die4
                {
                    enableDie(die: playerController.die4, index: 3)
                }
                else if die! == playerController.die5
                {
                    enableDie(die: playerController.die5, index: 4)
                }
            }
        }
    }
    
    func disableDie(die: DieView, index: Int)
    {
        if self.player.dice.count >= (index + 1)
        {
            die.face = self.player.dice[index].face
            die.setDieBackgroundColorAnimated(  color: UIColor.lightGray.withAlphaComponent(0.5),
                                             duration: GameViewController.animationLength)
        }
        else
        {
            UIView.transition(with: die,
                              duration: GameViewController.animationLength,
                              options: UIViewAnimationOptions.transitionCrossDissolve,
                              animations: { die.isHidden = true },
                              completion: nil)
        }
        
        die.isEnabled = false
    }
    
    func enableDie(die: DieView, index: Int)
    {
        if self.player.dice.count >= (index + 1)
        {
            die.face = self.player.dice[index].face
            die.setDieBackgroundColorAnimated(  color: UIColor.white,
                                             duration: GameViewController.animationLength)
        }
        else
        {
            UIView.transition(with: die,
                              duration: GameViewController.animationLength,
                              options: UIViewAnimationOptions.transitionCrossDissolve,
                              animations: { die.isHidden = true },
                              completion: nil)
        }
        
        die.isEnabled = true
    }

    func disableUI()
    {
        disableDie(die: playerController.die1, index: 0)
        disableDie(die: playerController.die2, index: 1)
        disableDie(die: playerController.die3, index: 2)
        disableDie(die: playerController.die4, index: 3)
        disableDie(die: playerController.die5, index: 4)
        
        let buttonAnimateEnable = { (button: UIButton, state: Bool) in
            if state && !button.isEnabled
            {
                UIView.animate(withDuration: GameViewController.animationLength, animations: {
                    button.tintColor = LiarsDiceColors.michiganMaize()
                })
            }
            else if !state && button.isEnabled
            {
                UIView.animate(withDuration: GameViewController.animationLength, animations: {
                    button.tintColor = UIColor.lightGray
                })
            }
            
            button.isEnabled = state
        }
        
        buttonAnimateEnable(playerController.exactButton, false)
        buttonAnimateEnable(playerController.passButton, false)
        buttonAnimateEnable(playerController.bidButton, false)
        
        playerController.countPicker.tableView.isScrollEnabled = false
        playerController.facePicker.tableView.isScrollEnabled = false
        playerController.countPicker.tableView.allowsSelection = false
        playerController.facePicker.tableView.allowsSelection = false
        
        UIView.animate(withDuration: GameViewController.animationLength, animations: {
            if let index = self.playerController.countPicker.tableView.indexPathForSelectedRow {
                self.playerController.countPicker.tableView.cellForRow(at: index)?.selectedBackgroundView!.backgroundColor = UIColor.lightGray.withAlphaComponent(0.25)
            }
            
            if let index = self.playerController.facePicker.tableView.indexPathForSelectedRow {
                self.playerController.facePicker.tableView.cellForRow(at: index)?.selectedBackgroundView!.backgroundColor = UIColor.lightGray.withAlphaComponent(0.25)
            }
        })
        
        // Animate sorting of dice
        
        var dice = [playerController.die1,
                    playerController.die2,
                    playerController.die3,
                    playerController.die4,
                    playerController.die5]
        
        dice = dice.sorted(by: {
            let one = isPushed(die: $0.0!)
            let two = isPushed(die: $0.1!)
            
            if (one && two) || (!one && !two)
            {
                return $0.0!.face < $0.1!.face
            }
            else if one
            {
                return false
            }
            else //if two
            {
                return true
            }
        })
        
        dice = dice.filter({ isPushed(die: $0! ) })
        
        if dice.count > 0
        {
            var xConstraints: [NSLayoutConstraint] = []
            
            for die in dice
            {
                let constraint = self.playerController.view.constraints.filter({ $0.firstAttribute == NSLayoutAttribute.leading && $0.secondAttribute == NSLayoutAttribute.trailing && $0.firstItem as? NSObject == die })
                
                if constraint.count == 1
                {
                    xConstraints.append(constraint[0])
                }
                else
                {
                    let constraint = self.playerController.view.constraints.filter({ $0.firstAttribute == NSLayoutAttribute.leading && $0.secondAttribute == NSLayoutAttribute.leading && $0.firstItem as? NSObject == die })
                    
                    xConstraints.append(constraint[0])
                }
            }
            
            for index in 0..<dice.count
            {
//                if index == 0 && xConstraints[0].secondAttribute != NSLayoutAttribute.leading
//                {
//                    let constraint = self.playerController.view.constraints.filter({ $0.firstAttribute == NSLayoutAttribute.leading && $0.secondAttribute == NSLayoutAttribute.leading && $0.firstItem as? DieView != nil })
//                    
//                    xConstraints[0].firstItem = constraint[0].firstItem
//                    constraint[0].firstItem = dice[0]
//                }
//                else if xConstraints[index].secondItem !=
            }
        }
    }
}
