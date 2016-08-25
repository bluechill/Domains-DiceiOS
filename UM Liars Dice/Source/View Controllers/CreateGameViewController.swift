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
import Cheetah

class CreateGameViewController: UIViewController
{
    @IBOutlet weak var aiOpponentsLabel: UILabel!
    @IBOutlet weak var aiOpponentsStepper: UIStepper!
    
    @IBOutlet weak var humanOpponentsLabel: UILabel!
    @IBOutlet weak var humanOpponentsStepper: UIStepper!
    
    @IBOutlet weak var passTurnAroundLabel: UILabel!
    @IBOutlet weak var passTurnAroundSwitch: UISwitch!
    
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
        
        humanOpponentsLabel.text = String(Int(sender.value))
        
        checkAndChangeStepper(aiOpponentsStepper)
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
        
        var players: [String:PlayerActionController] = ["Player " + String(playerCount): localActionController]
        
        for _ in 0..<Int(aiOpponentsStepper.value)
        {} // TODO: AI
        
        for _ in 0..<Int(humanOpponentsStepper.value)
        {
            if passTurnAroundSwitch.isOn
            {
                playerCount += 1
                players["Player " + String(playerCount)] = localActionController
            }
            else
            {} // TODO: Game Center
        }
        
        let engine = DiceLogicEngine(players: players.map{ $0.key }, start: false)
        
        for player in engine.players
        {
            player.userData[GameViewController.PlayerControllerString] = players[player.name]
        }
        
        gameController.game = engine
    }
}
