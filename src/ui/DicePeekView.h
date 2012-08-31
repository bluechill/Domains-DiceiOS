//
//  DicePeekView.h
//  Lair's Dice
//
//  Created by Miller Tinkerhess on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayerState;

@interface DicePeekView : UIViewController {
    PlayerState *state;
    UIView *diceSubvew;
    int dieWidth;
}

- (id) initWithState:(PlayerState *)state;
- (void) dieButtonPressed:(id)sender;

@property (readwrite, retain) PlayerState *state;
@property (nonatomic, retain) IBOutlet UIView *diceSubvew;

+ (UIImage *) imageForDie:(int)die;

@end