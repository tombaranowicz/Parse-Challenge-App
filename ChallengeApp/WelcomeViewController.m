//
//  WelcomeViewController.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 11/20/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeModalViewController)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.navigationController.navigationBar.frame)+20, screenWidth-20, 300)];
    label.numberOfLines = 0;
    label.textColor = [UIColor darkGrayColor];
    label.textAlignment = NSTextAlignmentJustified;
    label.text = @"Hi!\n\nWelcome in Let's Challenge Me app, thanks to this application you can create new challenges, post your attempts, comment other users and nominate your friends! Sounds funny? Sure, but remember, be care of yourself, if you want to beat some challenge think of your health and security at first! App developer is not responsible for any damage caused to you or any other people!\n\nRemember, it's just a game, don't risk your health! Have a good time using our app :)";
    [self.view addSubview:label];
}

@end
