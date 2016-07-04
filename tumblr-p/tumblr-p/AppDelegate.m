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
#import "ShadowsocksRunner.h"
#import "CustomHTTPProtocol.h"

NSString *const BKPasscodeKeychainServiceName = @"TPPasscodeService";


@interface AppDelegate ()<CustomHTTPProtocolDelegate>

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

    //web proxy
    NSDictionary *dict = @{
                           @"SOCKSEnable" : @1,
                           @"SOCKSProxy" : @"127.0.0.1",
                           @"SOCKSPort" : @8864,
                           @"SOCKSProxyAuthenticated" : @0,
                           };

    [CustomHTTPProtocol setProxyConfig:dict];
    self.credentialsManager = [[CredentialsManager alloc] init];
    [CustomHTTPProtocol setDelegate:self];
    if (YES) {
        [CustomHTTPProtocol start];
    }
    //background proxy
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
    }];
    dispatch_queue_t proxy = dispatch_queue_create("proxy", NULL);
    dispatch_async(proxy, ^{
        [self runProxy];
    });

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
    [TMAPIClient sharedInstance].OAuthConsumerKey = @"";
    [TMAPIClient sharedInstance].OAuthConsumerSecret = @"";
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

#pragma mark - Run proxy

- (void)runProxy {
    [ShadowsocksRunner reloadConfig];
    for (; ;) {
        if ([ShadowsocksRunner runProxy]) {
            sleep(1);
        } else {
            sleep(2);
        }
    }
}
/*! Called by an CustomHTTPProtocol instance to ask the delegate whether it's prepared to handle
 *  a particular authentication challenge.  Can be called on any thread.
 *  \param protocol The protocol instance itself; will not be nil.
 *  \param protectionSpace The protection space for the authentication challenge; will not be nil.
 *  \returns Return YES if you want the -customHTTPProtocol:didReceiveAuthenticationChallenge: delegate
 *  callback, or NO for the challenge to be handled in the default way.
 */

- (BOOL)customHTTPProtocol:(CustomHTTPProtocol *)protocol canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    
    assert(protocol != nil);
#pragma unused(protocol)
    assert(protectionSpace != nil);
    
    return [[protectionSpace authenticationMethod] isEqual:NSURLAuthenticationMethodServerTrust];
}

/*! Called by an CustomHTTPProtocol instance to request that the delegate process on authentication
 *  challenge. Will be called on the main thread. Unless the challenge is cancelled (see below)
 *  the delegate must eventually resolve it by calling -resolveAuthenticationChallenge:withCredential:.
 *  \param protocol The protocol instance itself; will not be nil.
 *  \param challenge The authentication challenge; will not be nil.
 */

- (void)customHTTPProtocol:(CustomHTTPProtocol *)protocol didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    OSStatus            err;
    NSURLCredential *   credential;
    SecTrustRef         trust;
    SecTrustResultType  trustResult;
    
    // Given our implementation of -customHTTPProtocol:canAuthenticateAgainstProtectionSpace:, this method
    // is only called to handle server trust authentication challenges.  It evaluates the trust based on
    // both the global set of trusted anchors and the list of trusted anchors returned by the CredentialsManager.
    
    assert(protocol != nil);
    assert(challenge != nil);
    assert([[[challenge protectionSpace] authenticationMethod] isEqual:NSURLAuthenticationMethodServerTrust]);
    assert([NSThread isMainThread]);
    
    credential = nil;
    
    // Extract the SecTrust object from the challenge, apply our trusted anchors to that
    // object, and then evaluate the trust.  If it's OK, create a credential and use
    // that to resolve the authentication challenge.  If anything goes wrong, resolve
    // the challenge with nil, which continues without a credential, which causes the
    // connection to fail.
    
    trust = [[challenge protectionSpace] serverTrust];
    if (trust == NULL) {
        assert(NO);
    } else {
        err = SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef) self.credentialsManager.trustedAnchors);
        if (err != noErr) {
            assert(NO);
        } else {
            err = SecTrustSetAnchorCertificatesOnly(trust, false);
            if (err != noErr) {
                assert(NO);
            } else {
                err = SecTrustEvaluate(trust, &trustResult);
                if (err != noErr) {
                    assert(NO);
                } else {
                    if ( (trustResult == kSecTrustResultProceed) || (trustResult == kSecTrustResultUnspecified) ) {
                        credential = [NSURLCredential credentialForTrust:trust];
                        assert(credential != nil);
                    }
                    //credential = [NSURLCredential credentialForTrust:trust];
                }
            }
        }
    }
    
    [protocol resolveAuthenticationChallenge:challenge withCredential:credential];
}

/*! Called by an CustomHTTPProtocol instance to cancel an issued authentication challenge.
 *  Will be called on the main thread.
 *  \param protocol The protocol instance itself; will not be nil.
 *  \param challenge The authentication challenge; will not be nil; will match the challenge
 *  previously issued by -customHTTPProtocol:canAuthenticateAgainstProtectionSpace:.
 */

- (void)customHTTPProtocol:(CustomHTTPProtocol *)protocol didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
}

/*! Called by the CustomHTTPProtocol to log various bits of information.
 *  Can be called on any thread.
 *  \param protocol The protocol instance itself; nil to indicate log messages from the class itself.
 *  \param format A standard NSString-style format string; will not be nil.
 *  \param arguments Arguments for that format string.
 */

- (void)customHTTPProtocol:(CustomHTTPProtocol *)protocol logWithFormat:(NSString *)format arguments:(va_list)arguments {
    
    return;
    
    NSString *  prefix;
    
    // protocol may be nil
    assert(format != nil);
    
    if (protocol == nil) {
        prefix = @"protocol ";
    } else {
        prefix = [NSString stringWithFormat:@"protocol %p ", protocol];
    }
    [self logWithPrefix:prefix format:format arguments:arguments];
}


- (void)logWithPrefix:(NSString *)prefix format:(NSString *)format arguments:(va_list)arguments
{
    assert(prefix != nil);
    assert(format != nil);
    NSString *body = [[NSString alloc] initWithFormat:format arguments:arguments];
    NSLog(@"%@ - %@", prefix, body);
    //    if (sAppDelegateLoggingEnabled) {
    //        NSTimeInterval  now;
    //        ThreadInfo *    threadInfo;
    //        NSString *      str;
    //        char            elapsedStr[16];
    //
    //        now = [NSDate timeIntervalSinceReferenceDate];
    //
    //        threadInfo = [self threadInfoForCurrentThread];
    //
    //        str = [[NSString alloc] initWithFormat:format arguments:arguments];
    //        assert(str != nil);
    //
    //        snprintf(elapsedStr, sizeof(elapsedStr), "+%.1f", (now - sAppStartTime));
    //
    //        fprintf(stderr, "%3zu %s %s%s\n", (size_t) threadInfo.number, elapsedStr, [prefix UTF8String], [str UTF8String]);
    //    }
}
@end
