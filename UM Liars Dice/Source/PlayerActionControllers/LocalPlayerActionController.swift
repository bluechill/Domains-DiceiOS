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

    func minimumCountFor(face: UInt) -> Int
    {
        guard let bid = gameController.game!.lastBid else {
            return 1
        }

        if face != 1 && bid.face == 1 && !gameController.game!.isSpecialRules
        {
            return Int(bid.count) * 2 + 1
        }
        else if face > bid.face
        {
            return Int(bid.count)
        }
        else //if face <= bid.face
        {
            return Int(bid.count)+1
        }
    }

    func performAction(_ player: Player)
    {
        guard self.playerController.presentedViewController == nil else {
            return
        }

        playerController.localPlayerActionController = self

        let action = { (unused: UIAlertAction?) in
            if let bid = self.player.lastBid
            {
                self.playerController.facePicker.setSelected(index: Int(Die.sides - bid.face))
                self.playerController.countPicker.setSelected(index: Int(40 - self.minimumCountFor(face: bid.face)))
            }
            else if let bid = self.gameController.game!.lastBid
            {
                self.playerController.facePicker.setSelected(index: Int(Die.sides - bid.face))
                self.playerController.countPicker.setSelected(index: Int(40 - self.minimumCountFor(face: bid.face)))
            }

            self.gameController.opponentsView.reloadSections(IndexSet(integer: 0),
                                                             with: UITableViewRowAnimation.automatic)

            self.updateUI()
            self.enableUI()
        }

        if self.player != nil && player != self.player
        {
            updateUI(animate: true, blankText: true)

            self.player = player
            updateDice()

            playerController.die1.face = 0
            playerController.die2.face = 0
            playerController.die3.face = 0
            playerController.die4.face = 0
            playerController.die5.face = 0

            let controller = UIAlertController(title: "\(player.name)'s turn!", message: "The current turn has been passed to another human player.  Tap to continue as \(player.name)", preferredStyle: UIAlertControllerStyle.alert)

            controller.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.cancel, handler: action))

            self.playerController.present(controller, animated: true, completion: nil)
        }
        else
        {
            self.player = player
            self.updateUI(animate: false)
            updateDice()

            action(nil)
        }
    }

    func countDie(_ die: UInt) -> Int
    {
        var count = 0
        let specialRules = gameController.game!.isSpecialRules

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
                count += player.dice.filter({ $0.face == die || ($0.face == 1 && !specialRules) }).count
            }
            else
            {
                count += player.dice.filter({ $0.pushed && ($0.face == die || ($0.face == 1 && !specialRules)) }).count
            }
        }

        return count
    }

    func imageOfDie(_ face: UInt) -> UIImage
    {
        let size: CGSize = CGSize(width: gameController!.statsLabelView.frame.height * 0.8,
                                  height: gameController!.statsLabelView.frame.height * 0.8)

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

    func dieifyText(string: NSMutableAttributedString)
    {
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

        if string.mutableString.range(of: "1s").length > 0 {
            string.replaceCharacters(in: string.mutableString.range(of: "1s"),
                                     with: NSAttributedString(attachment: one))
        }

        if string.mutableString.range(of: "2s").length > 0 {
            string.replaceCharacters(in: string.mutableString.range(of: "2s"),
                                     with: NSAttributedString(attachment: two))
        }

        if string.mutableString.range(of: "3s").length > 0 {
            string.replaceCharacters(in: string.mutableString.range(of: "3s"),
                                     with: NSAttributedString(attachment: three))
        }

        if string.mutableString.range(of: "4s").length > 0 {
            string.replaceCharacters(in: string.mutableString.range(of: "4s"),
                                     with: NSAttributedString(attachment: four))
        }

        if string.mutableString.range(of: "5s").length > 0 {
            string.replaceCharacters(in: string.mutableString.range(of: "5s"),
                                     with: NSAttributedString(attachment: five))
        }

        if string.mutableString.range(of: "6s").length > 0 {
            string.replaceCharacters(in: string.mutableString.range(of: "6s"),
                                     with: NSAttributedString(attachment: six))
        }

        if string.mutableString.range(of: "us").length > 0 {
            string.replaceCharacters(in: string.mutableString.range(of: "us"),
                                     with: NSAttributedString(attachment: unknown))
        }
    }

    func statsLabelText() -> NSAttributedString
    {
        let dice: Int = gameController.game!.players.map({ $0.dice.count }).sum()

        let string = NSMutableAttributedString(string: "\(dice) dice, \(countDie(1)) 1s \(countDie(2)) 2s \(countDie(3)) 3s \(countDie(4)) 4s \(countDie(5)) 5s \(countDie(6)) 6s")

        dieifyText(string: string)

        return string
    }

    func previousBidText() -> NSAttributedString
    {
        guard let bid = gameController.game!.lastBid else {
            return NSAttributedString(string: "No previous bid.")
        }

        let string = NSMutableAttributedString(string: "\(bid.player) bid \(bid.count) \(bid.face)s")

        dieifyText(string: string)

        return string
    }

    func yourPreviousBidText() -> NSAttributedString
    {
        guard let currentTurn = gameController.game?.currentTurn else {
            return NSAttributedString(string: "")
        }

        guard playerController.localPlayerActionController.player != nil &&
              currentTurn == playerController.localPlayerActionController.player else {
            return NSAttributedString(string: "")
        }

        guard let bid = playerController.localPlayerActionController.player.lastBid else {
            return NSAttributedString(string: "It's your turn!")
        }

        let string = NSMutableAttributedString(string: "It's your turn! You last bid \(bid.count) \(bid.face)s")

        dieifyText(string: string)

        return string
    }

    func updateUI(animate: Bool = true,  blankText: Bool = false)
    {
        if (animate)
        {
            let animation: CATransition = CATransition()
            animation.duration = GameViewController.animationLength
            animation.type = kCATransitionFade
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.gameController.statsLabelView.layer.add(animation, forKey: "changeTextTransition")
            self.gameController.previousBidView.layer.add(animation, forKey: "changeTextTransition")
            self.gameController.yourPreviousBidView.layer.add(animation, forKey: "changeTextTransition")
        }

        if blankText
        {
            self.gameController.statsLabelView.attributedText = NSAttributedString(string: "No player stats")
            self.gameController.previousBidView.attributedText = previousBidText()
            self.gameController.yourPreviousBidView.attributedText = NSAttributedString(string: "No previous bid")
        }
        else
        {
            self.gameController.statsLabelView.attributedText = statsLabelText()
            self.gameController.previousBidView.attributedText = previousBidText()
            self.gameController.yourPreviousBidView.attributedText = yourPreviousBidText()
        }
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

    func pushedDice() -> [UInt]
    {
        let dice = [playerController.die1,
                    playerController.die2,
                    playerController.die3,
                    playerController.die4,
                    playerController.die5]

        return dice.filter({ isPushed(die: $0!) }).map{ $0!.face }
    }

    func bid()
    {
        let count: UInt = 40 - UInt(playerController.countPicker.getSelectedIndex())
        let face: UInt = Die.sides - UInt(playerController.facePicker.getSelectedIndex())

        disableUI()

        let controller = UIAlertController(title: "Bid?", message: "", preferredStyle: UIAlertControllerStyle.alert)

        let msg = NSMutableAttributedString(string: "Are you sure you want to bid \(count) \(face)s")
        dieifyText(string: msg)
        controller.setValue(msg, forKey: "attributedMessage")

        controller.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: { (_: UIAlertAction) in
            self.player.bid(count, face: face, pushDice: self.pushedDice())
        }))

        controller.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: { (_ : UIAlertAction) in
            self.enableUI()
        }))

        self.playerController.present(controller, animated: true, completion: nil)
    }

    func pass()
    {
        disableUI()

        player.pass(pushedDice())

        updateUI()
    }

    func exact()
    {
        disableUI()

        player.exact()

        updateUI()
    }

    func challenge(id: Int)
    {
        disableUI()

        player.challenge(gameController.game!.players[id].name)

        updateUI()
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

    func updateDice()
    {
        let ensurePushed = { (die: DieView) in
            let constraint = self.playerController.view.constraints.filter({ $0.firstAttribute == NSLayoutAttribute.top && $0.secondAttribute == NSLayoutAttribute.bottom && $0.firstItem as! NSObject == die })

            guard constraint.count == 1 else {
                return
            }

            self.playerController.view.layoutIfNeeded()

            constraint[0].constant = 0

            UIView.animate(withDuration: 0.3, animations: {
                self.playerController.view.layoutIfNeeded()
            })
        }

        let ensureUnpushed = { (die: DieView) in
            let constraint = self.playerController.view.constraints.filter({ $0.firstAttribute == NSLayoutAttribute.top && $0.secondAttribute == NSLayoutAttribute.bottom && $0.firstItem as! NSObject == die })

            guard constraint.count == 1 else {
                return
            }

            self.playerController.view.layoutIfNeeded()

            constraint[0].constant = 35

            UIView.animate(withDuration: 0.3, animations: {
                self.playerController.view.layoutIfNeeded()
            })
        }

        let action = { (die: DieView, index: Int) in
            if self.player.dice.count >= (index+1) && self.player.dice[index].pushed
            {
                ensurePushed(die)
            }
            else if self.player.dice.count >= (index+1) && !self.player.dice[index].pushed
            {
                ensureUnpushed(die)
            }
        }

        action(playerController.die1, 0)
        action(playerController.die2, 1)
        action(playerController.die3, 2)
        action(playerController.die4, 3)
        action(playerController.die5, 4)
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

    private func disableButtonFunctionality(animate: Bool)
    {
        disableDie(die: playerController.die1, index: 0)
        disableDie(die: playerController.die2, index: 1)
        disableDie(die: playerController.die3, index: 2)
        disableDie(die: playerController.die4, index: 3)
        disableDie(die: playerController.die5, index: 4)

        let buttonAnimateEnable = { (button: UIButton, state: Bool) in
            var animation = {}

            if state && !button.isEnabled
            {
                animation = { button.tintColor = LiarsDiceColors.michiganMaize() }
            }
            else if !state && button.isEnabled
            {
                animation = { button.tintColor = UIColor.lightGray }
            }

            if animate
            {
                UIView.animate(withDuration: GameViewController.animationLength, animations: animation)
            }
            else
            {
                animation()
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

        let animation = {
            if let index = self.playerController.countPicker.tableView.indexPathForSelectedRow {
                self.playerController.countPicker.tableView.cellForRow(at: index)?.selectedBackgroundView!.backgroundColor = UIColor.lightGray.withAlphaComponent(0.25)
            }

            if let index = self.playerController.facePicker.tableView.indexPathForSelectedRow {
                self.playerController.facePicker.tableView.cellForRow(at: index)?.selectedBackgroundView!.backgroundColor = UIColor.lightGray.withAlphaComponent(0.25)
            }
        }

        if animate
        {
            UIView.animate(withDuration: GameViewController.animationLength, animations: animation)
        }
        else
        {
            animation()
        }
    }

    private func enableButtonFunctionality(animate: Bool)
    {
        enableDie(die: playerController.die1, index: 0)
        enableDie(die: playerController.die2, index: 1)
        enableDie(die: playerController.die3, index: 2)
        enableDie(die: playerController.die4, index: 3)
        enableDie(die: playerController.die5, index: 4)

        let buttonAnimateEnable = { (button: UIButton, state: Bool) in
            var animation = {}

            if state && !button.isEnabled
            {
                animation = { button.tintColor = LiarsDiceColors.michiganMaize() }
            }
            else if !state && button.isEnabled
            {
                animation = { button.tintColor = UIColor.lightGray }
            }

            if animate
            {
                UIView.animate(withDuration: GameViewController.animationLength, animations: animation)
            }
            else
            {
                animation()
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

        let animation = {
            if let index = self.playerController.countPicker.tableView.indexPathForSelectedRow {
                self.playerController.countPicker.tableView.cellForRow(at: index)?.selectedBackgroundView!.backgroundColor = LiarsDiceColors.michiganSelectionBlue()
            }

            if let index = self.playerController.facePicker.tableView.indexPathForSelectedRow {
                self.playerController.facePicker.tableView.cellForRow(at: index)?.selectedBackgroundView!.backgroundColor = LiarsDiceColors.michiganSelectionBlue()
            }
        }

        if animate
        {
            UIView.animate(withDuration: GameViewController.animationLength, animations: animation)
        }
        else
        {
            animation()
        }
    }

    func sortDice(animate: Bool)
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
        
        if animate
        {
            UIView.animate(withDuration: 0.3, animations: {
                self.playerController.view.layoutIfNeeded()
            })
        }
        else
        {
            self.playerController.view.layoutIfNeeded()
        }
    }
    
    func disableUI(animate: Bool = true)
    {
        disableButtonFunctionality(animate: animate)
        
        // Animate sorting of dice
        
        sortDice(animate: animate)
    }
    
    func enableUI(animate: Bool = true)
    {
        enableButtonFunctionality(animate: animate)
        
        // Animate sorting of dice
        
        sortDice(animate: animate)
    }
}
