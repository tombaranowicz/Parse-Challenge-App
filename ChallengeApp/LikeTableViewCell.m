//
//  LikeTableViewCell.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/18/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "LikeTableViewCell.h"
#import <NSDate+TimeAgo.h>
#import <FontAwesomeKit/FAKFontAwesome.h>

@interface LikeTableViewCell()
{
    UILabel *userNameLabel;
    PFImageView *userImageView;
    UILabel *timeLabel;
}
@end

@implementation LikeTableViewCell

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
        
        userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, screenWidth-70, 20)];
        userNameLabel.textColor = [UIColor darkGrayColor];
        userNameLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        [self.contentView addSubview:userNameLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, CGRectGetMaxY(userNameLabel.frame), 150, 15)];
        timeLabel.font = [UIFont systemFontOfSize:12.0f];
        timeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:timeLabel];
    }
    
    return self;
}

- (void) setLike:(PFObject *)like
{
    FAKFontAwesome *userIcon = [FAKFontAwesome userIconWithSize:35.0f];
    [userIcon addAttribute:NSForegroundColorAttributeName value:[Utils themeColor]];
    userImageView.image = [userIcon imageWithSize:CGSizeMake(50, 50)];
    
    timeLabel.text = [like.createdAt timeAgo];
    
    PFQuery *query = [PFUser query];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 60*60;
    PFUser *author = like[@"author"];
    [query whereKey:@"objectId" equalTo:author.objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        userNameLabel.text = object[@"username"];
        userImageView.file = object[@"profileImageThumb"];
        [userImageView loadInBackground];
    }];
}
@end
