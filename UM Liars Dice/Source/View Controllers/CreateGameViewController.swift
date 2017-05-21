//
//  CreateGameViewController.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/22/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import UIKit
import DiceLogicEngine
import GameKit

class PlayerNameTableViewCell: UITableViewCell
{
    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var playerNameText: UITextField!
}

class CreateGameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var aiOpponentsLabel: UILabel!
    @IBOutlet weak var aiOpponentsStepper: UIStepper!

    @IBOutlet weak var humanOpponentsLabel: UILabel!
    @IBOutlet weak var humanOpponentsStepper: UIStepper!

    @IBOutlet weak var passTurnAroundLabel: UILabel!
    @IBOutlet weak var passTurnAroundSwitch: UISwitch!

    @IBOutlet weak var customPlayerNamesTable: UITableView!

    @IBOutlet weak var createGameButton: UIButton!

    static var maxPlayers: Double = 8
    static var animationLength: Double = 0.33

    override func viewWillAppear(_ animated: Bool)
    {
        createGameButton.isEnabled = true

        if (!GameCenterHelper.isAuthenticated())
        {
            passTurnAroundSwitch.setOn(true, animated: false)
            passTurnAroundSwitch.isEnabled = false

            aiOpponentsStepper.value = 1
            aiOpponentsLabel.text = "1"

            humanOpponentsStepper.value = 0
            humanOpponentsLabel.text = "0"

            passTurnAroundLabel.isHidden = true
            passTurnAroundSwitch.isHidden = true
        }
    }

    func checkAndChangeStepper(_ stepper: UIStepper)
    {
        var other = humanOpponentsStepper

        if stepper == humanOpponentsStepper
        {
            other = aiOpponentsStepper
        }

        stepper.maximumValue = CreateGameViewController.maxPlayers - (other?.value)!
        let enabled = (stepper.maximumValue > 0)

        if enabled && !stepper.isEnabled
        {
            UIView.animate(withDuration: CreateGameViewController.animationLength, animations: {
                stepper.tintColor = LiarsDiceColors.michiganMaize()
            })

        }
        else if !enabled && stepper.isEnabled
        {
            UIView.animate(withDuration: CreateGameViewController.animationLength, animations: {
                stepper.tintColor = UIColor.lightGray
            })
        }

        stepper.isEnabled = enabled
    }

    func checkAndChangeCreate()
    {
        let enabled = (aiOpponentsStepper.value + humanOpponentsStepper.value > 0)

        if enabled && !createGameButton.isEnabled
        {
            UIView.animate(withDuration: CreateGameViewController.animationLength, animations: {
                self.createGameButton.tintColor = LiarsDiceColors.michiganMaize()
            })
        }
        else if !enabled && createGameButton.isEnabled
        {
            UIView.animate(withDuration: CreateGameViewController.animationLength, animations: {
                self.createGameButton.tintColor = UIColor.lightGray
            })
        }

        createGameButton.isEnabled = enabled
    }

    @IBAction func aiOpponentsDidChangeValue(_ sender: UIStepper)
    {
        let animation: CATransition = CATransition()
        animation.duration = GameViewController.animationLength
        animation.type = kCATransitionFade
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        aiOpponentsLabel.layer.add(animation, forKey: "changeTextTransition")

        aiOpponentsLabel.text = String(Int(sender.value))

        checkAndChangeStepper(humanOpponentsStepper)
        checkAndChangeCreate()
    }

    @IBAction func humanOpponentsDidChangeValue(_ sender: UIStepper)
    {
        if sender.value != 0 && Int(humanOpponentsLabel.text!) == 0
        {
            UIView.transition(with: passTurnAroundSwitch,
                                      duration: CreateGameViewController.animationLength,
                                      options: UIViewAnimationOptions.transitionCrossDissolve,
                                      animations: { self.passTurnAroundSwitch.isHidden = false },
                                      completion: nil)
            UIView.transition(with: passTurnAroundLabel,
                                      duration: CreateGameViewController.animationLength,
                                      options: UIViewAnimationOptions.transitionCrossDissolve,
                                      animations: { self.passTurnAroundLabel.isHidden = false },
                                      completion: nil)
        }
        else if sender.value == 0 && Int(humanOpponentsLabel.text!) != 0
        {
            UIView.transition(with: passTurnAroundSwitch,
                                      duration: CreateGameViewController.animationLength,
                                      options: UIViewAnimationOptions.transitionCrossDissolve,
                                      animations: { self.passTurnAroundSwitch.isHidden = true },
                                      completion: nil)
            UIView.transition(with: passTurnAroundLabel,
                                      duration: CreateGameViewController.animationLength,
                                      options: UIViewAnimationOptions.transitionCrossDissolve,
                                      animations: { self.passTurnAroundLabel.isHidden = true },
                                      completion: nil)
        }

        let animation: CATransition = CATransition()
        animation.duration = GameViewController.animationLength
        animation.type = kCATransitionFade
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        humanOpponentsLabel.layer.add(animation, forKey: "changeTextTransition")

        humanOpponentsLabel.text = String(Int(sender.value))

        checkAndChangeStepper(aiOpponentsStepper)
        checkAndChangeCreate()

        customPlayerNamesTable.reloadSections([0], with: UITableViewRowAnimation.fade)
    }

    @IBAction func passTurnAroundSwitchDidChangeValue(_ sender: UISwitch)
    {
        let hidden = !passTurnAroundSwitch.isOn
        if customPlayerNamesTable.isHidden != hidden
        {
            UIView.transition(with: customPlayerNamesTable,
                              duration: CreateGameViewController.animationLength,
                              options: UIViewAnimationOptions.transitionCrossDissolve,
                              animations: { self.customPlayerNamesTable.isHidden = hidden },
                              completion: nil)
        }

        checkAndChangeCreate()
    }

    @IBAction func createGame(_ sender: UIButton)
    {
        self.performSegue(withIdentifier: "GameViewSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        guard let gameController = (segue.destination as? GameViewController) else {
            return
        }

        var playerCount = 1
        let localActionController = LocalPlayerActionController()

        var players: [String:PlayerActionController] = ["Human " + String(playerCount): localActionController]

        for i in 0..<Int(aiOpponentsStepper.value)
        {
            players["AI " + String(i)] = SoarPlayerActionController()
        }

        for _ in 0..<Int(humanOpponentsStepper.value)
        {
            if passTurnAroundSwitch.isOn
            {
                playerCount += 1
                players["Human " + String(playerCount)] = localActionController
            }
            else
            {} // TODO: Game Center
        }

        var playerNameMap: [String:String] = [:]

        var count = 0
        for keyValue in players
        {
            guard keyValue.key.characters.starts(with: "Human".characters) else {
                playerNameMap[keyValue.key] = keyValue.key
                continue
            }

            let cell = self.customPlayerNamesTable.cellForRow(at: IndexPath(row: count, section: 0)) as! PlayerNameTableViewCell
            count += 1

            guard let string = cell.playerNameText.text else {
                playerNameMap[cell.playerNameText.placeholder!] = keyValue.key
                continue
            }

            guard string.characters.count > 0 else {
                playerNameMap[cell.playerNameText.placeholder!] = keyValue.key
                continue
            }

            playerNameMap[string] = keyValue.key
        }

        let engine = DiceLogicEngine(players: playerNameMap.map{ $0.key }, start: true)

        for player in engine.players
        {
            player.userData[GameViewController.PlayerControllerString] = players[playerNameMap[player.name]!]
        }

        gameController.game = engine
    }

    // MARK: Table View Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return Int(humanOpponentsStepper.value)+1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "cell"

        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? PlayerNameTableViewCell

        if cell == nil
        {
            cell = PlayerNameTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
        }

        cell?.selectionStyle = UITableViewCellSelectionStyle.default

        let background = UIView()
        background.backgroundColor = LiarsDiceColors.michiganSelectionBlue()
        cell?.selectedBackgroundView = background

        let playerID = (indexPath as NSIndexPath).row
        cell?.playerLabel.text = "Player \(playerID+1) Name:"
        cell?.playerNameText.placeholder = "Player \(playerID+1)"

        return cell!
    }

    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Human Player Names"
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
