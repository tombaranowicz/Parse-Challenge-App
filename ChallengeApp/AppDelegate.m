//
//  AppDelegate.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/10/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "AppDelegate.h"
#import "BaseNavigationController.h"
#import "ViewController.h"
#import "LoginViewController.h"
#import "ChallengeTabBarController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [Parse setApplicationId:@"sBwVGWHCJZcMh0dCWYdN6rd1RCXcKzkRbNAWdtbC"
                  clientKey:@"CpwPPJQZwtVFPdChsUaGKaCYGb5AYCu399FedQqv"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFFacebookUtils initializeFacebook];

    self.window.rootViewController = [[ChallengeTabBarController alloc] init];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[UINavigationBar appearance] setBarTintColor:[Utils themeColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UITabBar appearance] setTintColor:[Utils themeColor]];
    
    return YES;
}

// ****************************************************************************
// App switching methods to support Facebook Single Sign-On.
// ****************************************************************************
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [[PFFacebookUtils session] close];
}

- (void) switchToDashboard {
    ChallengeTabBarController *tabBar = (ChallengeTabBarController *)self.window.rootViewController;
    tabBar.selectedIndex = 0;
}
@end
