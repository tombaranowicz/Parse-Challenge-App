//
//  ChallengeSolution.h
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/14/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Challenge.h"

@interface ChallengeSolution : NSObject

- (id) initWithPFObject: (PFObject *)object;

@property (nonatomic, strong) Challenge *challenge;
@property (nonatomic, strong) PFObject *object;
@property (nonatomic, strong) PFUser *author;

@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSDate *createDate;
@property (nonatomic) long likesCount;
@property (nonatomic) long commentsCount;

@property (nonatomic, strong) PFFile *imageFile;
@property (nonatomic, strong) PFFile *videoFile;
@property (nonatomic, strong) PFObject *like;
@property (nonatomic, strong) UIImage *loadedImage;

@end
