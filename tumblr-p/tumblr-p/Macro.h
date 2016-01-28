//
//  Macro.h
//  tumblr-p
//
//  Created by JiFeng on 16/1/22.
//  Copyright © 2016年 jeffsss. All rights reserved.
//

#ifndef Macro_h
#define Macro_h

#define WeakSelf   __typeof(&*self) __weak wSelf = self;
#define StrongSelf __typeof(&*self) __strong sSelf = wSelf;

#define CommonTagBase 1000

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

#define RGBA(r, g, b, a)                    [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r, g, b)                        RGBA(r, g, b, 1.0f)

#endif /* Macro_h */
