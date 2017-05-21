//
//  SoarPlayer.mm
//  Liar's Dice
//
//  Created by Alex on 5/6/17.
//  Copyright (c) 2017 University of Michigan. All rights reserved.
//

#import "SoarPlayer.h"

#import <DiceLogicEngine/DiceLogicEngine-Swift.h>

#include <map>
#include <unordered_map>

@interface SoarPlayer ()
{
    sml::Kernel* kernel;
    sml::Agent* agent;

    Player* me;
    DiceLogicEngine* engine;

    int seed;
}

@end

void printEvent(sml::smlPrintEventId eventID, void* pUserData, sml::Agent* pAgent, char const* pMessage)
{
    NSLog(@"%s", pMessage);
}

@implementation SoarPlayer

// From: http://stackoverflow.com/questions/24688512/what-is-the-proper-way-to-detect-if-unit-tests-are-running-at-runtime-in-xcode
// which is from google-toolbox-for-mac
+ (BOOL)areWeBeingUnitTested {
    BOOL answer = NO;
    Class testProbeClass;
#if GTM_USING_XCTEST // you may need to change this to reflect which framework are you using
    testProbeClass = NSClassFromString(@"XCTestProbe");
#else
    testProbeClass = NSClassFromString(@"SenTestProbe");
#endif
    if (testProbeClass != Nil) {
        // Doing this little dance so we don't actually have to link
        // SenTestingKit in
        SEL selector = NSSelectorFromString(@"isTesting");
        NSMethodSignature *sig = [testProbeClass methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        [invocation setSelector:selector];
        [invocation invokeWithTarget:testProbeClass];
        [invocation getReturnValue:&answer];
    }
    return answer;
}

- (id)init
{
    return [self init:1];
}

- (id)init:(int)newSeed
{
    self = [super init];
    if (self)
    {
        self->seed = newSeed;
    }

    return self;
}

- (void)updateAgent
{
    using namespace sml;

    agent->SynchronizeInputLink();
    Identifier* inputLink = agent->GetInputLink();

    NSMutableArray* ids = [NSMutableArray array];
    for (int i = 0;i < inputLink->GetNumberChildren();++i)
    {
         [ids addObject:[NSValue valueWithPointer:inputLink->GetChild(i)]];
    }

    for (NSValue* wme in ids)
    {
        ((sml::WMElement*)[wme pointerValue])->DestroyWME();
    }

    Identifier *idState = NULL;
    Identifier *idPlayers = NULL;
    Identifier *idAffordances = NULL;
    WMElement *idHistory = NULL;
    WMElement *idRounds = NULL;

    idState = inputLink->CreateIdWME("state");
    idPlayers = inputLink->CreateIdWME("players");
    idAffordances = inputLink->CreateIdWME("affordances");

    idState->CreateStringWME("special", (engine.isSpecialRules ? "true" : "false"));
    idState->CreateStringWME("inprogress", "true");

    if (me.hasLost)
        idPlayers->CreateStringWME("mystatus", "lost");
    else if (engine.winner == me)
        idPlayers->CreateStringWME("mystatus", "won");
    else
        idPlayers->CreateStringWME("mystatus", "play");

    static NSPredicate* pushedPredicate = [NSPredicate predicateWithBlock:^BOOL(Die* object, NSDictionary* bindings) {
        return object.pushed;
    }];

    static NSPredicate* unpushedPredicate = [NSPredicate predicateWithBlock:^BOOL(Die* object, NSDictionary* bindings) {
        return !object.pushed;
    }];

    static NSPredicate* onesPredicate = [NSPredicate predicateWithBlock:^BOOL(Die* object, NSDictionary* bindings) {
        return object.face == 1;
    }];
    static NSPredicate* twosPredicate = [NSPredicate predicateWithBlock:^BOOL(Die* object, NSDictionary* bindings) {
        return object.face == 2;
    }];
    static NSPredicate* threesPredicate = [NSPredicate predicateWithBlock:^BOOL(Die* object, NSDictionary* bindings) {
        return object.face == 3;
    }];
    static NSPredicate* foursPredicate = [NSPredicate predicateWithBlock:^BOOL(Die* object, NSDictionary* bindings) {
        return object.face == 4;
    }];
    static NSPredicate* fivesPredicate = [NSPredicate predicateWithBlock:^BOOL(Die* object, NSDictionary* bindings) {
        return object.face == 5;
    }];
    static NSPredicate* sixesPredicate = [NSPredicate predicateWithBlock:^BOOL(Die* object, NSDictionary* bindings) {
        return object.face == 6;
    }];

    static NSPredicate* actionItemsPredicate = [NSPredicate predicateWithBlock:^BOOL(HistoryItem* object, NSDictionary* bindings) {
        return [object isKindOfClass:HistoryAction.class];
    }];

    NSMutableDictionary* playerMap = [[NSMutableDictionary alloc] init];

    unsigned int playerID = 0;
    for (Player* player in engine.players)
    {
        Identifier* idPlayer = idPlayers->CreateIdWME("player");
        [playerMap setObject:[NSValue valueWithPointer:idPlayer] forKey:player.name];

        idPlayer->CreateIntWME("id", playerID++);
        idPlayer->CreateStringWME("name", player.name.UTF8String);
        idPlayer->CreateStringWME("exists", [player.dice count] > 0 ? "true" : "false");

        NSArray* unpushedDice = [player.dice filteredArrayUsingPredicate:unpushedPredicate];

        Identifier* idCup = idPlayer->CreateIdWME("cup");
        idCup->CreateIntWME("count", (long long)unpushedDice.count);

        if (me == player)
        {
            for (Die* die in unpushedDice)
                idCup->CreateIdWME("die")->CreateIntWME("face", (long long)die.face);

            Identifier* idTotals = idCup->CreateIdWME("totals");
            idTotals->CreateIntWME("1", (long long)[unpushedDice filteredArrayUsingPredicate:onesPredicate].count);
            idTotals->CreateIntWME("2", (long long)[unpushedDice filteredArrayUsingPredicate:twosPredicate].count);
            idTotals->CreateIntWME("3", (long long)[unpushedDice filteredArrayUsingPredicate:threesPredicate].count);
            idTotals->CreateIntWME("4", (long long)[unpushedDice filteredArrayUsingPredicate:foursPredicate].count);
            idTotals->CreateIntWME("5", (long long)[unpushedDice filteredArrayUsingPredicate:fivesPredicate].count);
            idTotals->CreateIntWME("6", (long long)[unpushedDice filteredArrayUsingPredicate:sixesPredicate].count);

            idPlayers->CreateSharedIdWME("me", idPlayer);
        }

        NSArray* pushedDice = [player.dice filteredArrayUsingPredicate:pushedPredicate];

        Identifier* idPushed = idPlayer->CreateIdWME("pushed");
        idPushed->CreateIntWME("count", (long long)pushedDice.count);

        for (Die* die in pushedDice)
            idPushed->CreateIdWME("die")->CreateIntWME("face", (long long)die.face);

        Identifier* idPushedTotals = idPushed->CreateIdWME("totals");
        idPushedTotals->CreateIntWME("1", (long long)[pushedDice filteredArrayUsingPredicate:onesPredicate].count);
        idPushedTotals->CreateIntWME("2", (long long)[pushedDice filteredArrayUsingPredicate:twosPredicate].count);
        idPushedTotals->CreateIntWME("3", (long long)[pushedDice filteredArrayUsingPredicate:threesPredicate].count);
        idPushedTotals->CreateIntWME("4", (long long)[pushedDice filteredArrayUsingPredicate:foursPredicate].count);
        idPushedTotals->CreateIntWME("5", (long long)[pushedDice filteredArrayUsingPredicate:fivesPredicate].count);
        idPushedTotals->CreateIntWME("6", (long long)[pushedDice filteredArrayUsingPredicate:sixesPredicate].count);

        if (engine.currentTurn == player)
            idPlayers->CreateSharedIdWME("current", idPlayer);

        if (engine.winner == player)
            idPlayers->CreateSharedIdWME("victor", idPlayer);
    }

    Identifier* idBid = idAffordances->CreateIdWME("action");
    idBid->CreateStringWME("name", "bid");
    idBid->CreateStringWME("available", engine.currentTurn == me ? "true" : "false");

    Identifier* idPass = idAffordances->CreateIdWME("action");
    idPass->CreateStringWME("name", "pass");
    idPass->CreateStringWME("available", me.canPass ? "true" : "false");

    Identifier* idExact = idAffordances->CreateIdWME("action");
    idExact->CreateStringWME("name", "exact");
    idExact->CreateStringWME("available", me.canExact ? "true" : "false");

    Identifier* idChallenge = idAffordances->CreateIdWME("action");
    idChallenge->CreateStringWME("name", "challenge");

    NSMutableArray* targets = [[NSMutableArray alloc] init];
    for (Player* player in engine.players)
    {
        if ([me canChallenge:player.name])
            [targets addObject:player];
    }

    idChallenge->CreateStringWME("available", targets.count > 0 ? "true" : "false");

    for (Player* target in targets)
        idChallenge->CreateSharedIdWME("target", (sml::Identifier*)([(NSValue*)[playerMap objectForKey:target.name] pointerValue]));

    NSArray* unpushedDice = [me.dice filteredArrayUsingPredicate:unpushedPredicate];

    Identifier* idPush = idAffordances->CreateIdWME("action");
    idPush->CreateStringWME("name", "push");
    idPush->CreateStringWME("available", unpushedDice.count > 0 ? "true" : "false");

    Identifier* idAccept = idAffordances->CreateIdWME("action");
    idAccept->CreateStringWME("name", "accept");
    idAccept->CreateStringWME("available", "false");

    if (engine.history.count == 0)
    {
        idRounds = inputLink->CreateStringWME("rounds", "nil");
        idHistory = inputLink->CreateStringWME("history", "nil");
        idState->CreateStringWME("last-bid", "nil");
    }
    else
    {
        idRounds = inputLink->CreateIdWME("rounds");
        Identifier* idR = nullptr;

        for (NSArray* round in engine.history.reverseObjectEnumerator)
        {
            if (idR == nullptr)
            {
                idR = idRounds->ConvertToIdentifier();
            }
            else
            {
                idR = idR->CreateIdWME("next_round");
            }

            NSArray* actionItems = [round filteredArrayUsingPredicate:actionItemsPredicate];

            if (actionItems.count > 0)
            {
                Identifier* idH = nullptr;

                for (HistoryAction* action in actionItems.reverseObjectEnumerator)
                {
                    if (idH == nullptr)
                    {
                        idH = idR;
                    }
                    else
                    {
                        idH = idH->CreateIdWME("next");
                    }

                    idH->CreateSharedIdWME("player", (sml::Identifier*)[[playerMap objectForKey:action.player] pointerValue]);

                    if ([action isKindOfClass:BidAction.class])
                    {
                        BidAction* bidAction = (BidAction*)action;
                        idH->CreateStringWME("action", "bid");
                        idH->CreateIntWME("multiplier", (long long)bidAction.count);
                        idH->CreateIntWME("face", (long long)bidAction.face);

                        if (engine.lastBid == bidAction)
                            idState->CreateSharedIdWME("last-bid", idH);
                    }
                    else if ([action isKindOfClass:PushAction.class])
                    {
                        idH->CreateStringWME("action", "push");
                    }
                    else if ([action isKindOfClass:PassAction.class])
                    {
                        idH->CreateStringWME("action", "pass");
                    }
                    else if ([action isKindOfClass:ExactAction.class])
                    {
                        idH->CreateStringWME("action", "exact");
                        idH->CreateStringWME("result", action.correct ? "success" : "failure");
                    }
                    else if ([action isKindOfClass:ChallengeAction.class])
                    {
                        ChallengeAction* challengeAction = (ChallengeAction*)action;

                        HistoryAction* actionChallenged = (HistoryAction*)[engine.currentRoundHistory objectAtIndex:(NSUInteger)challengeAction.challengeActionIndex];

                        if ([actionChallenged isKindOfClass:BidAction.class])
                            idH->CreateStringWME("action", "challenge_bid");
                        else
                            idH->CreateStringWME("action", "challenge_pass");

                        idH->CreateSharedIdWME("target", (sml::Identifier*)[[playerMap objectForKey:challengeAction.challengee] pointerValue]);
                        idH->CreateStringWME("result", action.correct ? "success" : "failure");
                    }
                }

                idH->CreateStringWME("next", "nil");
            }

            if (actionItems.count == 0 && idHistory == nullptr)
            {
                idHistory = inputLink->CreateStringWME("history", "nil");
                idState->CreateStringWME("last-bid", "nil");
            }
            else if (actionItems.count > 0 && idHistory == nullptr)
                idHistory = inputLink->CreateSharedIdWME("history", idR);
        }
    }

    agent->Commit();
}

- (HistoryAction*)performAction:(Player*)_me engine:(DiceLogicEngine*)_engine difficulty:(int)difficulty;
{
    using namespace sml;

    me = _me;
    engine = _engine;

    if (![SoarPlayer areWeBeingUnitTested])
        kernel = sml::Kernel::CreateKernelInCurrentThread(true, sml::Kernel::kSuppressListener);
    else
        kernel = sml::Kernel::CreateKernelInNewThread();

    agent = kernel->CreateAgent("soar");
    agent->RegisterForPrintEvent(sml::smlEVENT_PRINT, printEvent, nil);
    agent->ExecuteCommandLine(("decide set-random-seed " + std::to_string(seed)).c_str());

    NSString *ruleFile = nil; /*@"dice-pmh"; @"dice-p0-m0-c0"; */

    switch (difficulty)
    {
        default:
        case 0:
        {
            ruleFile = @"dice-easy";
            break;
        }
        case 1:
        {
            ruleFile = @"dice-medium";
            break;
        }
        case 2:
        {
            ruleFile = @"dice-hard";
            break;
        }
        case 3:
        {
            ruleFile = @"dice-harder";
            break;
        }
        case 4:
        {
            ruleFile = @"dice-hardest";
            break;
        }
    }

    NSString* path = [[NSBundle bundleWithIdentifier:@"edu.umich.SoarPlayer"] pathForResource:ruleFile ofType:@"soar" inDirectory:@"SoarAgent"];

    if (path == nil)
        path = [[NSBundle mainBundle] pathForResource:ruleFile ofType:@"soar" inDirectory:@""];

    if (path == nil)
        path = [[NSBundle mainBundle] pathForResource:ruleFile ofType:@"soar" inDirectory:@"SoarAgent"];

    if (path == nil)
        NSLog(@"Null path, this will fail.");

    NSString* source = [NSString stringWithFormat:@"source \"%@\"", path];
    agent->ExecuteCommandLine([source UTF8String]);
    agent->ExecuteCommandLine("w 1");

    agent->InitSoar();

    HistoryAction* action = nil;

    [self updateAgent];

    while (true)
    {
        agent->RunSelfTilOutput();

        if (agent->GetNumberCommands() > 0)
        {
            Identifier* outputLink = agent->GetOutputLink();

            BOOL done = NO;
            for (auto it = outputLink->GetChildrenBegin();it != outputLink->GetChildrenEnd();++it)
            {
                StringElement* d = (*it)->ConvertToStringElement();
                if (d && std::string(d->GetAttribute()) == "done")
                {
                    done = YES;
                    break;
                }
            }

            if (!done)
                continue;

            for (auto it = outputLink->GetChildrenBegin();it != outputLink->GetChildrenEnd();++it)
            {
                Identifier* command = (*it)->ConvertToIdentifier();
                if (command == nullptr)
                    continue;

                if (command->GetParameterValue("status") != nullptr &&
                    std::string(command->GetParameterValue("status")) == "complete")
                    continue;

                std::string attribute = command->GetAttribute();
                if (attribute == "bid")
                {
                    std::string multiplier = std::string(command->GetParameterValue("multiplier"));
                    std::string f = std::string(command->GetParameterValue("face"));
                    NSUInteger count = std::stoi(multiplier);
                    NSUInteger face = std::stoi(f);

                    action = [[BidAction alloc] initWithPlayer:me.name
                                                         count:count
                                                          face:face
                                                    pushedDice:[[NSArray alloc] init]
                                                       newDice:[[NSArray alloc] init]
                                                       correct:NO];
                }
                else if (attribute == "push")
                {
                    NSMutableArray* dice = [[NSMutableArray alloc] init];

                    for (auto it = command->GetChildrenBegin();it != command->GetChildrenEnd();++it)
                    {
                        // die.face <face>
                        long long face = (*it)->ConvertToIdentifier()->GetChild(0)->ConvertToIntElement()->GetValue();
                        [dice addObject:[NSNumber numberWithLongLong:face]];
                    }

                    BidAction* bidAction = (BidAction*)action;
                    action = [[BidAction alloc] initWithPlayer:me.name
                                                         count:bidAction.count
                                                          face:bidAction.face
                                                    pushedDice:dice
                                                       newDice:[[NSArray alloc] init]
                                                       correct:false];
                }
                else if (attribute == "exact")
                {
                    action = [[ExactAction alloc] initWithPlayer:me.name correct:false];
                }
                else if (attribute == "challenge")
                {
                    // challenge.target <target>
                    long long target = command->GetChild(0)->ConvertToIntElement()->GetValue();
                    NSString* challengee = [engine.players objectAtIndex:(NSUInteger)target].name;

                    action = [[ChallengeAction alloc] initWithPlayer:me.name
                                                          challengee:challengee
                                                challengeActionIndex:0
                                                             correct:false];
                }
                else if (attribute == "pass")
                {
                    action = [[PassAction alloc] initWithPlayer:me.name
                                                     pushedDice:[[NSArray alloc] init]
                                                        newDice:[[NSArray alloc] init]
                                                        correct:false];
                }

                command->AddStatusComplete();
            }

            break;
        }
    }

    kernel->StopAllAgents();
    kernel->Shutdown();
    delete kernel;

    return action;
}

@end
