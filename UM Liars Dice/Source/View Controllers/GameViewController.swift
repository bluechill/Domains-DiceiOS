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

class GameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    var game: DiceLogicEngine? = nil
    
    // MARK: Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 8
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
        
        cell?.playerLabel.text = "Player \((indexPath as NSIndexPath).row+1)"
        cell?.challengeButton.tag = (indexPath as NSIndexPath).row
        
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
        
    }
}
