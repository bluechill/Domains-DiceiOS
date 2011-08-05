//
//  Lair_s_DiceAppDelegate_iPad.m
//  Lair's Dice
//
//  Created by Alex on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Lair_s_DiceAppDelegate_iPad.h"
#import "iPadServerViewController.h"
#import "Agent.h"

#import "NetworkPlayer.h"

#import "MainMenu.h"

#import "Die.h"

#import "HistoryItem.h"

@implementation Arguments

- (int)dieNumber
{
    return dieNumber;
}

- (int)playerNumber
{
    return playerNumber;
}

- (int)die
{
    return die;
}


- (void)setDieNumber:(int)number
{
    dieNumber = number;
}

- (void)setPlayerNumber:(int)number
{
    playerNumber = number;
}

- (void)setDie:(int)number
{
    die = number;
}

- (BOOL)wasChallenge
{
    return wasChallenge;
}

- (void)setWasChallenge:(BOOL)won1
{
    wasChallenge = won1;
}

- (BOOL)wasExact
{
    return wasExact;
}

- (void)setWasExact:(BOOL)won1
{
    wasExact = won1;
}

- (BOOL)shouldLoseDiceExact
{
    return shouldLoseDiceExact;
}

- (void)setShouldLoseDiceExact:(BOOL)shouldLose
{
    shouldLoseDiceExact = shouldLose;
}

@end

@interface Lair_s_DiceAppDelegate_iPad()

- (void)shuffle:(NSMutableArray *)array;

@end

typedef enum {
    QuestionMark = 0,
    One = 1,
    Two = 2,
    Three = 3,
    Four = 4,
    Five = 5,
    Six = 6
} Value;

typedef enum {
    Up,
    Down,
    Left,
    Right
} Orientation;

typedef struct {
    UIImageView *die;
    Value dieValue;
    
    Orientation orient;
} GUIDie;

@implementation Lair_s_DiceAppDelegate_iPad

- (id) init
{
    self = [super init];
    if (self)
    {
        int seed = arc4random() % RAND_MAX;
        srand(seed);    
        NSLog(@"Seed:%i", seed);
    }
    return self;
}

static NSUInteger random_below(NSUInteger n) {
    NSUInteger m = 1;
    
    // Compute smallest power of two greater than n.
    // There's probably a faster solution than this loop, but bit-twiddling
    // isn't my specialty.
    do {
        m <<= 1;
    } while(m < n);
    
    NSUInteger ret;
    
    do {
        ret = random() % m;
    } while(ret >= n);
    
    return ret;
}

- (void)shuffle:(NSMutableArray *)array
{
    for(NSUInteger i = [array count]; i > 1; i--) {
        NSUInteger j = random_below(i);
        [array exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
}


- (void)startTheGameWithNumberOfAgents:(int)agents players:(int)networkPlayers
{
    for (int i = 0; i < agents; i++)
    {
        //if (i == 1)
        //{
        //    Agent *newAgent = [[Agent alloc] init:YES];
        //    [players addObject:newAgent];
        //}
        //else
        [players addObject:[[Agent alloc] init:NO]];
    }
    
    [self shuffle:players];
    
    diceEngine = [[DiceEngine alloc] initWithPlayers:players];
    
    [mainViewController.view removeFromSuperview];
    [mainViewController release];
    
    mainViewController = [[iPadServerViewController alloc] initWithNibName:@"iPadServerViewController" bundle:nil withPlayers:[players count]];
    
    [(iPadServerViewController *)mainViewController setAppDelegate:self];
    
    [window addSubview:mainViewController.view];
    
    [window makeKeyAndVisible];
    
    mainLoop = [[NSThread alloc] initWithTarget:diceEngine selector:@selector(mainLoop:) object:self];
    [mainLoop start];
}

- (void)goToMainMenu
{
    if (![mainLoop isCancelled])
        [mainLoop cancel];
    
    [mainLoop release];
    
    mainLoop = nil;
    
    [mainViewController.view removeFromSuperview];
    [mainViewController release];
    
    [players release];
    players = [[NSMutableArray alloc] init];
    
    mainViewController = [[MainMenu alloc] initWithNibName:@"MainMenu" bundle:nil];
    
    [(MainMenu *)mainViewController setAppDelegate:self]; 
    
    [window addSubview:mainViewController.view];
    
    [window makeKeyAndVisible];
}

- (void)goToHelp
{
    [mainViewController.view removeFromSuperview];
    [mainViewController release];
    
    [players release];
    players = [[NSMutableArray alloc] init];
    
    mainViewController = [[iPadHelp alloc] initWithNibName:@"iPadHelp" bundle:nil];
    
    [(iPadHelp *)mainViewController setDelegate:self]; 
    
    [window addSubview:mainViewController.view];
    
    [window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*[server release];
     server = nil;
     
     server = [[Server alloc] init];
     server.delegate = self;
     [server startServer];*/
    
    peer = [[Peer alloc] init:YES];
    [peer setDelegate:self];
    [peer startPicker];
    
    [self goToMainMenu];
    
    return YES;
}

- (void)dealloc
{
    //[server release];
    [peer release];
	[super dealloc];
}

- (void)logToConsole:(NSString *)stringToOutputToConsole
{
    [mainViewController performSelectorOnMainThread:@selector(logToConsole:) withObject:stringToOutputToConsole waitUntilDone:NO];
}

- (void)logToActions:(NSString *)stringToOutputToActions
{
    [(iPadServerViewController *)mainViewController lastAction].text = stringToOutputToActions;
}

- (void)updateActionWithPush:(NSArray *)diceNumbersPushed withPlayer:(id <Player>)player withPlayerID:(int)playerIdentifier
{
    NSString *string = @"";
    
    int i = 0;
    for (NSNumber *number in diceNumbersPushed)
    {
        if ([number isKindOfClass:[NSNumber class]])
        {
            if ((i + 1) < [diceNumbersPushed count] || (i + 1) == 1)
                string = [string stringByAppendingFormat:@"Die %i,", [number intValue]];
            else
                string = [string stringByAppendingFormat:@"and Die %i", [number intValue]];
            
            if ((i + 1) < [diceNumbersPushed count])
                string = [string stringByAppendingString:@" "];
            
            if ([mainViewController isKindOfClass:[iPadServerViewController class]])
            {
                iPadServerViewController *controller = (iPadServerViewController *)mainViewController;
                
                Arguments *args = [[Arguments alloc] init];
                args.dieNumber = (i + 1);
                args.playerNumber = (playerIdentifier + 1);
                args.die = [number intValue];
                [args autorelease];
                [controller performSelectorOnMainThread:@selector(dieWasPushed:) withObject:args waitUntilDone:YES];
            }
        }
        
        i++;
    }
    
    
    [self logToConsole:[NSString stringWithFormat:@"%@ pushed by %@", string, [player name]]];
    
    [self performSelectorOnMainThread:@selector(logToActions:) withObject:[NSString stringWithFormat:@"%@\nPUSH %@", [(iPadServerViewController *)mainViewController lastAction].text, string] waitUntilDone:NO];
}

- (void)updateActionWithBid:(   Bid *) bid withPlayer:(id <Player>)player
{
    [self logToConsole:[NSString stringWithFormat:@"%@ bid %i %is", [player name], bid.numberOfDice, bid.rankOfDie]];
    
    NSString *secondPart = @"";
    
    if ([[(iPadServerViewController *)mainViewController lastAction].text hasSuffix:@"Pass"] && [[(iPadServerViewController *)mainViewController lastAction].text rangeOfString:@"Second To Last Action ("].length == NSNotFound)
    {
        NSString *lastActionText = [(iPadServerViewController *)mainViewController lastAction].text;
        NSArray *componentsOfLastAction = [lastActionText componentsSeparatedByString:@")"];
        NSString *firstComponent = [componentsOfLastAction objectAtIndex:0];
        NSArray *componentsOfTheFirstComponent = [firstComponent componentsSeparatedByString:@"("];
        NSString *nameOfSecondToLastPlayer = [componentsOfTheFirstComponent objectAtIndex:1];
        
        secondPart = [NSString stringWithFormat:@"Second To Last Action (%@): Pass", nameOfSecondToLastPlayer];
    }
    
    [self performSelectorOnMainThread:@selector(logToActions:) withObject:[NSString stringWithFormat:@"Last Action (%@):\nBid %i %i%@\n%@", [player name], bid.numberOfDice, bid.rankOfDie, (bid.rankOfDie > 1 ? @"s" : @""), secondPart] waitUntilDone:NO];
}

- (void)updateActionWithExact:(id <Player>)player andWasTheExactRight:(BOOL *)wasTheExactRight withPlayerID:(int)playerIdentifier
{
    [self logToConsole:[NSString stringWithFormat:@"%@ exacted", [player name]]];
    
    if (*wasTheExactRight)
        [self logToConsole:[NSString stringWithFormat:@"%@ was right!", [player name]]];
    else
        [self logToConsole:[NSString stringWithFormat:@"%@ was wrong!", [player name]]];
    
    [self performSelectorOnMainThread:@selector(logToActions:) withObject:[NSString stringWithFormat:@"Last Action (%@):\n Exact! (%@)", [player name], (*wasTheExactRight ? @"Success!" : @"Fail!")] waitUntilDone:NO];
    
    wasChallenge = NO;
    wasExact = YES;
    
    self->playerID = playerIdentifier;
    if (*wasTheExactRight)
        shouldLoseDieExact = NO;
    else
        shouldLoseDieExact = YES;
    
    free(wasTheExactRight);
}

- (void)updateActionWithPass:(id <Player>)player
{
    [self logToConsole:[NSString stringWithFormat:@"%@ passed", [player name]]];
    
    [self performSelectorOnMainThread:@selector(logToActions:) withObject:[NSString stringWithFormat:@"Last Action (%@):\nPass", [player name]] waitUntilDone:NO];
}

- (void)updateActionWithChallenge:(id <Player>)firstPlayer against:(id <Player>)secondPlayer ofType:(Type)type withDidTheChallengerWin:(BOOL *)didTheChallengerWin withPlayerID:(int)playerIdentifier
{
    if (type == A_CHALLENGE_BID)
        [self logToConsole:[NSString stringWithFormat:@"%@ challenged %@'s bid!", [firstPlayer name], [secondPlayer name]]];
    else
        [self logToConsole:[NSString stringWithFormat:@"%@ challenged %@'s pass", [firstPlayer name], [secondPlayer name]]];
    
    if (*didTheChallengerWin)
        [self logToConsole:[NSString stringWithFormat:@"%@ won!", [firstPlayer name]]];
    else
        [self logToConsole:[NSString stringWithFormat:@"%@ lost!", [firstPlayer name]]];
    
    [self performSelectorOnMainThread:@selector(logToActions:) withObject:[NSString stringWithFormat:@"Last Action (%@):\n Challenge against %@! (%@)", [firstPlayer name], [secondPlayer name], (*didTheChallengerWin ? @"Success!" : @"Fail!")] waitUntilDone:NO];
    
    wasChallenge = YES;
    wasExact = NO;
    shouldLoseDieExact = NO;
    
    self->playerID = playerIdentifier;
    
    free(didTheChallengerWin);
}

- (void)someoneWonTheGame:(NSString *)playerName
{
    playerName = [[playerName componentsSeparatedByString:@"-"] objectAtIndex:0];
    
    [self showAll:[diceEngine diceGameState]];
    
    [self logToConsole:[NSString stringWithFormat:@"%@ won!", playerName]];
    
    [(iPadServerViewController *)mainViewController gameOver:playerName];
}

- (void)specialRulesAreInEffect
{
    [self logToConsole:@"Special Rules are Now In Effect"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Special Rules" message:@"Special Rules are now in effect.  Click the help button at the main menu for more information." delegate:mainViewController cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

- (void)clientConnected:(NSString *)clientName
{
    if (!mainLoop)
    {
        NSString *name = [peer.namesToPeerIDs objectForKey:clientName];
        if (!name)
            name = clientName;
        NetworkPlayer *newPlayer = [[NetworkPlayer alloc] initWithName:name playerID:[players count]];
        [newPlayer setDelegate:self];
        [players addObject:newPlayer];
        
        [(MainMenu *)mainViewController addNetworkPlayer:name];
    }
}

- (void)clientDisconnected:(NSString *)clientName
{
    NSString *name = [peer.namesToPeerIDs objectForKey:clientName];
    if (!name)
        name = clientName;
    [(MainMenu *)mainViewController removeNetworkPlayer:name];
}

- (void)clientSentData:(NSString *)data client:(NSString *)client
{
    if ([data isEqualToString:@"C:DONESHOWALL"])
    {
        BOOL doneShowAll = YES;
        
        for (NetworkPlayer *player in players)
        {
            if ([player isKindOfClass:[NetworkPlayer class]])
            {
                NSString *name = [peer.peerIDsToName objectForKey:[player name]];
                if (!name)
                    name = [player name];
                
                if (name == client)
                    player.doneShowAll = YES;
                else if (!player.doneShowAll)
                    doneShowAll = NO;
            }
        }
        
        if (doneShowAll)
        {
            for (NetworkPlayer *player in players)
            {
                if ([player isKindOfClass:[NetworkPlayer class]])
                {
                    player.doneShowAll = NO;
                }
            }
            
            iPadServerViewController *controller = (iPadServerViewController *)mainViewController;
            
            Arguments *arguments = [[Arguments alloc] init];
            arguments.wasChallenge = wasChallenge;
            arguments.wasExact = wasExact;
            arguments.playerNumber = playerID;
            arguments.shouldLoseDiceExact = shouldLoseDieExact;
            
            [controller performSelectorOnMainThread:@selector(clearPushedDice:) withObject:arguments waitUntilDone:YES];
            
            [diceEngine doneShowAll];
            [(iPadServerViewController *)mainViewController clearAll];
            
            [(iPadServerViewController *)mainViewController lastAction].text = @"";
        }
        
        return;
    }
    
    for (NetworkPlayer *player in players)
    {
        if ([player isKindOfClass:[NetworkPlayer class]])
        {
            NSString *name = [peer.peerIDsToName objectForKey:[player name]];
            if (!name)
                name = [player name];
            if (name == client)
                [player clientData:data];
        }
    }
}

- (void)sendData:(NSString *)data toPlayer:(NSString *)player
{
    NSString *name = [[peer peerIDsToName] objectForKey:player];
    if (!name)
        name = player;
    
    NSMutableData *message = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:message];
    [archiver encodeObject:data];
    [archiver finishEncoding];
    [archiver release];
    [message autorelease];
    
    [peer sendNetworkPacket:[peer gameSession] packetID:NETWORK_OTHER withData:message ofLength:[message length] reliable:YES withPeerID:name];
    //[server sendNetworkPacket:NETWORK_OTHER withData:&data ofLength:sizeof(data) reliable:YES peer:player];
}

- (BOOL)canAcceptConnections
{
    if (!mainLoop)
        return YES;
    else
        return NO;
}

- (void)setPlayerNames
{
    for (int i = 0;i < [players count];i++)
    {
        id <NSObject, Player> player = [players objectAtIndex:i];
        if ([player conformsToProtocol:@protocol(Player)])
        {
            [(iPadServerViewController *)mainViewController setPlayerName:[player name] forPlayer:(i + 1)];
        }
    }
}

- (void)showAll:(DiceGameState *)gameState
{
    static int calls = 0;
    calls++;
    NSLog(@"CALLS:%i", calls);
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (PlayerState *newPlayer in [gameState players])
    {
        NSArray *arrayOfDice = [newPlayer arrayOfDice];
        
        NSMutableArray *playerDice = [[NSMutableArray alloc] init];
        
        for (Die *die in arrayOfDice)
        {
            NSNumber *newDie = [NSNumber numberWithInt:[die dieValue]];
            [playerDice addObject:newDie];
        }
        
        [playerDice autorelease];
        [array addObject:playerDice];
    }
    
    [array autorelease];
    [(iPadServerViewController *)mainViewController showAll:array];
    
    BOOL networkPlayers = NO;
    for (NetworkPlayer *player in players)
    {
        if ([player isKindOfClass:[NetworkPlayer class]])
        {
            if (![(PlayerState *)[gameState player:[gameState playerIDByPlayerName:[player name]]] hasThePlayerLost])
            {
                networkPlayers = YES;
                [self sendData:@"SHOWALL" toPlayer:[player name]];
            }
            else
            {
                player.doneShowAll = YES;
            }
        }
    }
    
    if (!networkPlayers)
    {
        iPadServerViewController *controller = (iPadServerViewController *)mainViewController;
        
        Arguments *arguments = [[Arguments alloc] init];
        arguments.wasChallenge = wasChallenge;
        arguments.wasExact = wasExact;
        arguments.playerNumber = playerID;
        arguments.shouldLoseDiceExact = shouldLoseDieExact;
        
        [controller performSelectorOnMainThread:@selector(clearPushedDice:) withObject:arguments waitUntilDone:YES];
        
        [diceEngine doneShowAll];
        [(iPadServerViewController *)mainViewController performSelectorOnMainThread:@selector(clearAll) withObject:nil waitUntilDone:NO];
    }
}

- (void)tappedArea:(int)area
{
    area -= 1;
    
    NSString *content = @"";
    
    NSArray *roundHistory = [[diceEngine diceGameState] history];
    roundHistory = [roundHistory reversedArray];
    
    BOOL hasPlayer = NO;
    
    int i = 0;
    for (HistoryItem *item in roundHistory)
    {
        if ([item isKindOfClass:[HistoryItem class]])
        {
            if ([[diceEngine diceGameState] playerIDByPlayerName:[[item player] playerName]] == area)
            {
                //Got the player
                hasPlayer = YES;
                BOOL wasPush = NO;
                
                NSString *name = [[[[item player] playerName] componentsSeparatedByString:@"-"] objectAtIndex:0];
                
                switch ([item type]) {
                    case PUSH:
                    {
                        content = [NSString stringWithFormat:@"\nAlso pushed"];
                        wasPush = YES;
                    }
                        break;
                    case BID:
                    {
                        content = [NSString stringWithFormat:@"%@:\nBid %@ %@%@.%@", name, [NSString stringWithFormat:@"%i", [[item bid] numberOfDice]], [NSString stringWithFormat:@"%i", [[item bid] rankOfDie]], ([[item bid] numberOfDice] > 1 ? @"s" : @""), content];
                    }
                        break;
                    case PASS:
                    {
                        content = [NSString stringWithFormat:@"%@:\nPass", name];
                    }
                        break;
                    default:
                        break;
                }
                
                if (!wasPush)
                    break;
            }
        }
        i++;
    }
    
    if (!hasPlayer)
    {
        content = @"This player has not played this round yet.";
    }
    
    [(iPadServerViewController *)mainViewController showPopOverFor:area withContents:content];
}

- (void)newTurn:(int)player
{
    intStruct integer;
    integer.integer = player;
    NSValue *value = [NSValue value:&integer withObjCType:@encode(intStruct)];
    [(iPadServerViewController *)mainViewController performSelectorOnMainThread:@selector(setCurrentTurn:) withObject:value waitUntilDone:NO];
}

- (void)hideAllDice:(int)playerId
{
    
}

@end
