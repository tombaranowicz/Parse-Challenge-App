//
//  Challenge.h
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/10/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Challenge : NSObject
{
    
}

- (id) initWithPFObject: (PFObject *)object;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *details;

@property (nonatomic, strong) PFFile *imageFile;

@property (nonatomic, strong) NSDate *createDate;
@property (nonatomic) long likesCount;
@property (nonatomic) long solutionsCount;
@property (nonatomic) long commentsCount;

@property (nonatomic, strong) PFObject *object;
@property (nonatomic, strong) PFObject *like;

@end
