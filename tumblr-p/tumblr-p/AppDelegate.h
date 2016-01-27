//
//  AppDelegate.h
//  tumblr-p
//
//  Created by JiFeng on 16/1/7.
//  Copyright © 2016年 jeffsss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BKPasscodeView/BKPasscodeLockScreenManager.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,BKPasscodeLockScreenManagerDelegate,BKPasscodeViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

