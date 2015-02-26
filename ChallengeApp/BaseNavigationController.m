//
//  BaseNavigationController.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/12/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = NO;
}

@end
