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

    static var animationLength: Double = 0.33
    static let PlayerControllerString = "PlayerController"

    // MARK: DiceObserver Methods
    
    func diceLogicActionOccurred(_ engine: DiceLogicEngine)
    {
        if let controller = (engine.currentTurn?.userData[GameViewController.PlayerControllerString] as? PlayerActionController)
        {
            controller.performAction(engine.currentTurn!)
        }
    }

    func diceLogicRoundDidEnd(_ engine: DiceLogicEngine)
    {

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
        game!.observers.append(self)
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

        if let bid = game.players[playerID].lastBid
        {
            let string = NSMutableAttributedString(string: "\(game.players[playerID].name): Last bid \(bid.count) \(bid.face)s")

            localPlayerViewController.localPlayerActionController.dieifyText(string: string)

            cell?.playerLabel.attributedText = string
        }

        cell?.challengeButton.tag = playerID

        var pushedDice = game.players[playerID].dice.filter({ $0.pushed })
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
