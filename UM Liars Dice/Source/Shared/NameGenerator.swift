//
//  NameGenerator.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/26/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation

class NameGenerator
{
    static let names = ["Alice", "Bob", "Carol", "Decker", "Erin", "Maize", "Rosie", "Sarah", "Thomas", "Watson", "Athena", "Blue", "Carter", "Nyx", "Ellie", "Floyd", "Jane", "Kirk", "Hemera", "Ares", "Zeus", "Hades", "Hera", "Erebus", "Sol", "Vesta", "Ceres", "Scylla", "Vox", "Aura", "Angela", "Jarvis", "Auto", "The Bard"]
    
    static func generateNamesFor(_ numberOfPlayers: Int) -> [String]
    {
        var set = Set<String>()
        
        while set.count < numberOfPlayers
        {
            guard let sample = names.sample else {
                return []
            }
            
            set.insert(sample)
        }
        
        return Array(set)
    }
}
