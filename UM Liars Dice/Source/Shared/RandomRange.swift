//
//  RandomRange.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/26/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import DiceLogicEngine

// From & Modified http://stackoverflow.com/questions/24003191/pick-a-random-element-from-an-array

func sizeof <T> (_: () -> T) -> Int { // sizeof return type without calling
    return MemoryLayout<T>.size
}

let ARC4Foot: Int = sizeof(arc4random)

extension UnsignedInteger {
    static var max: Self { // sadly `max` is not required by the protocol
        return ~0
    }
    static var random: Self {
        let foot = MemoryLayout<Self>.size
        guard foot > ARC4Foot else {
            return numericCast(arc4random() & numericCast(max))
        }
        var r = UIntMax(arc4random())
        for i in 1..<(foot / ARC4Foot) {
            r |= UIntMax(arc4random()) << UIntMax(8 * ARC4Foot * i)
        }
        return numericCast(r)
    }
}

extension ClosedRange where Bound : UnsignedInteger {
    var random: Bound {
        guard lowerBound > 0 || upperBound < Bound.max else { return Bound.random }
        return lowerBound + (Bound.random % (upperBound - lowerBound + 1))
    }
}

extension ClosedRange where Bound : SignedInteger {
    var random: Bound {
        let foot = MemoryLayout<Bound>.size
        let distance = lowerBound.unsignedDistanceTo(upperBound)
        guard foot > 4 else { // optimisation: use UInt32.random if sufficient
            let off: UInt32
            if distance < numericCast(UInt32.max) {
                off = UInt32.random % numericCast(distance + 1)
            } else {
                off = UInt32.random
            }
            return numericCast(lowerBound.toIntMax() + numericCast(off))
        }
        guard distance < UIntMax.max else {
            return numericCast(IntMax(bitPattern: UIntMax.random))
        }
        let off = UIntMax.random % (distance + 1)
        let x = (off + lowerBound.unsignedDistanceFromMin).plusMinIntMax
        return numericCast(x)
    }
}

extension SignedInteger {
    func unsignedDistanceTo(_ other: Self) -> UIntMax {
        let _self = self.toIntMax()
        let other = other.toIntMax()
        let (start, end) = _self < other ? (_self, other) : (other, _self)
        if start == IntMax.min && end == IntMax.max {
            return UIntMax.max
        }
        if start < 0 && end >= 0 {
            let s = start == IntMax.min ? UIntMax(Int.max) + 1 : UIntMax(-start)
            return s + UIntMax(end)
        }
        return UIntMax(end - start)
    }
    var unsignedDistanceFromMin: UIntMax {
        return IntMax.min.unsignedDistanceTo(self.toIntMax())
    }
}

extension UIntMax {
    var plusMinIntMax: IntMax {
        if self > UIntMax(IntMax.max) { return IntMax(self - UIntMax(IntMax.max) - 1) }
        else { return IntMax.min + IntMax(self) }
    }
}

extension Collection where IndexDistance == Int {
    var sample: Iterator.Element? {
        if isEmpty { return nil }
        let end = UInt(count) - 1
        let add = (0...end).random
        let idx = index(startIndex, offsetBy: Int(add))
        return self[idx]
    }
}
