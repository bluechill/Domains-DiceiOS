//
//  DiceLocalPlayer.m
//  Liar's Dice
//
//  Created by Miller Tinkerhess on 10/4/11.
//  Copyright (c) 2012 University of Michigan. All rights reserved.
//

#import "DiceLocalPlayer.h"

#import "PlayerState.h"
#import "PlayGame.h"
#import "GameKitGameHandler.h"
#import "PlayGameView.h"

@implementation DiceLocalPlayer

@synthesize name, playerState, gameView, handler, participant;

- (id)initWithName:(NSString*)aName withHandler:(GameKitGameHandler *)newHandler withParticipant:(GKTurnBasedParticipant *)localPlayer
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.name = aName;
        playerID = -1;
		handler = newHandler;
		participant = localPlayer;
    }
    
    return self;
}


- (void)dealloc
{
	NSLog(@"Dice Local Player deallocated\n");
}

- (NSString*) getDisplayName
{
	NSString* displayName = self.name;

	if ([GKLocalPlayer localPlayer].isAuthenticated)
		displayName = @"You";

    return displayName;
}

- (NSString*) getGameCenterName
{
	if (![GKLocalPlayer localPlayer].isAuthenticated)
		return self.name;
	
	return [[GKLocalPlayer localPlayer] playerID];
}

- (void) updateState:(PlayerState*)state
{
    self.playerState = state;
	PlayGameView* gameViewLocal = self.gameView;
	PlayerState* playerStateLocal = self.playerState;
    [gameViewLocal updateState:playerStateLocal];
}

- (int) getID
{
    return playerID;
}

- (void) setID:(int)anID
{
    playerID = anID;
}

- (void) itsYourTurn
{
	PlayGameView* gameViewLocal = self.gameView;
	[gameViewLocal updateUI];

	UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification,
									gameViewLocal.gameStateLabel);
}

- (void)notifyHasLost
{
	GameKitGameHandler* handlerLocal = self.handler;

	if (handlerLocal)
		handlerLocal.match.currentParticipant.matchOutcome = GKTurnBasedMatchOutcomeLost;
}

- (void)notifyHasWon
{
	GameKitGameHandler* handlerLocal = self.handler;

	if (handlerLocal)
		[handlerLocal endMatchForAllParticipants];
}

- (void) end
{}

- (void) end:(BOOL)showAlert
{
	if (![NSThread isMainThread] || !showAlert)
		return;

	PlayGameView* localView = self.gameView;

	if (localView == nil)
	{
		PlayerState* localState = self.playerState;
		DiceGameState* gameState = localState.gameState;
		DiceGame* game = gameState.game;

		self.gameView = game.gameView;
		localView = self.gameView;
	}

	if (localView == nil || localView.navigationController.visibleViewController != localView)
		return;

	id<Player> gameWinner = localView.game.gameState.gameWinner;
	NSString* winner = [gameWinner getDisplayName];
	NSString* winString = @"Wins";

	if ([winner isEqualToString:@"You"])
		winString = @"Win";

	NSString *title = [NSString stringWithFormat:@"%@ %@!", winner, winString];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:nil
												   delegate:self
										  cancelButtonTitle:nil
										  otherButtonTitles:@"Okay", nil];
	[alert show];
}

- (void)removeHandler
{
	self.handler = nil;
}

@end
