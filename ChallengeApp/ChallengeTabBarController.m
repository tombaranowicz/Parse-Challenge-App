//
//  ChallengeTabBarController.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/12/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "ChallengeTabBarController.h"
#import "BaseNavigationController.h"

#import "GlobalChallengesViewController.h"
#import "MyProfileViewController.h"
#import "ExploreChallengesViewController.h"

@interface ChallengeTabBarController ()
{
    MyProfileViewController *myProfileVc;
    GlobalChallengesViewController *globalChallengesVc;
    ExploreChallengesViewController *exploreChallengesVc;
}
@end

@implementation ChallengeTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    myProfileVc = [[MyProfileViewController alloc] init];
    BaseNavigationController *myNavigationController = [[BaseNavigationController alloc] initWithRootViewController:myProfileVc];
    myNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"user.png"] tag:1];
    
    exploreChallengesVc = [[ExploreChallengesViewController alloc] init];
    BaseNavigationController *exploreNavigationController = [[BaseNavigationController alloc] initWithRootViewController:exploreChallengesVc];
    exploreNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"search.png"] tag:2];
    
    globalChallengesVc = [[GlobalChallengesViewController alloc] init];
    BaseNavigationController *globalNavigationController = [[BaseNavigationController alloc] initWithRootViewController:globalChallengesVc];
    globalNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"globe.png"] tag:3];

    self.viewControllers = @[globalNavigationController, exploreNavigationController, myNavigationController];
}

@end
