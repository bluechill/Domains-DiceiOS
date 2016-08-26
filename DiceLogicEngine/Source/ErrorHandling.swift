//
//  ErrorHandling.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation

public enum Handlers
{
    static var Error: (String) -> Void = { _ in }
    static var Warning: (String) -> Void = { _ in }
}

public class ErrorHandling
{
    public static func error(   _ items: String...,
                                separator: String = " ",
                                terminator: String = "\n")
    {
        let errorString = items.joined(separator: separator)
        let string = "Error: " + errorString
        print(string, separator: "", terminator: terminator)

        Handlers.Error(errorString)
    }

    public static func warning( _ items: String...,
                                separator: String = " ",
                                terminator: String = "\n")
    {
        let warningString = items.joined(separator: separator)
        let string = "Warning: " + warningString
        print(string, separator: "", terminator: terminator)

        Handlers.Warning(warningString)
    }
}
