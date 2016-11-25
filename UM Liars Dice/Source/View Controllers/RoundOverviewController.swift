//
//  RoundOverview.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 11/25/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import UIKit
import DiceLogicEngine

// From GameViewController
//class PlayerTableViewButton: UIButton
//class PlayerTableViewCell: UITableViewCell

class RoundOverviewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Variables

    var playerDice: [[UInt]] = []
    var playerActions: [HistoryAction?] = []
    weak var game: DiceLogicEngine? = nil
    weak var localPlayerActionController: LocalPlayerActionController! = nil

    @IBOutlet weak var playersView: UITableView!
    @IBOutlet weak var statsLabelView: UILabel!
    @IBOutlet weak var previousActionLabel: UILabel!

    static var animationLength: Double = 0.33
    static let PlayerControllerString = "RoundOverview"

    // MARK: Storyboard Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
    }

    override func viewDidLayoutSubviews()
    {
    }

    override func viewWillAppear(_ animated: Bool)
    {
    }

    override func viewDidAppear(_ animated: Bool)
    {
    }

    @IBAction func dismiss()
    {
        self.dismiss(animated: true, completion: {
            if let winner = self.game!.winner
            {
                let controller = UIAlertController(title: "\(winner.name) won!", message: "Tap to continue.", preferredStyle: UIAlertControllerStyle.alert)

                controller.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.cancel, handler: nil))

                self.localPlayerActionController?.playerController.present(controller, animated: true, completion: nil)
            }

            if let controller = (self.game!.currentTurn?.userData[GameViewController.PlayerControllerString] as? PlayerActionController)
            {
                controller.performAction(self.game!.currentTurn!)
            }
        })
    }

    // MARK: Table View Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return game!.players.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "cell"

        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? PlayerTableViewCell

        if cell == nil
        {
            cell = PlayerTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
        }

        cell?.selectionStyle = UITableViewCellSelectionStyle.default

        let background = UIView()
        background.backgroundColor = LiarsDiceColors.michiganSelectionBlue()
        cell?.selectedBackgroundView = background

        guard let game = game else {
            return cell!
        }

        let playerID = (indexPath as NSIndexPath).row

        let name = game.players[playerID].name
        cell?.playerLabel.text = name

        if let action = playerActions[playerID]
        {
            if let bid = (action as? BidAction)
            {
                let string = NSMutableAttributedString(string: "\(name): Last bid \(bid.count) \(bid.face)s")

                if !bid.correct
                {
                    string.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSMakeRange(0, string.length))
                }

                cell?.playerLabel.attributedText = string
                cell?.playerLabel.dieifyText()
            }
            else if let exact = (action as? ExactAction)
            {
                let string = NSMutableAttributedString(string: "\(name): Exacted \(exact.correct ? "correctly" : "incorrectly")")
                cell?.playerLabel.attributedText = string
            }
            else if let challenge = (action as? ChallengeAction)
            {
                let string = NSMutableAttributedString(string: "\(name): Challenged \(challenge.challengee) \(challenge.correct ? "correctly" : "incorrectly")")
                cell?.playerLabel.attributedText = string
            }
            else if let pass = (action as? PassAction)
            {
                let string = NSMutableAttributedString(string: "\(name): Passed while \(pass.correct ? "not bluffing" : "bluffing")")
                cell?.playerLabel.attributedText = string
            }
        }

        var dice = playerDice[playerID]
        dice.sort(by: { $0 < $1 })

        if dice.count >= 1
        {
            cell?.die1.face = dice[0]
        }
        else
        {
            cell?.die1.isHidden = true
        }

        if dice.count >= 2
        {
            cell?.die2.face = dice[1]
        }
        else
        {
            cell?.die2.isHidden = true
        }

        if dice.count >= 3
        {
            cell?.die3.face = dice[2]
        }
        else
        {
            cell?.die3.isHidden = true
        }

        if dice.count >= 4
        {
            cell?.die4.face = dice[3]
        }
        else
        {
            cell?.die4.isHidden = true
        }

        if dice.count >= 5
        {
            cell?.die5.face = dice[4]
        }
        else
        {
            cell?.die5.isHidden = true
        }

        return cell!
    }

    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Players"
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        if let view = view as? UITableViewHeaderFooterView
        {
            view.backgroundView?.backgroundColor = LiarsDiceColors.michiganBlue()
            view.textLabel!.backgroundColor = LiarsDiceColors.michiganBlue()
            view.textLabel!.textColor = UIColor.white
        }
    }
}
