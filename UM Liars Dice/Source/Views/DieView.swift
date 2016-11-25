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
    static let DefaultBackgroundColor = UIColor.white
    static let DefaultFaceColor = UIColor.black

    var _dieBackgroundColor = DieView.DefaultBackgroundColor
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

    var _dieFaceColor = DieView.DefaultFaceColor
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
                dieB = DieView.DieB(DieView.Radius, self.bounds)
                self.layer.replaceSublayer(self.layer.sublayers![self.layer.sublayers!.count-2], with: dieB)
                self.layer.replaceSublayer(self.layer.sublayers!.last!, with: DieView.DieForFace(_face, self.bounds))
                (self.layer.sublayers!.last! as? CAShapeLayer)!.fillColor = dieFaceColor.cgColor
            }
        }
    }

    var dieB = CAShapeLayer()

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)

        initShapeLayers()

        self.layer.addSublayer(dieB)
        self.layer.addSublayer(DieView.DieForFace(self.face, self.bounds))
        (self.layer.sublayers!.last! as? CAShapeLayer)!.fillColor = dieFaceColor.cgColor
    }

    required override init(frame: CGRect)
    {
        super.init(frame: frame)

        initShapeLayers()

        self.layer.addSublayer(dieB)
        self.layer.addSublayer(DieView.DieForFace(self.face, self.bounds))
        (self.layer.sublayers!.last! as? CAShapeLayer)!.fillColor = dieFaceColor.cgColor
    }

    override func layoutSubviews()
    {
        initShapeLayers()

        self.face = _face
    }

    static func Die1(_ radius: CGFloat, _ bounds: CGRect) -> CAShapeLayer
    {
        let die = CAShapeLayer()

        die.frame = bounds

        die.path = UIBezierPath.init(  arcCenter: CGPoint(x: die.bounds.width / 2.0, y: die.bounds.height / 2.0),
                                        radius: radius * die.bounds.width,
                                        startAngle: 0,
                                        endAngle: CGFloat(M_PI * 2.0),
                                        clockwise: true).cgPath

        return die
    }

    static func Die2(_ radius: CGFloat, _ bounds: CGRect) -> CAShapeLayer
    {
        let die = CAShapeLayer()

        die.frame = bounds

        let die2CG = UIBezierPath.init(  arcCenter: CGPoint(x: die.bounds.width / 4.0, y: die.bounds.height * 3.0 / 4.0),
                                         radius: radius * die.bounds.width,
                                         startAngle: 0,
                                         endAngle: CGFloat(M_PI * 2.0),
                                         clockwise: true)
        die2CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: die.bounds.width * 3.0 / 4.0, y: die.bounds.height / 4.0),
                                          radius: radius * die.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die.path = die2CG.cgPath

        return die
    }

    static func Die3(_ radius: CGFloat, _ bounds: CGRect) -> CAShapeLayer
    {
        let die = CAShapeLayer()

        die.frame = bounds

        let die3CG = UIBezierPath.init()
        die3CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: die.bounds.width / 4.0, y: die.bounds.height * 3.0 / 4.0),
                                          radius: radius * die.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die3CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: die.bounds.width / 2.0, y: die.bounds.height / 2.0),
                                          radius: radius * die.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die3CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: die.bounds.width * 3.0 / 4.0, y: die.bounds.height / 4.0),
                                          radius: radius * die.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die.path = die3CG.cgPath

        return die
    }

    static func Die4(_ radius: CGFloat, _ bounds: CGRect) -> CAShapeLayer
    {
        let die = CAShapeLayer()

        die.frame = bounds

        let die4CG = UIBezierPath.init()
        die4CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: die.bounds.width / 4.0, y: die.bounds.height / 4.0),
                                          radius: radius * die.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die4CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: die.bounds.width / 4.0, y: die.bounds.height * 3.0 / 4.0),
                                          radius: radius * die.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die4CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: die.bounds.width * 3.0 / 4.0, y: die.bounds.height / 4.0),
                                          radius: radius * die.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die4CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: die.bounds.width * 3.0 / 4.0, y: die.bounds.height * 3.0 / 4.0),
                                          radius: radius * die.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die.path = die4CG.cgPath

        return die
    }

    static func Die5(_ radius: CGFloat, _ bounds: CGRect) -> CAShapeLayer
    {
        let die = CAShapeLayer()

        die.frame = bounds

        let die5CG = UIBezierPath.init()
        die5CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: die.bounds.width / 4.0, y: die.bounds.height / 4.0),
                                          radius: radius * die.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die5CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: die.bounds.width / 4.0, y: die.bounds.height * 3.0 / 4.0),
                                          radius: radius * die.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))

        die5CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: die.bounds.width / 2.0, y: die.bounds.height / 2.0),
                                          radius: radius * die.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))

        die5CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: die.bounds.width * 3.0 / 4.0, y: die.bounds.height / 4.0),
                                          radius: radius * die.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die5CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: die.bounds.width * 3.0 / 4.0, y: die.bounds.height * 3.0 / 4.0),
                                          radius: radius * die.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die.path = die5CG.cgPath

        return die
    }

    static func Die6(_ radius: CGFloat, _ bounds: CGRect) -> CAShapeLayer
    {
        let die = CAShapeLayer()

        die.frame = bounds

        let die6CG = UIBezierPath.init()
        die6CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: die.bounds.width / 4.0, y: die.bounds.height / 4.0),
                                          radius: radius * die.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die6CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: die.bounds.width / 4.0, y: die.bounds.height * 3.0 / 4.0),
                                          radius: radius * die.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die6CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: die.bounds.width / 4.0, y: die.bounds.height / 2.0),
                                          radius: radius * die.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die6CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: die.bounds.width * 3.0 / 4.0, y: die.bounds.height / 2.0),
                                          radius: radius * die.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))

        die6CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: die.bounds.width * 3.0 / 4.0, y: die.bounds.height / 4.0),
                                          radius: radius * die.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die6CG.append(UIBezierPath.init(  arcCenter: CGPoint(x: die.bounds.width * 3.0 / 4.0, y: die.bounds.height * 3.0 / 4.0),
                                          radius: radius * die.bounds.width,
                                          startAngle: 0,
                                          endAngle: CGFloat(M_PI * 2.0),
                                          clockwise: true))
        die.path = die6CG.cgPath

        return die
    }

    static func DieQ(_ radius: CGFloat, _ bounds: CGRect) -> CAShapeLayer
    {
        let die = CAShapeLayer()

        die.frame = bounds

        let dieQCG = UIBezierPath.init()
        let font = UIFont.systemFont(ofSize: 10 * radius * die.bounds.width)

        var unichars = [UniChar]("?".utf16)
        var glyphs = [CGGlyph](repeating: 0, count: unichars.count)
        let gotGlyphs = CTFontGetGlyphsForCharacters(font, &unichars, &glyphs, unichars.count)
        if gotGlyphs
        {
            let cgpath = CTFontCreatePathForGlyph(font, glyphs[0], nil)!
            let path = UIBezierPath(cgPath: cgpath)

            path.apply(CGAffineTransform.init(scaleX: 1.0, y: -1.0))
            path.apply(CGAffineTransform.init(translationX: die.bounds.width / 2.0 - path.bounds.width / 2.0, y: die.bounds.height / 2.0 + path.bounds.height / 2.0))

            dieQCG.append(path)
        }

        die.path = dieQCG.cgPath
        return die
    }

    static func DieB(_ radius: CGFloat, _ bounds: CGRect) -> CAShapeLayer
    {
        let die = CAShapeLayer()

        die.frame = bounds
        die.path = UIBezierPath.init(roundedRect: bounds, cornerRadius: radius * bounds.width).cgPath
        die.fillColor = UIColor.white.cgColor

        return die
    }

    static let Radius: CGFloat = 0.1
    func initShapeLayers()
    {
        dieB = DieView.DieB(DieView.Radius, self.bounds)
        dieB.fillColor = dieBackgroundColor.cgColor
    }

    static func DieForFace(_ face: UInt, _ bounds: CGRect) -> CAShapeLayer
    {
        switch face
        {
        case 1:
            return Die1(DieView.Radius,bounds)
        case 2:
            return Die2(DieView.Radius,bounds)
        case 3:
            return Die3(DieView.Radius,bounds)
        case 4:
            return Die4(DieView.Radius,bounds)
        case 5:
            return Die5(DieView.Radius,bounds)
        case 6:
            return Die6(DieView.Radius,bounds)
        default:
            return DieQ(DieView.Radius,bounds)
        }
    }
}
