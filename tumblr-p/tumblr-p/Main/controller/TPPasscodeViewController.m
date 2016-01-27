//
//  TPPasscodeViewController.m
//  tumblr-p
//
//  Created by JiFeng on 16/1/27.
//  Copyright © 2016年 jeffsss. All rights reserved.
//

#import "TPPasscodeViewController.h"

@implementation TPPasscodeViewController

- (void)customizePasscodeInputView:(BKPasscodeInputView *)aPasscodeInputView
{
    [super customizePasscodeInputView:aPasscodeInputView];
    
    if ([aPasscodeInputView.passcodeField isKindOfClass:[BKPasscodeField class]]) {
        BKPasscodeField *passcodeField = (BKPasscodeField *)aPasscodeInputView.passcodeField;
        passcodeField.imageSource = self;
        passcodeField.dotSize = CGSizeMake(32, 32);
    }
}

#pragma mark - BKPasscodeFieldImageSource

- (UIImage *)passcodeField:(BKPasscodeField *)aPasscodeField dotImageAtIndex:(NSInteger)aIndex filled:(BOOL)aFilled
{
    if (aFilled) {
        return [UIImage imageNamed:@"p_fill"];
    } else {
        return [UIImage imageNamed:@"p_unfill"];
    }
}

@end

