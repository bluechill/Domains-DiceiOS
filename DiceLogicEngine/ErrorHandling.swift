//
//  ErrorHandling.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import Rainbow

public enum Handlers
{
    static var Error: (String) -> Void = { _ in }
    static var Warning: (String) -> Void = { _ in }
}

public func error(items: String..., separator: String = " ", terminator: String = "\n")
{
    let errorString = items.joinWithSeparator(separator)
    let string = "Error: " + errorString
    print(string.red, separator: "", terminator: terminator)
    
    Handlers.Error(errorString)
}

public func warning(items: String..., separator: String = " ", terminator: String = "\n")
{
    let warningString = items.joinWithSeparator(separator)
    let string = "Warning: " + warningString
    print(string.blue, separator: "", terminator: terminator)
    
    Handlers.Warning(warningString)
}
