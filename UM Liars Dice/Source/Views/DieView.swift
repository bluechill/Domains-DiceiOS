//
//  DieView.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/23/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import UIKit
import DiceLogicEngine

@IBDesignable class DieView: UIButton
{
    @IBInspectable var dieBackgroundColor = UIColor.white
    @IBInspectable var dieFaceColor = UIColor.black
    
    private var _face: UInt = 1
    @IBInspectable var face: UInt
    {
        get { return _face }
        set {
            _face = newValue
            
            if _face < 1
            {
                _face = 1
            }
            else if _face > Die.sides
            {
                _face = Die.sides
            }
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect)
    {
        let backgroundRadius: CGFloat = 0.1
        let radius: CGFloat = 0.1
        
        let dieBackground = UIBezierPath.init(roundedRect: self.bounds, cornerRadius: backgroundRadius * self.bounds.width)
        dieBackgroundColor.setFill()
        dieBackground.fill()
        
        let face: UIBezierPath = UIBezierPath()
        
        switch _face
        {
        case 1:
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
        case 2:
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 4.0, y: self.bounds.height * 3.0 / 4.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width * 3.0 / 4.0, y: self.bounds.height / 4.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
        case 3:
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 4.0, y: self.bounds.height * 3.0 / 4.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width * 3.0 / 4.0, y: self.bounds.height / 4.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
        case 4:
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 4.0, y: self.bounds.height / 4.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 4.0, y: self.bounds.height * 3.0 / 4.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width * 3.0 / 4.0, y: self.bounds.height / 4.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width * 3.0 / 4.0, y: self.bounds.height * 3.0 / 4.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
        case 5:
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 4.0, y: self.bounds.height / 4.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 4.0, y: self.bounds.height * 3.0 / 4.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
            
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
            
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width * 3.0 / 4.0, y: self.bounds.height / 4.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width * 3.0 / 4.0, y: self.bounds.height * 3.0 / 4.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
        case 6:
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 4.0, y: self.bounds.height / 4.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 4.0, y: self.bounds.height * 3.0 / 4.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 4.0, y: self.bounds.height / 2.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width * 3.0 / 4.0, y: self.bounds.height / 2.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
            
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width * 3.0 / 4.0, y: self.bounds.height / 4.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width * 3.0 / 4.0, y: self.bounds.height * 3.0 / 4.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
        default:
            face.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0),
                                                radius: radius * self.bounds.width,
                                                startAngle: 0,
                                                endAngle: CGFloat(M_PI * 2.0),
                                                clockwise: true))
        }
        
        dieFaceColor.setFill()
        face.fill()
    }
}
