//
//  LocalPlayerViewController.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/22/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import UIKit
import DiceLogicEngine

class LocalPlayerViewController: UIViewController, ScrollPickerViewDataSource, ScrollPickerViewDelegate
{
    @IBOutlet weak var countPicker: ScrollPickerView!
    @IBOutlet weak var facePicker: ScrollPickerView!

    var hasTouchedCountPicker = false

    @IBOutlet weak var die1: DieView!
    @IBOutlet weak var die2: DieView!
    @IBOutlet weak var die3: DieView!
    @IBOutlet weak var die4: DieView!
    @IBOutlet weak var die5: DieView!

    @IBOutlet weak var exactButton: UIButton!
    @IBOutlet weak var passButton: UIButton!
    @IBOutlet weak var bidButton: UIButton!

    weak var localPlayerActionController: LocalPlayerActionController!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        countPicker.datasource = self
        countPicker.delegate = self

        facePicker.datasource = self
        facePicker.delegate = self

        let footer = UIView(frame: CGRect(x: 0, y: 0, width: countPicker.frame.width, height: countPicker.frame.height / 3.0))
        let footer2 = UIView(frame: CGRect(x: 0, y: 0, width: facePicker.frame.width, height: facePicker.frame.height / 3.0))

        let header = UIView(frame: CGRect(x: 0, y: 0, width: countPicker.frame.width, height: countPicker.frame.height / 3.0))
        let header2 = UIView(frame: CGRect(x: 0, y: 0, width: facePicker.frame.width, height: facePicker.frame.height / 3.0))

        countPicker.footerView = footer
        facePicker.footerView = footer2

        countPicker.headerView = header
        facePicker.headerView = header2

        countPicker.layer.borderWidth = 1.0
        countPicker.layer.borderColor = LiarsDiceColors.michiganSelectionBlue().cgColor

        facePicker.layer.borderWidth = 1.0
        facePicker.layer.borderColor = LiarsDiceColors.michiganSelectionBlue().cgColor
    }

    override func viewDidAppear(_ animated: Bool)
    {
        view.layoutIfNeeded()

        countPicker.setSelected(index: 39)
        facePicker.setSelected(index: 4)
    }

    func scrollPickerView(numberOfRowsFor scrollPicker: ScrollPickerView) -> UInt
    {
        if scrollPicker == countPicker
        {
            var selectedIndex = facePicker.getSelectedIndex()
            if selectedIndex == -1
            {
                selectedIndex = 1
            }

            let face = Die.sides - UInt(selectedIndex)
            return (40 - UInt(localPlayerActionController.minimumCountFor(face: face))) + 1
        }
        else
        {
            return Die.sides
        }
    }

    func scrollPickerView(_ scrollPicker: ScrollPickerView, viewForIndex index: UInt) -> UIView
    {
        if scrollPicker == countPicker
        {
            let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: scrollPicker.bounds.width, height: scrollPicker.bounds.width))
            label.text = String(40 - index)
            label.textColor = UIColor.white
            label.textAlignment = NSTextAlignment.center
            label.backgroundColor = UIColor.clear

            return label
        }
        else
        {
            let offset: CGFloat = 6.0
            let widthHeight = scrollPicker.bounds.width - offset*2

            let view = DieView(frame: CGRect(x: offset, y: offset, width: widthHeight, height: widthHeight))
            view.face = Die.sides - index
            view.isEnabled = false

            return view
        }
    }

    func scrollPickerView(_ scrollPicker: ScrollPickerView, heightForRow row: UInt) -> CGFloat
    {
        return scrollPicker.bounds.width
    }

    func scrollPickerView(_ scrollPicker: ScrollPickerView, canSelectIndex index: UInt) -> Bool
    {
        return scrollPicker.tableView.isScrollEnabled
    }

    func scrollPickerView(_ scrollPicker: ScrollPickerView, didSelectIndex index: Int)
    {
        print("Selected \(index)")

        guard countPicker.getSelectedIndex() != -1 && facePicker.getSelectedIndex() != -1 else {
            return
        }

        let count: UInt = 40 - UInt(countPicker.getSelectedIndex())
        let face: UInt = Die.sides - UInt(facePicker.getSelectedIndex())

        var animation = {}
        let state = localPlayerActionController.player.isValidBid(count, face: face)

        if state && !bidButton.isEnabled
        {
            animation = { self.bidButton.tintColor = LiarsDiceColors.michiganMaize() }
        }
        else if !state && bidButton.isEnabled
        {
            animation = { self.bidButton.tintColor = UIColor.lightGray }
        }

        UIView.animate(withDuration: GameViewController.animationLength, animations: animation)
        bidButton.isEnabled = state
    }

    @IBAction func pushDie(_ sender: DieView)
    {
        let constraint = self.view.constraints.filter({ $0.firstAttribute == NSLayoutAttribute.top && $0.secondAttribute == NSLayoutAttribute.bottom && $0.firstItem as! NSObject == sender })

        guard constraint.count == 1 else {
            return
        }

        self.view.layoutIfNeeded()

        if (constraint[0].constant == 0)
        {
            constraint[0].constant = 35
        }
        else
        {
            constraint[0].constant = 0
        }

        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })

        localPlayerActionController.push(die: Int(sender.face))

        var animation = {}

        let state = localPlayerActionController.player.canPushDice(localPlayerActionController.newPushedDice())

        if state && (!bidButton.isEnabled || !passButton.isEnabled)
        {
            animation = {
                self.bidButton.tintColor = LiarsDiceColors.michiganMaize()
                self.passButton.tintColor = LiarsDiceColors.michiganMaize()
            }
        }
        else if !state && (bidButton.isEnabled || passButton.isEnabled)
        {
            animation = {
                self.bidButton.tintColor = UIColor.lightGray
                self.passButton.tintColor = UIColor.lightGray
            }
        }

        UIView.animate(withDuration: GameViewController.animationLength, animations: animation)
        bidButton.isEnabled = state
        passButton.isEnabled = state
    }

    @IBAction func exact(_ sender: UIButton)
    {
        localPlayerActionController.exact()
    }

    @IBAction func pass(_ sender: UIButton)
    {
        localPlayerActionController.pass()
    }

    @IBAction func bid(_ sender: UIButton)
    {
        localPlayerActionController.bid()
    }

    @IBAction func challenge(_ sender: UIButton)
    {
        localPlayerActionController.challenge(id: sender.tag)
    }
}
