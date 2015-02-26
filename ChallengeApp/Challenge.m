//
//  Challenge.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/10/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "Challenge.h"

#define CHALLENGE_NAME_FIELD @"name"
#define CHALLENGE_DESCRIPTION_FIELD @"description"
#define CHALLENGE_IMAGE_FIELD @"image"
#define CHALLENGE_LIKES_FIELD @"likes"
#define CHALLENGE_COMMENTS_FIELD @"comments"
#define CHALLENGE_SOLUTIONS_FIELD @"solutions"

@implementation Challenge

- (id) initWithPFObject: (PFObject *)object
{
    self = [super init];
    if (self) {
        
//        DLOG(@"init challenge: %@ %@", [object objectForKey:CHALLENGE_NAME_FIELD], object);

        self.title = [object objectForKey:CHALLENGE_NAME_FIELD];
        self.details = [object objectForKey:CHALLENGE_DESCRIPTION_FIELD];
        self.createDate = object.createdAt;
        self.likesCount = [[object objectForKey:CHALLENGE_LIKES_FIELD] longValue];
        self.commentsCount = [[object objectForKey:CHALLENGE_COMMENTS_FIELD] longValue];
        self.solutionsCount = [[object objectForKey:CHALLENGE_SOLUTIONS_FIELD] longValue];
        
        self.imageFile = [object objectForKey:CHALLENGE_IMAGE_FIELD];
        
        self.object = object;
    }
    return self;
}

@end
