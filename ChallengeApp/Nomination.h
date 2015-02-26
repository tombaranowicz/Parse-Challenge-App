//
//  Nomination.h
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/30/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Challenge.h"

@interface Nomination : NSObject
- (id) initWithPFObject: (PFObject *)object;

@property (nonatomic, strong) PFObject *object;
@property (nonatomic, strong) Challenge *challenge;
@property (nonatomic, strong) PFUser *fromUser;
@property (nonatomic, strong) PFUser *toUser;

@end
