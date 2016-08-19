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
        let aiOpponents = Int(aiOpponentsLabel.text!)!
        let humanOpponents = Int(humanOpponentsLabel.text!)!
        
        let names = NameGenerator.generateNamesFor(aiOpponents)
        let humanNames = Array(repeating: "Placeholder", count: humanOpponents)
        
        let players = names + humanNames
        
        let engine = DiceLogicEngine(players: players, start: false)
        
        if humanOpponentsStepper.value > 0 && !passTurnAroundSwitch.isOn
        {
            // multi-player
            if GameCenterHelper.isAuthenticated()
            {
                createGameButton.isEnabled = false
                
                let humanPlayers = Int(humanOpponentsLabel.text!)! + 1
                
                let request = GKMatchRequest()
                request.minPlayers = humanPlayers
                request.maxPlayers = humanPlayers
                request.playerGroup = aiOpponents + 1
                
                GKTurnBasedMatch.find(for: request, withCompletionHandler: { (match, error) in
                    guard error == nil else {
                        return
                    }
                    
                    guard let match = match else {
                        return
                    }
                    
                    match.loadMatchData(completionHandler: { (data, error) in
                        guard let data = data else {
                            // New match, first player
                            engine.shuffleAndCreateRound()
                            return
                        }
                        
                        // Previous match, update with data
                        engine.updateWithData(data)
                    })
                })
            }
            else
            {
                let alertController = UIAlertController.init(title: "Game Center Disabled", message: "You have been logged out of Game Center. Would you like to authenticate?", preferredStyle: UIAlertControllerStyle.alert);
                
                let yes = UIAlertAction.init(title: "Yes", style: UIAlertActionStyle.default, handler: { (action) in
                    UIApplication.shared.openURL(URL.init(string: "gamecenter:")!)
                })
                
                let no = UIAlertAction.init(title: "No", style: UIAlertActionStyle.cancel, handler: nil)
                
                alertController.addAction(yes)
                alertController.addAction(no)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        else
        {
            engine.shuffleAndCreateRound()
        }
        
        var aiPlayers = 0
        var hPlayers = 0
        
        let localID = GKLocalPlayer.localPlayer().playerID
        
        for index in 0..<(aiOpponents+humanOpponents)
        {
            if  engine.players[index].userData["AI"] != nil ||
                (engine.players[index].userData["GCID"] == nil && aiPlayers < aiOpponents)
            {
                aiPlayers += 1
                engine.players[index].userData["AI"] = true
                engine.players[index].userData["PlayerController"] = SoarPlayerActionController()
            }
            else if engine.players[index].userData["GCID"] != nil || hPlayers < humanOpponents
            {
                hPlayers += 1
                
                if engine.players[index].userData["GCID"] == nil
                {
                    engine.players[index].userData["GCID"] = "-1"
                }
                
                if String(engine.players[index].userData["GCID"]) != localID
                {
                    engine.players[index].userData["PlayerController"] = RemotePlayerActionController()
                }
                else
                {
                    engine.players[index].userData["PlayerController"] = LocalPlayerActionController()
                }
            }
            else
            {
                engine.players[index].userData["PlayerController"] = LocalPlayerActionController()
            }
        }
        
        if engine.players.filter({ (player) in player.userData["PlayerController"] is LocalPlayerActionController }).count == 0
        {
            
        }
        
        self.performSegue(withIdentifier: "PlayGameSegue", sender: self)
    }
}
