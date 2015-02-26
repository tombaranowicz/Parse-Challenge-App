//
//  UserProfileViewController.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/18/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "UserProfileViewController.h"
#import "ChallengesViewController.h"
#import "SolutionsViewController.h"
#import <FontAwesomeKit/FAKFontAwesome.h>

@interface UserProfileViewController ()
{
    UILabel *userNameLabel;
    UILabel *challengesLabel;
    UILabel *solutionsLabel;
    PFImageView *userImageView;
    
}
@end

@implementation UserProfileViewController

- (id)initWithPFUser:(PFUser *)user_
{
    self = [super init];
    if (self) {
        user = user_;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"User Profile";

    userImageView = [[PFImageView alloc] initWithFrame:CGRectMake(10, 75, 70, 70)];
    userImageView.contentMode = UIViewContentModeScaleAspectFill;
    userImageView.clipsToBounds = YES;
    userImageView.layer.cornerRadius = 35.f;
    userImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    userImageView.layer.borderWidth = 0.5f;
    [self.view addSubview:userImageView];
    
    FAKFontAwesome *userIcon = [FAKFontAwesome userIconWithSize:50.0f];
    [userIcon addAttribute:NSForegroundColorAttributeName value:[Utils themeColor]];
    userImageView.image = [userIcon imageWithSize:CGSizeMake(70, 70)];
    
    userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 75, screenWidth-110, 17)];
    userNameLabel.textColor = [UIColor darkGrayColor];
    userNameLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    [self.view addSubview:userNameLabel];
    
    challengesLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 100, 75, 40)];
    challengesLabel.numberOfLines = 2;
    challengesLabel.textColor = [UIColor darkGrayColor];
    challengesLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    challengesLabel.textAlignment = NSTextAlignmentCenter;
    challengesLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(challengesLabelHandler)];
    [challengesLabel addGestureRecognizer:tap];
    [self.view addSubview:challengesLabel];
    
    solutionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(190, 100, 75, 40)];
    solutionsLabel.numberOfLines = 2;
    solutionsLabel.textColor = [UIColor darkGrayColor];
    solutionsLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    solutionsLabel.textAlignment = NSTextAlignmentCenter;
    solutionsLabel.userInteractionEnabled = YES;
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(solutionsLabelHandler)];
    [solutionsLabel addGestureRecognizer:tap];
    [self.view addSubview:solutionsLabel];
    
    PFQuery *query = [PFUser query];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 60*60;
    [query whereKey:@"objectId" equalTo:user.objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        NSLog(@"GOT USER DATA: %@", object);
        userNameLabel.text = object[@"username"];
        userImageView.file = object[@"profileImageThumb"];
        challengesLabel.text = [NSString stringWithFormat:@"%d\nchallenges", [object[@"challenges"] intValue]];
        solutionsLabel.text = [NSString stringWithFormat:@"%d\nattempts", [object[@"solutions"] intValue]];
        [userImageView loadInBackground];
    }];
}

- (void) challengesLabelHandler {
    ChallengesViewController *vc = [[ChallengesViewController alloc] initForUser:user];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) solutionsLabelHandler {
    SolutionsViewController *vc = [[SolutionsViewController alloc] initForUser:user];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
