//
//  ChallengeSolution.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/14/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "ChallengeSolution.h"

@implementation ChallengeSolution

- (id) initWithPFObject: (PFObject *)object
{
    self = [super init];
    if (self) {
        
        self.comment = [object objectForKey:@"comment"];
        self.createDate = object.createdAt;
        self.likesCount = [[object objectForKey:@"likes"] longValue];
        self.commentsCount = [[object objectForKey:@"comments"] longValue];
        
        self.imageFile = [object objectForKey:@"image"];
        self.videoFile = [object objectForKey:@"movie"];
        
        self.author = [object objectForKey:@"user"];

        self.object = object;
    }
    return self;
}

@end
