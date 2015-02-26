//
//  CommentTableViewCell.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/14/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "CommentTableViewCell.h"
#import <NSDate+TimeAgo.h>
#import <FontAwesomeKit/FAKFontAwesome.h>

@interface CommentTableViewCell()
{
    UILabel *commentLabel;
    UILabel *userNameLabel;
    PFImageView *userImageView;
    UILabel *timeLabel;
}
@end

@implementation CommentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;

        userImageView = [[PFImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
        userImageView.contentMode = UIViewContentModeScaleAspectFill;
        userImageView.clipsToBounds = YES;
        userImageView.layer.cornerRadius = 25.f;
        userImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        userImageView.layer.borderWidth = 0.5f;
        [self.contentView addSubview:userImageView];
        
        userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, screenWidth-70, 14)];
        userNameLabel.textColor = [UIColor darkGrayColor];
        userNameLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        [self.contentView addSubview:userNameLabel];
        
        commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 19, screenWidth-70, 32)];
        commentLabel.numberOfLines = 0;
        commentLabel.font = [UIFont systemFontOfSize:13.0f];
        commentLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:commentLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-160, CGRectGetMaxY(commentLabel.frame)+5, 150, 15)];
        timeLabel.font = [UIFont systemFontOfSize:12.0f];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:timeLabel];
    }
    
    return self;
}

- (void) setComment:(Comment *)comment
{
    FAKFontAwesome *userIcon = [FAKFontAwesome userIconWithSize:35.0f];
    [userIcon addAttribute:NSForegroundColorAttributeName value:[Utils themeColor]];
    userImageView.image = [userIcon imageWithSize:CGSizeMake(50, 50)];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    commentLabel.frame = CGRectMake(60, 19, screenWidth-70, 32);
    commentLabel.text = comment.comment;
    [commentLabel sizeToFit];
    
    timeLabel.frame = CGRectMake(screenWidth-160, CGRectGetMaxY(commentLabel.frame)+5, 150, 15);
    timeLabel.text = [NSString stringWithFormat:@"%@", [comment.object.createdAt timeAgo]];
    
    PFQuery *query = [PFUser query];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 60*60;
    [query whereKey:@"objectId" equalTo:comment.author.objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        userNameLabel.text = object[@"username"];
        userImageView.file = object[@"profileImageThumb"];
        [userImageView loadInBackground];
    }];
}

+ (CGFloat) heightForComment: (Comment *)comment cellWidth:(CGFloat)width {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60, 19, width-70, 32)];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:13.0f];
    label.text = comment.comment;
    [label sizeToFit];
    
    return 20 + label.frame.size.height + 25;
}
@end
