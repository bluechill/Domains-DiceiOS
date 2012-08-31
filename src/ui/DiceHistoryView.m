//
//  DiceHistoryView.m
//  Liars Dice
//
//  Created by Miller Tinkerhess on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DiceHistoryView.h"

#import "HistoryItem.h"

@implementation DiceHistoryView
@synthesize historyLabel, state;

- (id)initWithPlayerState:(PlayerState *)aState
{
    self = [super initWithNibName:@"DiceHistoryView"
                           bundle:nil];
    if (self) {
        // Custom initialization
        self.state = aState;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *rounds = [self.state.gameState roundHistory];
    NSMutableString *str = [NSMutableString string];
    for (NSArray *round in rounds)
    {
        for (HistoryItem *item in round)
        {
            [str appendFormat:@"%@\n\n", [item asString]];
        }
    }
    
    NSArray *thisRound = [self.state.gameState history];
    for (HistoryItem *item in thisRound)
    {
        [str appendFormat:@"%@\n\n", [item asString]];
    }

    self.historyLabel.text = [NSString stringWithString:str];
    [self.historyLabel setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void) viewDidAppear:(BOOL)animated
{
    CGPoint bottomOffset = CGPointMake(0, [self.historyLabel contentSize].height - self.historyLabel.frame.size.height);
    [self.historyLabel setContentOffset:bottomOffset animated: YES];
}

- (void)viewDidUnload
{
    [self setHistoryLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)backPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
- (void)dealloc {
    [historyLabel release];
    [super dealloc];
}
@end