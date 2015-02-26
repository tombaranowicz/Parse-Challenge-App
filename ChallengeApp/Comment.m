//
//  Comment.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/14/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (id) initWithPFObject: (PFObject *)object
{
    self = [super init];
    if (self) {
        self.comment = [object objectForKey:@"comment"];
        self.author = [object objectForKey:@"author"];
        self.object = object;
    }
    return self;
}

@end
