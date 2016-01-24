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

#endif /* Macro_h */
