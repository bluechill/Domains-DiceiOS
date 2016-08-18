//
//  MainMenuViewController.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController
{
    override func viewDidAppear(_ animated: Bool) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate
        {
            if let controller = appDelegate.gameCenterController
            {
                self.navigationController!.present(controller, animated: true, completion: nil)
            }
            else
            {
                appDelegate.mainMenuController = self
            }
        }
    }
    
    @IBAction func pressedPoweredBySoar(_ sender: UIButton)
    {
        UIApplication.shared.openURL(URL(string: "http://soar.eecs.umich.edu/")!)
    }
    
    @IBAction func playPressed(_ sender: UIButton)
    {
        if GameCenterHelper.isAuthenticated()
        {
            self.performSegue(withIdentifier: "PlayGameSegue", sender: sender)
        }
        else
        {
            self.performSegue(withIdentifier: "NewGameSegue", sender: sender)
        }
    }
}
