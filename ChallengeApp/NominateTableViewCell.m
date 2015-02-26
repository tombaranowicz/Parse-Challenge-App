//
//  NominateTableViewCell.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 11/6/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "NominateTableViewCell.h"
#import <FontAwesomeKit/FAKFontAwesome.h>

@interface NominateTableViewCell()
{
    UILabel *userNameLabel;
    PFImageView *userImageView;
}
@end

@implementation NominateTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        
        userImageView = [[PFImageView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
        userImageView.contentMode = UIViewContentModeScaleAspectFill;
        userImageView.clipsToBounds = YES;
        userImageView.layer.cornerRadius = 20.f;
        userImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        userImageView.layer.borderWidth = 0.5f;
        [self.contentView addSubview:userImageView];
        
        userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, screenWidth-70, 50)];
        userNameLabel.textColor = [UIColor darkGrayColor];
        userNameLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        [self.contentView addSubview:userNameLabel];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        self.contentView.backgroundColor = [Utils themeColor];
        userNameLabel.textColor = [UIColor whiteColor];
    } else {
        self.contentView.backgroundColor = [UIColor whiteColor];
        userNameLabel.textColor = [Utils themeColor];
    }
}

- (void) setUser:(PFUser *)user
{
    DLOG(@"set user for cell %@", user);
    userNameLabel.text = user[@"username"];
    
    FAKFontAwesome *userIcon = [FAKFontAwesome userIconWithSize:30.0f];
    [userIcon addAttribute:NSForegroundColorAttributeName value:[Utils themeColor]];
    userImageView.image = [userIcon imageWithSize:CGSizeMake(40, 40)];
    
    userImageView.file = user[@"profileImageThumb"];
    [userImageView loadInBackground];
}

@end
