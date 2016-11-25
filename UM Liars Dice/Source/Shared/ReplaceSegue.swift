//
//  ReplaceSegue.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 11/25/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import UIKit

class ReplaceSegue: UIStoryboardSegue
{
    override func perform()
    {
        let navigationController = self.source.navigationController;

        // Get a changeable copy of the stack
        let controllerStack = NSMutableArray(array: navigationController!.viewControllers)
        // Replace the source controller with the destination controller, wherever the source may be
        controllerStack.replaceObject(at: controllerStack.index(of: self.source), with: self.destination)

        // Assign the updated stack with animation
        navigationController!.setViewControllers((controllerStack.subarray(with: NSMakeRange(0, controllerStack.count)) as! [UIViewController]), animated: true)
    }
}
