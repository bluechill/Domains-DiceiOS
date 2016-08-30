//
//  PlayViewController.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/21/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import UIKit

class GameViewCell: UITableViewCell
{
    @IBOutlet weak var gameLabel: UILabel!
}

class PlayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var gameTableView: UITableView!

    var singlePlayerGames = [String]()
    var multiPlayerGames = [String]()

    override func viewDidLoad()
    {
        super.viewDidLoad()

        singlePlayerGames = ["1\n2", "3\n4", "5\n6"]
        multiPlayerGames = ["7\n8", "9\n10", "11\n12"]

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressRecognized))
        gameTableView.addGestureRecognizer(longPress)
    }

    @IBAction func longPressRecognized(_ sender: UILongPressGestureRecognizer)
    {
        gameTableView.setEditing(true, animated: true)

        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneEditing))
        self.navigationItem.setRightBarButton(item, animated: true)
    }

    @IBAction func doneEditing(_ sender: UIBarButtonItem)
    {
        gameTableView.setEditing(false, animated: true)

        let item = UIBarButtonItem(title: "New Game", style: UIBarButtonItemStyle.plain, target: self, action: #selector(newGameSegue))
        self.navigationItem.setRightBarButton(item, animated: true)
    }

    @IBAction func newGameSegue(_ sender: UIBarButtonItem)
    {
        self.performSegue(withIdentifier: "NewGameSegue", sender: sender)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return singlePlayerGames.count
        }
        else
        {
            return multiPlayerGames.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "cell"

        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? GameViewCell

        if cell == nil
        {
            cell = GameViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
        }

        cell?.showsReorderControl = true
        cell?.selectionStyle = UITableViewCellSelectionStyle.default

        let background = UIView()
        background.backgroundColor = LiarsDiceColors.michiganSelectionBlue()
        cell?.selectedBackgroundView = background

        if (indexPath as NSIndexPath).section == 0
        {
            cell?.gameLabel.text = singlePlayerGames[(indexPath as NSIndexPath).row]
        }
        else
        {
            cell?.gameLabel.text = multiPlayerGames[(indexPath as NSIndexPath).row]
        }

        return cell!
    }

    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == 0
        {
            return "Singleplayer Games"
        }
        else
        {
            return "Multiplayer Games"
        }
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        if let view = view as? UITableViewHeaderFooterView
        {
            view.backgroundView?.backgroundColor = UIColor.clear
            view.textLabel!.backgroundColor = UIColor.clear
            view.textLabel!.textColor = UIColor.white
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == UITableViewCellEditingStyle.delete
        {
            if (indexPath as NSIndexPath).section == 0
            {
                singlePlayerGames.remove(at: (indexPath as NSIndexPath).row)
            }
            else
            {
                multiPlayerGames.remove(at: (indexPath as NSIndexPath).row)
            }

            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        if (sourceIndexPath as NSIndexPath).section == 0
        {
            let item = singlePlayerGames.remove(at: (sourceIndexPath as NSIndexPath).row)
            singlePlayerGames.insert(item, at: (destinationIndexPath as NSIndexPath).row)
        }
        else
        {
            let item = multiPlayerGames.remove(at: (sourceIndexPath as NSIndexPath).row)
            multiPlayerGames.insert(item, at: (destinationIndexPath as NSIndexPath).row)
        }
    }

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath
    {
        if (sourceIndexPath as NSIndexPath).section == 0 && (sourceIndexPath as NSIndexPath).section != (proposedDestinationIndexPath as NSIndexPath).section
        {
            return IndexPath(row: singlePlayerGames.count-1, section: 0)
        }
        else if (sourceIndexPath as NSIndexPath).section == 1 && (sourceIndexPath as NSIndexPath).section != (proposedDestinationIndexPath as NSIndexPath).section
        {
            return IndexPath(row: 0, section: 1)
        }

        return proposedDestinationIndexPath
    }
}
