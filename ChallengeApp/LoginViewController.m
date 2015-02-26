//
//  LoginViewController.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/10/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "LoginViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Log In";
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 100, self.view.frame.size.width-20, 50)];
    
    [button setTitle:@"FACEBOOK" forState:UIControlStateNormal];
    button.backgroundColor = [Utils themeColor];
    [button addTarget:self action:@selector(facebookLoginHandler) forControlEvents:UIControlEventTouchUpInside];
    [button addShadow];
    [self.view addSubview:button];
    
    button = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(button.frame)+20, self.view.frame.size.width-20, 50)];
    [button setTitle:@"CONTINUE AS GUEST" forState:UIControlStateNormal];
    button.backgroundColor = [Utils themeColor];
    [button addTarget:self action:@selector(showDashboard) forControlEvents:UIControlEventTouchUpInside];
    [button addShadow];
    [self.view addSubview:button];
}

- (void) facebookLoginHandler
{
    [self showIndeterminateProgressWithTitle:@"user authentication..."];
    NSArray *permissionsArray = @[ @"user_about_me", @"publish_actions", @"user_location", @"user_friends"];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
            [self hideIndeterminateProgress];
        } else {
            if (user.isNew) {
                DLOG(@"new user %@", user);
                
                FBRequest *request = [FBRequest requestForMe];
                [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    if (!error) {
                        NSDictionary *userData = (NSDictionary *)result;
                        DLOG(@"downloaded user data %@", userData);
                        
                        PFUser *me = [PFUser currentUser];
                        me[@"facebookId"] = userData[@"id"];
                        [me saveInBackground];
                        me[@"username"] = userData[@"name"];
                        [me saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (error) {
                                DLOG(@"user save error %@", error);
                            } else {
                                DLOG(@"saved user");
                            }
                            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                        }];
                    } else {
                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    }
                }];
            } else {
                DLOG(@"logged in %@", user);
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }];
}


+ (void)getUsernameWithCompletionBlock:(void(^)(NSString *username))handler {
    if([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){ //<-
        FBRequest *request = [FBRequest requestForMe];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSDictionary *userData = (NSDictionary *)result;
                NSString *name = userData[@"name"];
                handler(name);
            }}];
    } else {
        handler([[PFUser currentUser] username]);
    }
}

- (void) showDashboard
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate switchToDashboard];
}

@end
