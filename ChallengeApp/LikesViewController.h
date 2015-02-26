//
//  LikesViewController.h
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/17/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "BaseViewController.h"
#import <Parse/Parse.h>
#import "Challenge.h"
#import "ChallengeSolution.h"

#define LIKE_CELL_HEIGHT 60.f

@interface LikesViewController : PFQueryTableViewController
{
    
}

- (id) initWithChallenge:(Challenge *)challenge;
- (id) initWithChallengeSolution:(ChallengeSolution *)challengeSolution;

@end
