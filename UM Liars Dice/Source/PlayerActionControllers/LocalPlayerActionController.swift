//
//  LocalPlayerActionController.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 8/13/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import DiceLogicEngine
import UIKit

class LocalPlayerActionController: PlayerActionController
{
    weak var playerController: LocalPlayerViewController!
    weak var gameController: GameViewController!

    weak var player: Player!

    func performAction(_ player: Player)
    {
        playerController.localPlayerActionController = self

        self.player = player

        updateUI()
        enableUI()
    }

    func countDie(_ die: UInt) -> Int
    {
        var count = 0

        for player in gameController.game!.players
        {
            if playerController.localPlayerActionController.player == nil
            {
                break
            }
            else if die == 0
            {
                if player != playerController.localPlayerActionController.player
                {
                    count += player.dice.filter({ !$0.pushed }).count
                }
            }
            else if player == playerController.localPlayerActionController.player
            {
                count += player.dice.filter({ $0.face == die }).count
            }
            else
            {
                count += player.dice.filter({ $0.pushed && $0.face == die }).count
            }
        }

        return count
    }

    func imageOfDie(_ face: UInt) -> UIImage
    {
        let size: CGSize = CGSize(width: gameController!.statsLabelView.frame.height,
                                  height: gameController!.statsLabelView.frame.height)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        let layer = CALayer()

        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        let dieB = DieView.DieB(DieView.Radius, bounds)
        layer.addSublayer(dieB)

        if face != 7
        {
            let die = DieView.DieForFace(face, bounds)
            die.fillColor = playerController.die1.dieFaceColor.cgColor
            layer.addSublayer(die)
        }

        layer.render(in: UIGraphicsGetCurrentContext()!)

        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return outputImage!
    }

    func statsLabelText() -> NSAttributedString
    {
        let dice: Int = gameController.game!.players.map({ $0.dice.count }).sum()

        let string = NSMutableAttributedString(string: "\(dice) dice, \(countDie(1)) 1s \(countDie(2)) 2s \(countDie(3)) 3s \(countDie(4)) 4s \(countDie(5)) 5s \(countDie(6)) 6s \(countDie(0)) us")

        let die = NSTextAttachment()
        die.image = imageOfDie(7)

        let one = NSTextAttachment()
        one.image = imageOfDie(1)

        let two = NSTextAttachment()
        two.image = imageOfDie(2)

        let three = NSTextAttachment()
        three.image = imageOfDie(3)

        let four = NSTextAttachment()
        four.image = imageOfDie(4)

        let five = NSTextAttachment()
        five.image = imageOfDie(5)

        let six = NSTextAttachment()
        six.image = imageOfDie(6)

        let unknown = NSTextAttachment()
        unknown.image = imageOfDie(0)

//        string.replaceCharacters(in: string.mutableString.range(of: "dice"),
//                                with: NSAttributedString(attachment: die))

        string.replaceCharacters(in: string.mutableString.range(of: "1s"),
                                 with: NSAttributedString(attachment: one))

        string.replaceCharacters(in: string.mutableString.range(of: "2s"),
                                 with: NSAttributedString(attachment: two))

        string.replaceCharacters(in: string.mutableString.range(of: "3s"),
                                 with: NSAttributedString(attachment: three))

        string.replaceCharacters(in: string.mutableString.range(of: "4s"),
                                 with: NSAttributedString(attachment: four))

        string.replaceCharacters(in: string.mutableString.range(of: "5s"),
                                 with: NSAttributedString(attachment: five))

        string.replaceCharacters(in: string.mutableString.range(of: "6s"),
                                 with: NSAttributedString(attachment: six))

        string.replaceCharacters(in: string.mutableString.range(of: "us"),
                                 with: NSAttributedString(attachment: unknown))

        return string
    }

    func previousBidText() -> NSAttributedString
    {
        return NSAttributedString()
    }

    func yourPreviousBidText() -> NSAttributedString
    {
        return NSAttributedString()
    }

    func updateUI()
    {
        disableUI()

        self.gameController.statsLabelView.attributedText = statsLabelText()
        self.gameController.previousBidView.attributedText = previousBidText()
        self.gameController.yourPreviousBidView.attributedText = yourPreviousBidText()
    }

    private func enableOrDisableDice(_ die: DieView, _ index: Int)
    {
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

    private func animateButtonEnable(_ button: UIButton, _ state: Bool)
    {
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
        if self.player != nil && self.player.dice.count >= (index + 1)
        {
            die.face = self.player.dice[index].face
            die.setDieBackgroundColorAnimated(  color: UIColor.lightGray.withAlphaComponent(0.5),
                                             duration: GameViewController.animationLength)
        }
        else if self.player != nil
        {
            UIView.transition(with: die,
                              duration: GameViewController.animationLength,
                              options: UIViewAnimationOptions.transitionCrossDissolve,
                              animations: { die.isHidden = true },
                              completion: nil)
        }
        else if self.player == nil
        {
            die.face = 0
            UIView.transition(with: die,
                              duration: GameViewController.animationLength,
                              options: UIViewAnimationOptions.transitionCrossDissolve,
                              animations: { die.isHidden = false },
                              completion: nil)
        }

        die.isEnabled = false
    }

    func enableDie(die: DieView, index: Int)
    {
        if self.player == nil
        {
            return
        }

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

    private func disableButtonFunctionality()
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
//        buttonAnimateEnable(playerController.passButton, false)
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
    }

    private func enableButtonFunctionality()
    {
        enableDie(die: playerController.die1, index: 0)
        enableDie(die: playerController.die2, index: 1)
        enableDie(die: playerController.die3, index: 2)
        enableDie(die: playerController.die4, index: 3)
        enableDie(die: playerController.die5, index: 4)

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

    func sortDice()
    {
        var dice = [playerController.die1,
                    playerController.die2,
                    playerController.die3,
                    playerController.die4,
                    playerController.die5]

        var pushedDice = dice.filter({ isPushed(die: $0!) })
        let unpushedDice = dice.filter({ !isPushed(die: $0!) })

        pushedDice = pushedDice.sorted(by: {
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

        dice = pushedDice + unpushedDice

        for index in 0..<dice.count
        {
            guard let die = dice[index] else {
                print("Error: die is not valid")
                return
            }

            var constraints = self.playerController.view.constraints.filter({
                $0.firstAttribute == NSLayoutAttribute.leading &&
                    $0.secondAttribute == NSLayoutAttribute.trailing &&
                    $0.firstItem as? NSObject == die
            })

            if constraints.count == 0
            {
                constraints = self.playerController.view.constraints.filter({
                    $0.firstAttribute == NSLayoutAttribute.leading &&
                        $0.secondAttribute == NSLayoutAttribute.leading &&
                        $0.firstItem as! NSObject == die
                })
            }

            guard constraints.count == 1 else {
                print("Error: Die has no matching constraints for sorting.")
                return
            }

            self.playerController.view.removeConstraint(constraints[0])

            if index == 0
            {
                self.playerController.view.addConstraint(NSLayoutConstraint(item: die,
                                                                            attribute: NSLayoutAttribute.leading,
                                                                            relatedBy: NSLayoutRelation.equal,
                                                                            toItem: self.playerController.view,
                                                                            attribute: NSLayoutAttribute.leading,
                                                                            multiplier: 1.0,
                                                                            constant: 0.0))
            }
            else
            {
                self.playerController.view.addConstraint(NSLayoutConstraint(item: die,
                                                                            attribute: NSLayoutAttribute.leading,
                                                                            relatedBy: NSLayoutRelation.equal,
                                                                            toItem: dice[index-1]!,
                                                                            attribute: NSLayoutAttribute.trailing,
                                                                            multiplier: 1.0,
                                                                            constant: 8.0))
            }


            var endConstraint = self.playerController.view.constraints.filter({
                $0.firstAttribute == NSLayoutAttribute.leading &&
                $0.secondAttribute == NSLayoutAttribute.trailing &&
                $0.firstItem as? NSObject == playerController.countPicker &&
                $0.secondItem as? NSObject == die
            })

            if endConstraint.count == 1
            {
                self.playerController.view.removeConstraint(endConstraint[0])
            }
        }

        self.playerController.view.addConstraint(NSLayoutConstraint(item: self.playerController.countPicker,
                                                                    attribute: NSLayoutAttribute.leading,
                                                                    relatedBy: NSLayoutRelation.equal,
                                                                    toItem: dice[4]!,
                                                                    attribute: NSLayoutAttribute.trailing,
                                                                    multiplier: 1.0,
                                                                    constant: 12.0))

        UIView.animate(withDuration: 0.3, animations: {
            self.playerController.view.layoutIfNeeded()
        })
    }

    func disableUI()
    {
        disableButtonFunctionality()

        // Animate sorting of dice

        sortDice()
    }

    func enableUI()
    {
        enableButtonFunctionality()

        // Animate sorting of dice

        sortDice()
    }
}
