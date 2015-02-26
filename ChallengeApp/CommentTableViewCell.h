//
//  CommentTableViewCell.h
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/14/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@interface CommentTableViewCell : UITableViewCell
{
    
}

- (void) setComment:(Comment *)comment;
+ (CGFloat) heightForComment: (Comment *)comment cellWidth:(CGFloat)width;

@end
