//
//  SettingsViewController.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/21/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet var difficulty: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        difficulty.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "difficulty")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func changedDifficulty(_ sender: UISegmentedControl)
    {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "difficulty")
    }
}
