//
//  AppDelegate.m
//  tumblr-p
//
//  Created by JiFeng on 16/1/7.
//  Copyright © 2016年 jeffsss. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "LoginViewController.h"
#import <BKPasscodeView/BKPasscodeLockScreenManager.h>
#import "TPPasscodeViewController.h"

NSString *const BKPasscodeKeychainServiceName = @"TPPasscodeService";


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self registeTumblr];
    
    [self checkLogin];
    
    //设置密码
    [[NSUserDefaults standardUserDefaults] setObject:@"1213" forKey:@"privacy_password"];
    
    //设置锁屏
    [[BKPasscodeLockScreenManager sharedManager] setDelegate:self];
    
    [self.window makeKeyAndVisible];
    
    //开始就显示密码登陆,太快了会报错：`Unbalanced calls to begin/end appearance transitions for`
    [self performSelector:@selector(checkPassword) withObject:self afterDelay:0.5];
    
    return YES;
}

-(void)checkPassword{
    //开始就显示密码登陆
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"privacy_password"]){
        TPPasscodeViewController *viewController = [[TPPasscodeViewController alloc] initWithNibName:nil bundle:nil];
        viewController.type = BKPasscodeViewControllerCheckPasscodeType;
        viewController.delegate = self;
        viewController.passcodeStyle = BKPasscodeInputViewNumericPasscodeStyle;
        viewController.touchIDManager = [[BKTouchIDManager alloc] initWithKeychainServiceName:BKPasscodeKeychainServiceName];
        viewController.touchIDManager.promptText = @"使用指纹解锁";
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        
        [self.window.rootViewController presentViewController:navController animated:NO completion:nil];
        [navController.view.superview bringSubviewToFront:navController.view];
    }
}

-(void)checkLogin{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"]){
        MainViewController *vc = [[MainViewController alloc] init];
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:vc];
    } else {
        LoginViewController *vc = [[LoginViewController alloc] init];
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:vc];;
    }
}

-(void)registeTumblr{
    [TMAPIClient sharedInstance].OAuthConsumerKey = @"PBwhtXxAZCnmVyzBmcc6fJG7EUXE41F5js8MJFOohuxSAMWD1G";
    [TMAPIClient sharedInstance].OAuthConsumerSecret = @"nItXj5DFC1VBwk3qEEiIJUjW6ngKqQI1lGPRjyS1eA8bXo0z6Q";
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"]){
        [TMAPIClient sharedInstance].OAuthToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
        [TMAPIClient sharedInstance].OAuthTokenSecret = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token_secret"];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [[TMAPIClient sharedInstance] handleOpenURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground");
    [[BKPasscodeLockScreenManager sharedManager] showLockScreen:NO];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"applicationWillTerminate");
}

- (BOOL)lockScreenManagerShouldShowLockScreen:(BKPasscodeLockScreenManager *)aManager
{
    return YES;   // return NO if you don't want to present lock screen.
}

- (UIViewController *)lockScreenManagerPasscodeViewController:(BKPasscodeLockScreenManager *)aManager{
    TPPasscodeViewController *viewController = [[TPPasscodeViewController alloc] initWithNibName:nil bundle:nil];
    viewController.type = BKPasscodeViewControllerCheckPasscodeType;
    viewController.delegate = self;
    viewController.passcodeStyle = BKPasscodeInputViewNumericPasscodeStyle;
    viewController.touchIDManager = [[BKTouchIDManager alloc] initWithKeychainServiceName:BKPasscodeKeychainServiceName];
    viewController.touchIDManager.promptText = @"使用指纹解锁";
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    return navController;
}
#pragma mark -  BKPasscodeViewControllerDelegate

/**
 * Tells the delegate that passcode is created or authenticated successfully.
 */
- (void)passcodeViewController:(BKPasscodeViewController *)aViewController didFinishWithPasscode:(NSString *)aPasscode{
    [aViewController dismissViewControllerAnimated:YES completion:nil];
}

/**
 * Ask the delegate to verify that a passcode is correct. You must call the resultHandler with result.
 * You can check passcode asynchronously and show progress view (e.g. UIActivityIndicator) in the view controller if authentication takes too long.
 * You must call result handler in main thread.
 */
- (void)passcodeViewController:(BKPasscodeViewController *)aViewController authenticatePasscode:(NSString *)aPasscode resultHandler:(void(^)(BOOL succeed))aResultHandler{
    if ([aPasscode isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"privacy_password"]]) {
        aResultHandler(YES);
    } else {
        aResultHandler(NO);
    }
}
@end
