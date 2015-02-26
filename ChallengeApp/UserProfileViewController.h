//
//  UserProfileViewController.h
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/18/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "BaseViewController.h"
#import <Parse/Parse.h>

@interface UserProfileViewController : BaseViewController
{
    PFUser *user;
}

- (id)initWithPFUser:(PFUser *)user;
@end
