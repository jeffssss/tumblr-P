//
//  AppDelegate.h
//  tumblr-p
//
//  Created by JiFeng on 16/1/7.
//  Copyright © 2016年 jeffsss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BKPasscodeView/BKPasscodeLockScreenManager.h>
#import "CredentialsManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,BKPasscodeLockScreenManagerDelegate,BKPasscodeViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readwrite) CredentialsManager *   credentialsManager;

@end

