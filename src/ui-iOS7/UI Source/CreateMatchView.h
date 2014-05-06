//
//  CreateMatchView.h
//  UM Liars Dice
//
//  Created by Alex Turner on 5/6/14.
//
//

#import <UIKit/UIKit.h>

@interface CreateMatchView : UIViewController

@property (nonatomic, retain) IBOutlet UILabel* numberOfAIPlayers;
@property (nonatomic, retain) IBOutlet UIStepper* changeNumberOfAIPlayers;

@property (nonatomic, retain) IBOutlet UILabel* minimumNumberOfHumanPlayers;
@property (nonatomic, retain) IBOutlet UIStepper* changeMinimumNumberOfHumanPlayers;

@property (nonatomic, retain) IBOutlet UILabel* maximumNumberOfHumanPlayers;
@property (nonatomic, retain) IBOutlet UIStepper* changeMaximumNumberOfHumanPlayers;

@property (nonatomic, retain) IBOutlet UIButton* createMatchButton;

-(IBAction)createMatchButtonPressed:(id)sender;

@end
