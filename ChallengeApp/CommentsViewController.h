//
//  CommentsViewController.h
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/14/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "BaseViewController.h"
#import "Challenge.h"
#import "ChallengeSolution.h"
#import <Parse/Parse.h>

@interface CommentsViewController : BaseViewController
{
    
}

- (id) initWithChallenge:(Challenge *)challenge;
- (id) initWithChallengeSolution:(ChallengeSolution *)challengeSolution;

@end
