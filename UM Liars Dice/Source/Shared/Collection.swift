//
//  Collection.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 8/30/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation

import Foundation

protocol Addable {
    static func +(lhs: Self, rhs: Self) -> Self
    init(_: Int)
    init()
}

extension Int : Addable {}
extension Int8 : Addable {}
extension Int16 : Addable {}
extension Int32 : Addable {}
extension Int64 : Addable {}

extension UInt : Addable {}
extension UInt8 : Addable {}
extension UInt16 : Addable {}
extension UInt32 : Addable {}
extension UInt64 : Addable {}

extension Double : Addable {}
extension Float : Addable {}

extension Collection
{
    func sum<T : Addable>(min: T = T(0)) -> T {
        return map { $0 as! T }.reduce(min) { $0 + $1 }
    }
}
