//
//  BaseViewController.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/10/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()
{

}
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        userLoggedIn = YES;
    }
}

-(void)showModalViewController:(UIViewController *)modalViewController
{
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:modalViewController];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

-(void)closeModalViewController
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) showIndeterminateProgressWithTitle:(NSString *)title
{
    [HUD dismiss];
    HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleExtraLight];
    HUD.textLabel.text = title;
    [HUD showInView:self.view];
}

- (void) hideIndeterminateProgress
{
    [HUD dismiss];
    HUD = nil;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)showAlertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: PROJECT_NAME
                          message: message
                          delegate: nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil];
    [alert show];
}

@end
