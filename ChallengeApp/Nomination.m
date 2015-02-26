//
//  Nomination.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/30/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "Nomination.h"

@implementation Nomination

- (id) initWithPFObject: (PFObject *)object
{
    self = [super init];
    if (self) {
        self.fromUser = [object objectForKey:@"from"];
        self.toUser = [object objectForKey:@"to"];
        self.object = object;
    }
    return self;
}



@end
