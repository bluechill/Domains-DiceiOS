//
//  GameKitGameHandler.m
//  UM Liars Dice
//
//  Created by Alex Turner on 5/8/14.
//
//

#import "GameKitGameHandler.h"
#import "SoarPlayer.h"
#import "MultiplayerMatchData.h"
#import "PlayGameView.h"
#import "ApplicationDelegate.h"

@implementation GameKitGameHandler

@synthesize localPlayer, remotePlayers, match, participants, localGame;

- (id)initWithDiceGame:(DiceGame*)lGame withLocalPlayer:(DiceLocalPlayer*)lPlayer withRemotePlayers:(NSArray*)rPlayers withMatch:(GKTurnBasedMatch *)gkMatch
{
	self = [super init];

	if (self)
	{
		self.localGame = lGame;
		self.localPlayer = lPlayer;
		self.remotePlayers = rPlayers;
		matchHasEnded = NO;
		match = gkMatch;

		participants = [match participants];
	}

	return self;
}

- (void) saveMatchData
{
	if (matchHasEnded || ![[[match currentParticipant] player].playerID isEqualToString:[[GKLocalPlayer localPlayer] playerID]])
		return;

	NSData* updatedMatchData = [NSKeyedArchiver archivedDataWithRootObject:localGame];

	ApplicationDelegate* delegate = [UIApplication sharedApplication].delegate;
	DDLogGameKit(@"Updated Match Data SHA1 Hash: %@", [delegate sha1HashFromData:updatedMatchData]);

	[match saveCurrentTurnWithMatchData:updatedMatchData completionHandler:^(NSError* error)
	{
		DDLogGameKit(@"Sent match data!");

		if (error)
			DDLogError(@"Error upon saving match data: %@\n", error.description);
	}];
}

- (void) updateMatchData
{
	if (matchHasEnded)
		return;

	if (!self.remotePlayers)
	{
		NSMutableArray* remotes = [[NSMutableArray alloc] init];
		for (DiceRemotePlayer* player in self.localGame.players)
		{
			if ([player isKindOfClass:DiceRemotePlayer.class])
				[remotes addObject:player];
		}

		self.remotePlayers = remotes;
	}

	[match loadMatchDataWithCompletionHandler:^(NSData* matchData, NSError* error)
	 {
		 if (!error)
		 {
			 for (int i = 0;i < [self->match.participants count];++i)
			 {
				 GKTurnBasedParticipant* p = [self->match.participants objectAtIndex:i];
				 NSString* oldPlayerID = ((GKTurnBasedParticipant*)[self->participants objectAtIndex:i]).player.playerID;
				 NSString* newPlayerID = p.player.playerID;

				 if ((oldPlayerID == nil && newPlayerID != nil) ||
					 ![oldPlayerID isEqualToString:newPlayerID])
				 {
					 NSMutableArray* array = [NSMutableArray arrayWithArray:self->participants];

					 [array replaceObjectAtIndex:i withObject:p];

					 self->participants = array;

					 for (DiceRemotePlayer* remote in self->remotePlayers)
					 {
						 NSString* remotePlayerID = [remote getGameCenterName];
						 if ((remotePlayerID == nil && oldPlayerID == nil) ||
							 [remotePlayerID isEqualToString:oldPlayerID])
						 {
							 [remote setParticipant:p];
							 break;
						 }
					 }
				 }
			 }

			 ApplicationDelegate* delegate = [UIApplication sharedApplication].delegate;
			 DDLogGameKit(@"Updated Match Data Retrieved SHA1 Hash: %@", [delegate sha1HashFromData:matchData]);

			 DiceGame* updatedGame = [NSKeyedUnarchiver unarchiveObjectWithData:matchData];

			 [updatedGame.gameState decodePlayers:self->match withHandler:self];

			 if (updatedGame.gameState.players &&
				 [updatedGame.gameState.players count] > 0)
				 updatedGame.players = [NSArray arrayWithArray:updatedGame.gameState.players];

			 updatedGame.gameState.players = updatedGame.players;

			 [self->localGame updateGame:updatedGame];
		 }
		 else
			 DDLogError(@"Error upon loading match data: %@\n", error.description);
	 }];
}

- (void) matchHasEnded
{
	matchHasEnded = YES;

	[localGame end];
}

- (void) advanceToRemotePlayer:(DiceRemotePlayer*)player
{
	if (matchHasEnded)
		return;

	NSData* updatedMatchData = [NSKeyedArchiver archivedDataWithRootObject:localGame];

	ApplicationDelegate* delegate = [UIApplication sharedApplication].delegate;
	DDLogGameKit(@"Updated Match Data SHA1 Hash: %@", [delegate sha1HashFromData:updatedMatchData]);

	NSMutableArray* nextPlayers = [NSMutableArray arrayWithArray:participants];

	for (int i = 0;i < nextPlayers.count;++i)
	{
		GKTurnBasedParticipant* p = [nextPlayers objectAtIndex:i];
		if (!p.player.playerID || [p.player.playerID isEqualToString:[player getGameCenterName]])
		{
			[nextPlayers removeObjectAtIndex:i];
			[nextPlayers insertObject:p atIndex:0];
			break;
		}
	}

	for (GKTurnBasedParticipant* p in nextPlayers)
	{
		NSString* gID = p.player.playerID;

		for (PlayerState* state in localGame.gameState.playerStates)
		{
			BOOL equal = [[[state playerPtr] getGameCenterName] isEqualToString:gID];

			if (!equal)
				continue;

			if ([state hasLost])
				p.matchOutcome = GKTurnBasedMatchOutcomeLost;
			else if ([state hasWon])
				p.matchOutcome = GKTurnBasedMatchOutcomeWon;
			else
				p.matchOutcome = GKTurnBasedMatchOutcomeNone;

			break;
		}
	}

	DDLogDebug(@"Next Players: %@", nextPlayers);

	[match endTurnWithNextParticipants:nextPlayers turnTimeout:GKTurnTimeoutDefault matchData:updatedMatchData completionHandler:^(NSError* error)
	 {
		 if (error)
			 DDLogError(@"Error advancing to next player: %@\n", error.description);
	 }];
}

- (GKTurnBasedParticipant*)myParticipant
{
	for (GKTurnBasedParticipant* participant in [match participants])
	{
		if ([participant player].playerID == [[GKLocalPlayer localPlayer] playerID])
			return participant;
	}

	return nil;
}

- (void) playerQuitMatch:(id<Player>)player withRemoval:(BOOL)remove
{
	if (matchHasEnded)
		return;

	if ([player isKindOfClass:SoarPlayer.class])
		[self saveMatchData];
	else if ([player isKindOfClass:DiceLocalPlayer.class])
	{
		NSMutableArray* localParticipants = [[NSMutableArray alloc] init];

		for (GKTurnBasedParticipant* participant in [match participants])
		{
			if (participant != [self myParticipant])
				[localParticipants addObject:participant];
		}

		GKTurnBasedMatchOutcome outcome;

		PlayerState* state = [[localGame gameState] getPlayerState:[player getID]];

		if ([state hasLost])
			outcome = GKTurnBasedMatchOutcomeLost;
		else
			outcome = GKTurnBasedMatchOutcomeQuit;

		void (^completionHandler)(NSError* error) = ^(NSError* error){
			if (error)
				DDLogError(@"Error when player quit: %@\n", error.description);

			if (remove)
				[self->match removeWithCompletionHandler:^(NSError* removeError)
				 {
					 if (removeError)
						 DDLogError(@"Error Removing Match: %@\n", removeError.description);
				 }];
		};

		if ([[match currentParticipant].player.playerID isEqual:[GKLocalPlayer localPlayer].playerID])
			[match participantQuitInTurnWithOutcome:outcome nextParticipants:localParticipants turnTimeout:GKTurnTimeoutDefault matchData:[NSKeyedArchiver archivedDataWithRootObject:localGame] completionHandler:completionHandler];
		else
			[match participantQuitOutOfTurnWithOutcome:outcome withCompletionHandler:completionHandler];
	}
}

- (BOOL) endMatchForAllParticipants
{
	if (matchHasEnded)
		return YES;

	for (GKTurnBasedParticipant* gktbp in match.participants)
	{
		PlayerState* state = nil;

		for (PlayerState* other in [[localGame gameState] playerStates])
		{
			if ([[[localGame.players objectAtIndex:other.playerID] getGameCenterName] isEqualToString:[gktbp player].playerID])
			{
				state = other;
				break;
			}
		}

		if ([state hasLost])
			gktbp.matchOutcome = GKTurnBasedMatchOutcomeLost;
		else if ([state hasWon])
			gktbp.matchOutcome = GKTurnBasedMatchOutcomeWon;
		else if (![state hasWon] && ![state hasLost])
			gktbp.matchOutcome = GKTurnBasedMatchOutcomeQuit;
	}

	[match endMatchInTurnWithMatchData:[NSKeyedArchiver archivedDataWithRootObject:localGame] completionHandler:^(NSError* error)
	 {
		 if (error)
			 DDLogError(@"Error ending match: %@\n", error.description);
	 }];

	return YES;
}

- (GKTurnBasedMatch*)getMatch
{
	return match;
}

@end
