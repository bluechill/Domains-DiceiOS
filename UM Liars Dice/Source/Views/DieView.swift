//
//  DieView.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/23/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import UIKit
import DiceLogicEngine
import CoreText

@IBDesignable class DieView: UIButton
{
    var _dieBackgroundColor = UIColor.white
    @IBInspectable var dieBackgroundColor: UIColor {
        get { return _dieBackgroundColor }
        set {
            _dieBackgroundColor = newValue
            
            dieB.fillColor = dieBackgroundColor.cgColor
        }
    }
    
    func setDieBackgroundColorAnimated(color: UIColor, duration: Double)
    {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.dieB.fillColor = color.cgColor
        })
        
        let animation = CABasicAnimation(keyPath: "fillColor")
        animation.fromValue = _dieBackgroundColor.cgColor
        animation.toValue = color.cgColor
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.fillMode = kCAFillModeBoth
        animation.isRemovedOnCompletion = true

        dieB.add(animation, forKey: nil)
        
        _dieBackgroundColor = color
        
        CATransaction.commit()
    }
    
    var _dieFaceColor = UIColor.black
    @IBInspectable var dieFaceColor: UIColor {
        get { return _dieFaceColor }
        set {
            _dieFaceColor = newValue
            
            die1.fillColor = dieFaceColor.cgColor
            die2.fillColor = dieFaceColor.cgColor
            die3.fillColor = dieFaceColor.cgColor
            die4.fillColor = dieFaceColor.cgColor
            die5.fillColor = dieFaceColor.cgColor
            die6.fillColor = dieFaceColor.cgColor
            dieQ.fillColor = dieFaceColor.cgColor
        }
    }
    
    func setDieFaceColorAnimated(color: UIColor, duration: Double)
    {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.die1.fillColor = color.cgColor
            self.die2.fillColor = color.cgColor
            self.die3.fillColor = color.cgColor
            self.die4.fillColor = color.cgColor
            self.die5.fillColor = color.cgColor
            self.die6.fillColor = color.cgColor
            self.dieQ.fillColor = color.cgColor
        })
        
        let animation = CABasicAnimation(keyPath: "fillColor")
        animation.fromValue = _dieFaceColor.cgColor
        animation.toValue = color.cgColor
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.fillMode = kCAFillModeBoth
        animation.isRemovedOnCompletion = false
        
        die1.add(animation, forKey: "fillColor")
        die2.add(animation, forKey: "fillColor")
        die3.add(animation, forKey: "fillColor")
        die4.add(animation, forKey: "fillColor")
        die5.add(animation, forKey: "fillColor")
        die6.add(animation, forKey: "fillColor")
        dieQ.add(animation, forKey: "fillColor")
        
        _dieFaceColor = color
        CATransaction.commit()
    }
    
    private var _face: UInt = 0
    @IBInspectable var face: UInt
    {
        get { return _face }
        set {
            _face = newValue
            
            if _face < 0
            {
                _face = 1
            }
            else if _face > Die.sides
            {
                _face = Die.sides
            }
            
            if self.layer.sublayers != nil && self.layer.sublayers!.count > 0
            {
                let _ = self.layer.sublayers!.removeLast()
                self.layer.addSublayer(dieForFace(_face))
            }
        }
    }
    
    var die1 = CAShapeLayer()
    var die2 = CAShapeLayer()
    var die3 = CAShapeLayer()
    var die4 = CAShapeLayer()
    var die5 = CAShapeLayer()
    var die6 = CAShapeLayer()
    var dieQ = CAShapeLayer()
    var dieB = CAShapeLayer()
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        initShapeLayers()
        
        self.layer.addSublayer(dieB)
        self.layer.addSublayer(dieForFace(self.face))
    }
    
    required override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        initShapeLayers()
        
        self.layer.addSublayer(dieB)
        self.layer.addSublayer(dieForFace(self.face))
    }
    
    override func layoutSubviews()
    {
        initShapeLayers()
    }
    
    func initDie1(_ radius: CGFloat)
    {
        die1.frame = self.bounds

        die1.path = UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0),
                                        radius: radius * self.bounds.width,
                                        startAngle: 0,
                                        endAngle: CGFloat(M_PI * 2.0),
                                        clockwise: true).cgPath

        die1.fillColor = dieFaceColor.cgColor
    }
    
    func initDie2(_ radius: CGFloat)
    {
        die2.frame = self.bounds

        let die2CG = UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 4.0, y: self.bounds.height * 3.0 / 4.0),
                                         radius: radius * self.bounds.width,
                                         startAngle: 0,
                                         endAngle: CGFloat(M_PI * 2.0),
                                         clockwise: true)
        die2CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width * 3.0 / 4.0, y: self.bounds.height / 4.0),
                                          radius: radius * self.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die2.path = die2CG.cgPath

        die2.fillColor = dieFaceColor.cgColor
    }
    
    func initDie3(_ radius: CGFloat)
    {
        die3.frame = self.bounds

        let die3CG = UIBezierPath.init()
        die3CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 4.0, y: self.bounds.height * 3.0 / 4.0),
                                          radius: radius * self.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die3CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0),
                                          radius: radius * self.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die3CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width * 3.0 / 4.0, y: self.bounds.height / 4.0),
                                          radius: radius * self.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die3.path = die3CG.cgPath
        
        die3.fillColor = dieFaceColor.cgColor
    }
    
    func initDie4(_ radius: CGFloat)
    {
        die4.frame = self.bounds

        let die4CG = UIBezierPath.init()
        die4CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 4.0, y: self.bounds.height / 4.0),
                                          radius: radius * self.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die4CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 4.0, y: self.bounds.height * 3.0 / 4.0),
                                          radius: radius * self.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die4CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width * 3.0 / 4.0, y: self.bounds.height / 4.0),
                                          radius: radius * self.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die4CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width * 3.0 / 4.0, y: self.bounds.height * 3.0 / 4.0),
                                          radius: radius * self.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die4.path = die4CG.cgPath
        
        die4.fillColor = dieFaceColor.cgColor
    }
    
    func initDie5(_ radius: CGFloat)
    {
        die5.frame = self.bounds
        
        let die5CG = UIBezierPath.init()
        die5CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 4.0, y: self.bounds.height / 4.0),
                                          radius: radius * self.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die5CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 4.0, y: self.bounds.height * 3.0 / 4.0),
                                          radius: radius * self.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        
        die5CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0),
                                          radius: radius * self.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        
        die5CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width * 3.0 / 4.0, y: self.bounds.height / 4.0),
                                          radius: radius * self.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die5CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width * 3.0 / 4.0, y: self.bounds.height * 3.0 / 4.0),
                                          radius: radius * self.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die5.path = die5CG.cgPath
        
        die5.fillColor = dieFaceColor.cgColor
    }
    
    func initDie6(_ radius: CGFloat)
    {
        die6.frame = self.bounds

        let die6CG = UIBezierPath.init()
        die6CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 4.0, y: self.bounds.height / 4.0),
                                          radius: radius * self.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die6CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 4.0, y: self.bounds.height * 3.0 / 4.0),
                                          radius: radius * self.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die6CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 4.0, y: self.bounds.height / 2.0),
                                          radius: radius * self.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die6CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width * 3.0 / 4.0, y: self.bounds.height / 2.0),
                                          radius: radius * self.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        
        die6CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width * 3.0 / 4.0, y: self.bounds.height / 4.0),
                                          radius: radius * self.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die6CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width * 3.0 / 4.0, y: self.bounds.height * 3.0 / 4.0),
                                          radius: radius * self.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die6.path = die6CG.cgPath
        
        die6.fillColor = dieFaceColor.cgColor
    }
    
    func initDieQ(_ radius: CGFloat)
    {
        dieQ.frame = self.bounds

        let dieQCG = UIBezierPath.init()
        let font = UIFont.systemFont(ofSize: 10 * radius * self.bounds.width)
        
        var unichars = [UniChar]("?".utf16)
        var glyphs = [CGGlyph](repeating: 0, count: unichars.count)
        let gotGlyphs = CTFontGetGlyphsForCharacters(font, &unichars, &glyphs, unichars.count)
        if gotGlyphs
        {
            let cgpath = CTFontCreatePathForGlyph(font, glyphs[0], nil)!
            let path = UIBezierPath(cgPath: cgpath)
            
            path.apply(CGAffineTransform.init(scaleX: 1.0, y: -1.0))
            path.apply(CGAffineTransform.init(translationX: self.bounds.width / 2.0 - path.bounds.width / 2.0, y: self.bounds.height / 2.0 + path.bounds.height / 2.0))
            
            dieQCG.append(path)
        }
        dieQ.path = dieQCG.cgPath
        
        dieQ.fillColor = dieFaceColor.cgColor
    }
    
    func initShapeLayers()
    {
        let radius: CGFloat = 0.1

        dieB.frame = self.bounds
        let dieBCG = UIBezierPath.init(roundedRect: self.bounds, cornerRadius: radius * self.bounds.width)
        dieB.path = dieBCG.cgPath
        dieB.fillColor = dieBackgroundColor.cgColor

        initDie1(radius)
        initDie2(radius)
        initDie3(radius)
        initDie4(radius)
        initDie5(radius)
        initDie6(radius)
        initDieQ(radius)
    }
    
    func dieForFace(_ face: UInt) -> CAShapeLayer
    {
        switch face
        {
        case 1:
            return die1
        case 2:
            return die2
        case 3:
            return die3
        case 4:
            return die3
        case 5:
            return die5
        case 6:
            return die6
        default:
            return dieQ
        }
    }
}
