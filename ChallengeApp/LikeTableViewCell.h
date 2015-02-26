//
//  LikeTableViewCell.h
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/18/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface LikeTableViewCell : UITableViewCell
{
    
}

- (void) setLike:(PFObject *)like;
@end
