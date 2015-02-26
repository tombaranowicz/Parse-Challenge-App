//
//  ChallengeTableViewCell.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/13/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "ChallengeTableViewCell.h"
#import <UIImageView+AFNetworking.h>
#import <NSDate+TimeAgo.h>
#import <FontAwesomeKit/FontAwesomeKit.h>

@interface ChallengeTableViewCell()
{
    UILabel *titleLabel;
    UILabel *timeLabel;
    UILabel *commentsLabel;
    UILabel *likesLabel;
    UILabel *solutionsLabel;
    UILabel *descriptionLabel;
}
@end

@implementation ChallengeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;

        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, screenWidth-20, 25)];
        titleLabel.textColor = [UIColor darkGrayColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [self.contentView addSubview:titleLabel];
        
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(titleLabel.frame)+5, screenWidth-20, 33)];
        descriptionLabel.numberOfLines = 2;
        descriptionLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        descriptionLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:descriptionLabel];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(descriptionLabel.frame), self.contentView.frame.size.width-20, 25)];
        view.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:view];

        solutionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 60, 15)];
        solutionsLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        solutionsLabel.textColor = [Utils themeColor];
        [view addSubview:solutionsLabel];
        
        commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(66, 5, 60, 15)];
        commentsLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        commentsLabel.textColor = [Utils themeColor];
        [view addSubview:commentsLabel];
        
        likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(127, 5, 58, 15)];
        likesLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        likesLabel.textColor = [Utils themeColor];
        [view addSubview:likesLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(190, 5, screenWidth-210, 15)];
        timeLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.textAlignment = NSTextAlignmentRight;
        [view addSubview:timeLabel];
    }
    
    return self;
}

- (void) updateWithChallenge:(Challenge *)challenge
{
    titleLabel.text = challenge.title;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    
    FAKFontAwesome *icon = [FAKFontAwesome commentIconWithSize:12.0f];
    NSMutableAttributedString *muAtrStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ", [Utils abbreviateNumber:challenge.commentsCount]]];
    [muAtrStr appendAttributedString:[icon attributedString]];
    commentsLabel.attributedText = muAtrStr;
    
    icon = [FAKFontAwesome thumbsUpIconWithSize:12.0f];
    muAtrStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ", [Utils abbreviateNumber:challenge.likesCount]]];
    [muAtrStr appendAttributedString:[icon attributedString]];
    likesLabel.attributedText = muAtrStr;
    
    icon = [FAKFontAwesome cameraIconWithSize:12.0f];
    muAtrStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ", [Utils abbreviateNumber:challenge.solutionsCount]]];
    [muAtrStr appendAttributedString:[icon attributedString]];
    solutionsLabel.attributedText = muAtrStr;

    icon = [FAKFontAwesome clockOIconWithSize:12.0f];
    muAtrStr = [[NSMutableAttributedString alloc]initWithAttributedString:[icon attributedString]];
    [muAtrStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", [challenge.createDate timeAgo]]]];
    timeLabel.attributedText = muAtrStr;
    
    descriptionLabel.frame = CGRectMake(10, CGRectGetMaxY(titleLabel.frame)+5, screenWidth-20, 33);
    descriptionLabel.text = challenge.details;
    [descriptionLabel sizeToFit];
}

@end
