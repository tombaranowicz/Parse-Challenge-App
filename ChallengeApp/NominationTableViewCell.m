//
//  NominationTableViewCell.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/30/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "NominationTableViewCell.h"
#import <NSDate+TimeAgo/NSDate+TimeAgo.h>
#import "Challenge.h"
#import <FontAwesomeKit/FAKFontAwesome.h>

@interface NominationTableViewCell()
{
    UILabel *commentLabel;
    UILabel *userNameLabel;
    PFImageView *userImageView;
    UILabel *timeLabel;
    UILabel *challengeLabel;
}
@end

@implementation NominationTableViewCell

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
        
        userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 5, screenWidth-80, 14)];
        userNameLabel.textColor = [UIColor darkGrayColor];
        userNameLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        [self.contentView addSubview:userNameLabel];
        
        commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 19, screenWidth-80, 20)];
        commentLabel.numberOfLines = 1;
        commentLabel.font = [UIFont systemFontOfSize:13.0f];
        commentLabel.textColor = [UIColor darkGrayColor];
        commentLabel.text = @"nominated you in:";
        [self.contentView addSubview:commentLabel];
        
        challengeLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, CGRectGetMaxY(commentLabel.frame), screenWidth-80, 20)];
        challengeLabel.textColor = [Utils blueColor];
        challengeLabel.font = [UIFont systemFontOfSize:13.0f];
        [self.contentView addSubview:challengeLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-160, CGRectGetMaxY(challengeLabel.frame), 150, 15)];
        timeLabel.font = [UIFont systemFontOfSize:12.0f];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:timeLabel];
    }
    
    return self;
}

- (void) updateWithNomination:(Nomination *)nomination {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    FAKFontAwesome *userIcon = [FAKFontAwesome userIconWithSize:35.0f];
    [userIcon addAttribute:NSForegroundColorAttributeName value:[Utils themeColor]];
    userImageView.image = [userIcon imageWithSize:CGSizeMake(50, 50)];
    
    timeLabel.text = [NSString stringWithFormat:@"%@", [nomination.object.createdAt timeAgo]];
    
    PFQuery *query = [PFUser query];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 60*60;
    [query whereKey:@"objectId" equalTo:nomination.fromUser.objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        userNameLabel.text = object[@"username"];
        userImageView.file = object[@"profileImageThumb"];
        [userImageView loadInBackground];
    }];
    
    __weak Nomination *weakSelf = nomination;
    PFObject *obj = nomination.object[@"challenge"];
    query = [PFQuery queryWithClassName:@"Challenge"];
    [query whereKey:@"objectId" equalTo:obj.objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        weakSelf.challenge = [[Challenge alloc] initWithPFObject:object];
        challengeLabel.text = object[@"name"];
    }];
}

@end
