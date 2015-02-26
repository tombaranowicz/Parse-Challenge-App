//
//  BaseViewController.h
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/10/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JGProgressHUD/JGProgressHUD.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "UIView+Custom.h"
#import <iAd/iAd.h>

@interface BaseViewController : UIViewController
{
    BOOL requestInProgress;
    BOOL forceRefresh;
    CGFloat screenWidth;
    BOOL userLoggedIn;
    JGProgressHUD *HUD;
}

-(void)showModalViewController:(UIViewController *)modalViewController;
-(void)closeModalViewController;

- (void) showIndeterminateProgressWithTitle:(NSString *)title;
- (void) hideIndeterminateProgress;

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
-(void)showAlertWithMessage:(NSString *)message;
@end
