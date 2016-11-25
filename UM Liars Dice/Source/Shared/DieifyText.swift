//
//  DieifyText.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 11/25/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import UIKit

class DieText
{
    static func imageOfDie(_ face: UInt, _ size: CGSize) -> UIImage
    {
        if (size.width <= 0 || size.height <= 0)
        {
            return UIImage()
        }

        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        let layer = CALayer()

        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        let dieB = DieView.DieB(DieView.Radius, bounds)
        layer.addSublayer(dieB)

        if face != 7
        {
            let die = DieView.DieForFace(face, bounds)
            die.fillColor = DieView.DefaultFaceColor.cgColor
            layer.addSublayer(die)
        }

        layer.render(in: UIGraphicsGetCurrentContext()!)

        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return outputImage!
    }

    static func dieifyText(_ string: NSMutableAttributedString, _ size: CGSize)
    {
        let die = NSTextAttachment()
        die.image = imageOfDie(7, size)

        let one = NSTextAttachment()
        one.image = imageOfDie(1, size)

        let two = NSTextAttachment()
        two.image = imageOfDie(2, size)

        let three = NSTextAttachment()
        three.image = imageOfDie(3, size)

        let four = NSTextAttachment()
        four.image = imageOfDie(4, size)

        let five = NSTextAttachment()
        five.image = imageOfDie(5, size)

        let six = NSTextAttachment()
        six.image = imageOfDie(6, size)

        let unknown = NSTextAttachment()
        unknown.image = imageOfDie(0, size)

        //        string.replaceCharacters(in: string.mutableString.range(of: "dice"),
        //                                with: NSAttributedString(attachment: die))

        if string.mutableString.range(of: "1s").length > 0 {
            string.replaceCharacters(in: string.mutableString.range(of: "1s"),
                                     with: NSAttributedString(attachment: one))
        }

        if string.mutableString.range(of: "2s").length > 0 {
            string.replaceCharacters(in: string.mutableString.range(of: "2s"),
                                     with: NSAttributedString(attachment: two))
        }

        if string.mutableString.range(of: "3s").length > 0 {
            string.replaceCharacters(in: string.mutableString.range(of: "3s"),
                                     with: NSAttributedString(attachment: three))
        }

        if string.mutableString.range(of: "4s").length > 0 {
            string.replaceCharacters(in: string.mutableString.range(of: "4s"),
                                     with: NSAttributedString(attachment: four))
        }

        if string.mutableString.range(of: "5s").length > 0 {
            string.replaceCharacters(in: string.mutableString.range(of: "5s"),
                                     with: NSAttributedString(attachment: five))
        }

        if string.mutableString.range(of: "6s").length > 0 {
            string.replaceCharacters(in: string.mutableString.range(of: "6s"),
                                     with: NSAttributedString(attachment: six))
        }

        if string.mutableString.range(of: "?s").length > 0 {
            string.replaceCharacters(in: string.mutableString.range(of: "?s"),
                                     with: NSAttributedString(attachment: unknown))
        }
    }
}

extension UILabel
{
    func dieifyText()
    {
        let string = NSMutableAttributedString()

        if let a = self.attributedText
        {
            string.append(a)
        }
        else if let s = self.text
        {
            string.append(NSAttributedString(string: s))
        }

        let size: CGSize = CGSize(width: self.frame.height * 0.8,
                                  height: self.frame.height * 0.8)

        DieText.dieifyText(string, size)

        self.attributedText = string
    }
}

