//
//  SoarPlayer.h
//  SoarPlayer
//
//  Created by Alex Turner on 5/21/17.
//  Copyright © 2017 Alex Turner. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for SoarPlayer.
FOUNDATION_EXPORT double SoarPlayerVersionNumber;

//! Project version string for SoarPlayer.
FOUNDATION_EXPORT const unsigned char SoarPlayerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SoarPlayer/PublicHeader.h>

#ifdef __cplusplus

#import "portability.h"
#import "sml_Connection.h"
#import "sml_Client.h"
#import "sml_Events.h"
#import "sml_ClientAgent.h"
#import "sml_ClientIdentifier.h"
#import "ElementXML.h"
#import <unordered_map>

#import <vector>

#endif

@class HistoryAction;
@class DiceLogicEngine;
@class Player;

@interface SoarPlayer : NSObject

- (id)init:(int)seed;

// who = who is the soar player
// state = [[1,2,3,4,5],[1,2,3,4]] etc.
- (HistoryAction*)performAction:(Player*)me engine:(DiceLogicEngine*)engine difficulty:(int)difficulty;

@end
