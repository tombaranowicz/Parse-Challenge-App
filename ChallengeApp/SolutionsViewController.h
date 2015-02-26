//
//  SolutionsViewController.h
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/27/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "BaseViewController.h"
#import <Parse/Parse.h>
#import "Challenge.h"

@interface SolutionsViewController : BaseViewController
{
    
}

- (id) initForUser:(PFUser *)user;
- (id) initForChallenge:(Challenge *)challenge;


@end
