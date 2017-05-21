//
//  DiceLogicEngine.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/15/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import Foundation
import MessagePack

public protocol DiceObserver
{
    func diceLogicActionOccurred(_ engine: DiceLogicEngine)
    func diceLogicRoundWillEnd(_ engine: DiceLogicEngine)
}

public class DiceLogicEngine: NSObject
{
    public internal(set) var players = [Player]()
    public internal(set) var history = [[HistoryItem]]()

    public var observers = [DiceObserver]()
    public var userData = [String:AnyObject]()

    public internal(set) var currentTurn: Player?

    public init(players: [String], start: Bool = true)
    {
        super.init()

        self.players = players.map{ Player(
            name: $0,
            dice: [Die(), Die(), Die(), Die(), Die()],
            engine: self)
        }

        if start
        {
            shuffleAndCreateRound()
        }
    }

    public func shuffleAndCreateRound()
    {
        self.players.shuffleInPlace()
        self.currentTurn = self.players[0]

        createNewRound()
    }

    func currentPlayerDiceCalculatedViaHistory(_ name: String) -> [Die]
    {
        let currentRound = self.currentRoundHistory

        guard currentRound.count > 0 else {
            ErrorHandling.error("No history to extract player dice from")
            return []
        }

        guard let initialState = currentRound.first as? InitialState else {
            ErrorHandling.error("Invalid formatted history")
            return []
        }

        guard let player = initialState.players[name] else {
            ErrorHandling.error("Corrupted Player Data for player \(name)")
            return []
        }

        var dice = player.map{ Die(face: $0) }

        for index in (0..<currentRound.count).reversed()
        {
            let item = currentRound[index]

            guard (item as? PushAction) != nil || (item as? PlayerLost) != nil else {
                continue
            }

            let action2 = item as? PushAction
            let lost = item as? PlayerLost

            if lost != nil && lost?.player == name
            {
                dice.removeAll()
                break
            }

            guard let action = action2 else {
                continue
            }

            guard action.player == name else {
                continue
            }

            dice.removeAll()
            dice.append(contentsOf: action.pushedDice.map{ Die(face: UInt($0), pushed: true) })
            dice.append(contentsOf: action.newDice.map{ Die(face: UInt($0)) })

            break
        }

        return dice
    }

    required public init?(data: Foundation.Data)
    {
        super.init()

        guard updateWithData(data) else {
            return nil
        }
    }

    internal init?(data: MessagePackValue)
    {
        super.init()

        guard updateWithData(data) else {
            return nil
        }
    }
}

// MARK: Dice Logic Engine Getters
public extension DiceLogicEngine
{
    public var currentRoundHistory: [HistoryItem]
    {
        get
        {
            guard let currentRound = history.last else {
                ErrorHandling.error("No current round, returning empty array")
                return []
            }

            return currentRound
        }
    }

    public var lastBid: BidAction?
    {
        get
        {
            for index in (0..<currentRoundHistory.count).reversed()
            {
                let item = currentRoundHistory[index]

                if let bid = (item as? BidAction)
                {
                    return bid
                }
            }

            return nil
        }
    }

    public var lastAction: HistoryAction?
    {
        get
        {
            for index in (0..<currentRoundHistory.count).reversed()
            {
                let item = currentRoundHistory[index]

                if let action = (item as? HistoryAction)
                {
                    return action
                }
            }

            return nil
        }
    }

    public var isSpecialRules: Bool
    {
        get
        {
            for index in 0..<currentRoundHistory.count
            {
                let item = currentRoundHistory[index]

                if (item as? SpecialRulesInEffect) != nil
                {
                    return true
                }
            }

            return false
        }
    }

    public var playersLeft: [Player]
    {
        get
        {
            return players.filter{ $0.dice.count > 0 }
        }
    }

    public var winner: Player?
    {
        get
        {
            let playersLeft = self.playersLeft

            guard playersLeft.count == 1 else {
                return nil
            }

            return playersLeft.first!
        }
    }
}

// MARK: Data Serialization
public extension DiceLogicEngine
{
    public func updateWithData(_ nsdata: Foundation.Data) -> Bool
    {
        var data: MessagePackValue = nil

        do
        {
            let pair = try unpack(nsdata)
            data = pair.value
        }
        catch
        {
            ErrorHandling.error("No data to update with")
            return false
        }

        return updateWithData(data)
    }

    private func updateHistory(_ history: [MessagePackValue], _ players: [MessagePackValue]) -> Bool
    {
        for item in history
        {
            guard let item = item.arrayValue else {
                ErrorHandling.error("DiceLogicEngine sub-array data is not an array")
                return false
            }

            guard item.count > 0 else {
                ErrorHandling.error("Empty DiceLogicEngine sub-array data")
                return false
            }

            var round = [HistoryItem]()

            for hItem in item
            {
                guard let newItem = HistoryItem.makeHistoryItem(hItem) else {
                    return false
                }

                round.append(newItem)
            }

            self.history.append(round)
        }

        for player in players
        {
            guard let player = player.stringValue else {
                ErrorHandling.error("Player in players array is not a player name")
                return false
            }

            self.players.append(Player( name: player,
                                        dice: currentPlayerDiceCalculatedViaHistory(player),
                                        engine: self))
        }

        return true
    }

    private func updatePlayers(_ playerUserData: [MessagePackValue], _ currentTurn: String) -> Bool
    {
        guard players.count == playerUserData.count else {
            ErrorHandling.error("Player User Data and Players Array are not the same size!")
            return false
        }

        for index in 0..<playerUserData.count
        {
            guard let data = playerUserData[index].dictionaryValue else {
                ErrorHandling.error("Data in player userData array is not a dictionary of data")
                return false
            }

            for (key, value) in data
            {
                guard let stringKey = key.stringValue else {
                    ErrorHandling.error("Key is not a string!")
                    return false
                }

                if stringKey == "AI"
                {
                    guard let boolValue = value.boolValue else {
                        ErrorHandling.error("AI Value is not a bool!")
                        return false
                    }

                    self.players[index].userData[stringKey] = boolValue
                }
                else if stringKey == "GCID"
                {
                    guard let stringValue = value.stringValue else {
                        ErrorHandling.error("GCID Key is not a string!")
                        return false
                    }

                    self.players[index].userData[stringKey] = stringValue
                }
                else
                {
                    ErrorHandling.error("Unknown key found in user data.  " +
                                        "Are you sure this data is for this " +
                                        "version of Liar's Dice?")
                    return false
                }
            }
        }

        guard let currentPlayer = self.player(currentTurn) else {
            ErrorHandling.error("Cannot find player whose turn it is")
            return false
        }

        self.currentTurn = currentPlayer

        return true
    }

    internal func updateWithData(_ data: MessagePackValue) -> Bool
    {
        self.history.removeAll()
        self.players.removeAll()

        guard let array = data.arrayValue else {
            ErrorHandling.error("DiceLogicEngine data is not an array")
            return false
        }

        guard array.count == 4 else {
            ErrorHandling.error("Invalid DiceLogicEngine data array")
            return false
        }

        guard let players = array[0].arrayValue else {
            ErrorHandling.error("No players array in DiceLogicEngine data")
            return false
        }

        guard let playerUserData = array[1].arrayValue else {
            ErrorHandling.error("No players userData in DiceLogicEngine data")
            return false
        }

        guard let currentTurn = array[2].stringValue else {
            ErrorHandling.error("No currentTurn string in DiceLogicEngine data")
            return false
        }

        guard let history = array[3].arrayValue else {
            ErrorHandling.error("No history array in DiceLogicEngine data")
            return false
        }

        guard updateHistory(history, players) else {
            return false
        }

        guard updatePlayers(playerUserData, currentTurn) else {
            return false
        }

        observers.forEach({ $0.diceLogicActionOccurred(self) })

        return true
    }

    public func asData() -> Foundation.Data
    {
        let playersMap: [MessagePackValue] = self.players.map{ .string($0.name) }
        let playerUserDataMap: [MessagePackValue] = self.players.map{ .map($0.userDataAsMsgPack()) }

        let historyMap: [MessagePackValue] = self.history.map{ .array($0.map{ $0.asData() }) }

        let value = MessagePackValue.array([.array(playersMap),
                                            .array(playerUserDataMap),
                                            .string(currentTurn!.name),
                                            .array(historyMap)])

        let data = pack(value)
        let ptr = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        data.copyBytes(to: ptr, count: data.count)
        let result = Foundation.Data(bytes: ptr, count: data.count)
        ptr.deallocate(capacity: data.count)
        return result
    }
}

internal extension DiceLogicEngine
{
    func player(_ name: String) -> Player?
    {
        let array = players.filter{ $0.name == name }

        guard array.count > 0 else {
            ErrorHandling.error("No player with name '\(name)'")
            return nil
        }
        guard array.count == 1 else {
            ErrorHandling.error("More than one player with the same name '\(name)'")
            return nil
        }

        return array.first!
    }

    func hasPlayerBeenInSpecialRulesBefore(_ player: String) -> Bool
    {
        for round in history.reversed()
        {
            for item in round.reversed()
            {
                if  let item = (item as? SpecialRulesInEffect),
                    item.player == player
                {
                    return true
                }
            }
        }

        return false
    }

    func appendHistoryItem(_ item: HistoryItem)
    {
        let currentRoundIndex = history.count-1
        history[currentRoundIndex].append(item)
    }

    func createNewRound()
    {
        var playerWhoLostRound: String? = nil

        if let round = history.last
        {
            var lostItem = (round.last as? PlayerLostRound)

            if lostItem == nil
            {
                for item in round.reversed()
                {
                    if let item = (item as? PlayerLostRound)
                    {
                        lostItem = item
                        break
                    }
                }
            }

            if let item = lostItem
            {
                playerWhoLostRound = item.player
            }
        }

        history.append([])

        for player in players
        {
            for die in player.dice
            {
                die.roll()
            }
        }

        var playerStringUInts = [String:[UInt]]()
        for player in players
        {
            playerStringUInts[player.name] = player.dice.map{ $0.face }
        }

        appendHistoryItem(InitialState(players: playerStringUInts))

        if let playerWhoLostRound = playerWhoLostRound
        {
            guard let player = self.player(playerWhoLostRound) else {
                ErrorHandling.error("Invalid player who lost the round.")
                return
            }

            if player.dice.count == 1 && !hasPlayerBeenInSpecialRulesBefore(player.name) && playersLeft.count > 2
            {
                appendHistoryItem(SpecialRulesInEffect(player: playerWhoLostRound))
            }
        }

        observers.forEach({ $0.diceLogicActionOccurred(self) })
    }

    func playerLosesRound(_ player: String)
    {
        guard self.winner == nil else {
            ErrorHandling.error("Cannot lose round when the game is over")
            return
        }

        guard let player = self.player(player) else {
            ErrorHandling.error("Invalid player lost the round")
            return
        }

        guard player.dice.count > 0 else {
            ErrorHandling.error("Player cannot lose the round when they already have zero dice.")
            return
        }

        observers.forEach({ $0.diceLogicRoundWillEnd(self) })

        appendHistoryItem(PlayerLostRound(player: player.name))

        player.dice.removeLast()
        self.currentTurn = self.player(player.name)

        if player.dice.count == 0
        {
            advancePlayer()

            appendHistoryItem(PlayerLost(player: player.name))

            let playersLeft = self.playersLeft
            if playersLeft.count == 1
            {
                appendHistoryItem(PlayerWon(player: playersLeft.first!.name))
                return
            }
        }

        createNewRound()
    }

    func countDice(_ face: UInt) -> UInt
    {
        var count: UInt = 0

        for player in self.players
        {
            for die in player.dice
            {
                if die.face == face || (!isSpecialRules && die.face == 1)
                {
                    count += 1
                }
            }
        }

        return count
    }

    func advancePlayer()
    {
        let index = players.index(where: { $0.name == self.currentTurn?.name})!
        var newIndex = index.advanced(by: 1)

        if newIndex >= players.count
        {
            newIndex = 0
        }

        var nextPlayers = players[newIndex..<players.count]
        nextPlayers.append(contentsOf: players[0..<index])

        for player in nextPlayers
        {
            if !player.hasLost
            {
                self.currentTurn = player
                observers.forEach({ $0.diceLogicActionOccurred(self) })
                return
            }
        }
    }

    func printState()
    {
        for player in players
        {
            print("\(player.name): ", terminator: "")

            for die in player.dice
            {
                print(" \(die.face)\(die.pushed ? "*" : "")", terminator: "")
            }

            print("")
        }
    }
}

// Equality
public extension DiceLogicEngine
{
    override public func isEqual(_ object: Any?) -> Bool {
        if (object is DiceLogicEngine)
        {
            let lhs = self;
            let rhs = (object as! DiceLogicEngine);

            // Player == will fail for two different engines, special case it since it
            //  will definitely fail here
            for (p1, p2) in zip(lhs.players, rhs.players)
            {
                if p1.name != p2.name || p1.dice != p2.dice
                {
                    return false
                }
            }

            let lhsCTName = lhs.currentTurn?.name
            let rhsCTName = rhs.currentTurn?.name
            
            return lhs.history == rhs.history && lhsCTName == rhsCTName
        }

        return false;
    }
}

public func == (lhs: DiceLogicEngine, rhs: DiceLogicEngine) -> Bool
{
    return lhs.isEqual(rhs);
}

public func == (lhs: [[HistoryItem]], rhs: [[HistoryItem]]) -> Bool
{
    guard lhs.count == rhs.count else {
        return false
    }

    for (r1, r2) in zip(lhs, rhs)
    {
        guard r1.count == r2.count else {
            return false
        }

        for (item1, item2) in zip(r1, r2)
        {
            guard item1 == item2 else {
                return false
            }
        }
    }

    return true
}
