//
//  GameViewController.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/21/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import UIKit
import DiceLogicEngine

class PlayerTableViewButton: UIButton
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        OperationQueue.main.addOperation({ self.isHighlighted = true })
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        OperationQueue.main.addOperation({ self.isHighlighted = false })
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        OperationQueue.main.addOperation({ self.isHighlighted = false })
    }
}

class PlayerTableViewCell: UITableViewCell
{
    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var challengeButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var die1: DieView!
    @IBOutlet weak var die2: DieView!
    @IBOutlet weak var die3: DieView!
    @IBOutlet weak var die4: DieView!
    @IBOutlet weak var die5: DieView!
}

class GameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DiceObserver
{
    // MARK: Variables

    var game: DiceLogicEngine? = nil
    weak var localPlayerViewController: LocalPlayerViewController!

    @IBOutlet weak var opponentsView: UITableView!
    @IBOutlet weak var statsLabelView: UILabel!
    @IBOutlet weak var previousBidView: UILabel!
    @IBOutlet weak var yourPreviousBidView: UILabel!
    @IBOutlet weak var specialRulesDie: DieView!

    static var animationLength: Double = 0.33
    static let PlayerControllerString = "PlayerController"

    // MARK: DiceObserver Methods
    
    func diceLogicActionOccurred(_ engine: DiceLogicEngine)
    {
        if self.navigationController!.presentedViewController != nil
        {
            return
        }

        if let controller = (engine.currentTurn?.userData[GameViewController.PlayerControllerString] as? PlayerActionController)
        {
            controller.performAction(engine.currentTurn!)
        }
    }

    func diceLogicRoundWillEnd(_ engine: DiceLogicEngine)
    {
        let roundover = (self.storyboard?.instantiateViewController(withIdentifier: "RoundOverviewController") as? RoundOverviewController)
        roundover!.game = engine
        roundover!.playerDice = engine.players.map({ $0.dice.map({ $0.face }) })
        roundover!.playerActions = engine.players.map({ $0.lastAction })

        let blurEffect = UIBlurEffect(style: .light)
        let blueEffectView = UIVisualEffectView(effect: blurEffect)
        blueEffectView.frame = self.view.bounds
        roundover?.view.frame = self.view.bounds
        roundover?.view.backgroundColor = UIColor.clear
        roundover?.view.insertSubview(blueEffectView, at: 0)
        roundover?.modalPresentationStyle = .overCurrentContext

        let statsLabelText = NSMutableAttributedString(attributedString: localPlayerViewController.localPlayerActionController.allStatsLabelText())
        DieText.dieifyText(statsLabelText, CGSize(width: roundover!.previousActionLabel.frame.height * 0.8,
                                                  height: roundover!.previousActionLabel.frame.height * 0.8))

        roundover?.statsLabelView.attributedText = statsLabelText
        roundover?.previousActionLabel.attributedText = localPlayerViewController.localPlayerActionController.previousActionText()

        roundover?.previousActionLabel.dieifyText()
        roundover?.playersView.reloadData()
        roundover?.localPlayerActionController = localPlayerViewController.localPlayerActionController

        localPlayerViewController.localPlayerActionController.updateUI(animate: false, blankText: true)
        localPlayerViewController.localPlayerActionController.updateDice()
        localPlayerViewController.localPlayerActionController.playerController.die1.face = 0
        localPlayerViewController.localPlayerActionController.playerController.die2.face = 0
        localPlayerViewController.localPlayerActionController.playerController.die3.face = 0
        localPlayerViewController.localPlayerActionController.playerController.die4.face = 0
        localPlayerViewController.localPlayerActionController.playerController.die5.face = 0

        self.navigationController!.present(roundover!, animated: true, completion: nil)
    }

    // MARK: Storyboard Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "LocalPlayerSegue"
        {
            for player in game!.players
            {
                if let localActionController = (player.userData[GameViewController.PlayerControllerString] as? LocalPlayerActionController),
                    let localPlayerViewController = (segue.destination as? LocalPlayerViewController)
                {
                    localActionController.playerController = localPlayerViewController
                    localActionController.gameController = self
                    self.localPlayerViewController = localPlayerViewController
                    self.localPlayerViewController.localPlayerActionController = localActionController
                    break
                }
            }
        }
    }

    override func viewDidLayoutSubviews()
    {
        if (game!.observers.filter({ ($0 as? GameViewController) == self }).count == 0)
        {
            game!.observers.append(self)
        }
    }

    override func viewWillDisappear(_ animated: Bool)
    {
        if (game!.observers.filter({ ($0 as? GameViewController) == self }).count > 0)
        {
            game!.observers = game!.observers.filter({ ($0 as? GameViewController) != self })
        }
    }

    override func viewWillAppear(_ animated: Bool)
    {
        self.specialRulesDie.setDieBackgroundColorAnimated(color: LiarsDiceColors.michiganMaize(), duration: 0.33)
        self.specialRulesDie.isEnabled = false
        self.specialRulesDie.face = 1

        if (game!.observers.filter({ ($0 as? GameViewController) == self }).count == 0)
        {
            game!.observers.append(self)
        }
    }

    override func viewDidAppear(_ animated: Bool)
    {
        diceLogicActionOccurred(game!)
    }

    // MARK: Table View Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return game!.players.count-1
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

        var playerID = (indexPath as NSIndexPath).row

        if let player = localPlayerViewController.localPlayerActionController.player
        {
            if playerID >= game.players.index(of: player)!
            {
                playerID += 1
            }
        }

        cell?.playerLabel.text = game.players[playerID].name

        if let action = game.players[playerID].lastAction
        {
            if let bid = (action as? BidAction)
            {
                let string = NSMutableAttributedString(string: "\(game.players[playerID].name): Last bid \(bid.count) \(bid.face)s")

                cell?.playerLabel.attributedText = string
                cell?.playerLabel.dieifyText()
            }
            else if (action as? ExactAction) != nil
            {
                let string = NSMutableAttributedString(string: "\(game.players[playerID].name): Exacted")
                cell?.playerLabel.attributedText = string
            }
            else if let challenge = (action as? ChallengeAction)
            {
                let string = NSMutableAttributedString(string: "\(game.players[playerID].name): Challenged \(challenge.challengee)")
                cell?.playerLabel.attributedText = string
            }
            else if (action as? PassAction) != nil
            {
                let string = NSMutableAttributedString(string: "\(game.players[playerID].name): Passed")
                cell?.playerLabel.attributedText = string
            }
        }

        cell?.challengeButton.tag = playerID

        var pushedDice = game.players[playerID].dice.filter({ $0.pushed })
        let dice = game.players[playerID].dice
        pushedDice.sort(by: { $0.face < $1.face })

        let lambda = { (dieView: DieView?, index: Int) in
            guard let dieView = dieView else {
                return
            }

            if pushedDice.count >= (index + 1)
            {
                dieView.face = pushedDice[index].face
            }
            else
            {
                dieView.face = 0
            }

            if dice.count >= index + 1 && dieView.isHidden == true
            {
                dieView.isHidden = false
            }
            else if dice.count < index + 1 && dieView.isHidden == false
            {
                dieView.isHidden = true
            }
        }

        lambda(cell?.die1, 0)
        lambda(cell?.die2, 1)
        lambda(cell?.die3, 2)
        lambda(cell?.die4, 3)
        lambda(cell?.die5, 4)

        guard let currentTurn = game.currentTurn else {
            cell?.challengeButton.isEnabled = false
            return cell!
        }

        if currentTurn.userData[GameViewController.PlayerControllerString] is LocalPlayerActionController
        {
            cell?.challengeButton.isEnabled = currentTurn.canChallenge(game.players[playerID].name)
        }
        else
        {
            cell?.challengeButton.isEnabled = false
        }

        return cell!
    }

    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Opponents"
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

    @IBAction func challenge(_ sender: UIButton)
    {
        localPlayerViewController.challenge(sender)
    }
}
