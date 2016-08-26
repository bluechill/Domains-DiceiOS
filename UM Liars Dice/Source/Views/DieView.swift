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

            if self.layer.sublayers != nil && self.layer.sublayers!.count > 0
            {
                (self.layer.sublayers!.last! as! CAShapeLayer).fillColor = dieFaceColor.cgColor
            }
        }
    }

    func setDieFaceColorAnimated(color: UIColor, duration: Double)
    {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            if self.layer.sublayers != nil && self.layer.sublayers!.count > 0
            {
                (self.layer.sublayers!.last! as! CAShapeLayer).fillColor = color.cgColor
            }
        })

        let animation = CABasicAnimation(keyPath: "fillColor")
        animation.fromValue = _dieFaceColor.cgColor
        animation.toValue = color.cgColor
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.fillMode = kCAFillModeBoth
        animation.isRemovedOnCompletion = false

        if self.layer.sublayers != nil && self.layer.sublayers!.count > 0
        {
            self.layer.sublayers!.last!.add(animation, forKey: "fillColor")
        }

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

        self.face = _face
    }

    func Die1(_ radius: CGFloat) -> CAShapeLayer
    {
        let die = CAShapeLayer()

        die.frame = self.bounds

        die.path = UIBezierPath.init(  arcCenter: CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0),
                                        radius: radius * self.bounds.width,
                                        startAngle: 0,
                                        endAngle: CGFloat(M_PI * 2.0),
                                        clockwise: true).cgPath

        die.fillColor = dieFaceColor.cgColor

        return die
    }

    func Die2(_ radius: CGFloat) -> CAShapeLayer
    {
        let die = CAShapeLayer()

        die.frame = self.bounds

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
        die.path = die2CG.cgPath

        die.fillColor = dieFaceColor.cgColor

        return die
    }

    func Die3(_ radius: CGFloat) -> CAShapeLayer
    {
        let die = CAShapeLayer()

        die.frame = self.bounds

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
        die.path = die3CG.cgPath

        die.fillColor = dieFaceColor.cgColor

        return die
    }

    func Die4(_ radius: CGFloat) -> CAShapeLayer
    {
        let die = CAShapeLayer()

        die.frame = self.bounds

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
        die.path = die4CG.cgPath

        die.fillColor = dieFaceColor.cgColor

        return die
    }

    func Die5(_ radius: CGFloat) -> CAShapeLayer
    {
        let die = CAShapeLayer()

        die.frame = self.bounds

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
        die.path = die5CG.cgPath

        die.fillColor = dieFaceColor.cgColor

        return die
    }

    func Die6(_ radius: CGFloat) -> CAShapeLayer
    {
        let die = CAShapeLayer()

        die.frame = self.bounds

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
        die.path = die6CG.cgPath

        die.fillColor = dieFaceColor.cgColor

        return die
    }

    func DieQ(_ radius: CGFloat) -> CAShapeLayer
    {
        let die = CAShapeLayer()

        die.frame = self.bounds

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

        die.path = dieQCG.cgPath
        die.fillColor = dieFaceColor.cgColor

        return die
    }

    static let Radius: CGFloat = 0.1
    func initShapeLayers()
    {
        dieB.frame = self.bounds
        let dieBCG = UIBezierPath.init(roundedRect: self.bounds, cornerRadius: DieView.Radius * self.bounds.width)
        dieB.path = dieBCG.cgPath
        dieB.fillColor = dieBackgroundColor.cgColor
    }

    func dieForFace(_ face: UInt) -> CAShapeLayer
    {
        switch face
        {
        case 1:
            return Die1(DieView.Radius)
        case 2:
            return Die2(DieView.Radius)
        case 3:
            return Die3(DieView.Radius)
        case 4:
            return Die4(DieView.Radius)
        case 5:
            return Die5(DieView.Radius)
        case 6:
            return Die6(DieView.Radius)
        default:
            return DieQ(DieView.Radius)
        }
    }
}
