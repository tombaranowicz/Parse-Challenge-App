//
//  Comment.h
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/14/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Comment : NSObject
{
    
}

- (id) initWithPFObject: (PFObject *)object;

@property (nonatomic, strong) NSString *comment;

@property (nonatomic, strong) PFObject *object;
@property (nonatomic, strong) PFUser *author;
@end
