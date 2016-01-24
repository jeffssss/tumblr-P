//
//  CMAlertPopupManager.h
//  canmou_c
//
//  Created by JiFeng on 15/11/5.
//  Copyright © 2015年 Canmou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertPopupManager : NSObject

+(AlertPopupManager *)sharedManager;

-(void)postTips:(NSString *)title withType:(NSString *)type;

@end


@interface AlertPopupView : UIView
+(AlertPopupView *)alertViewWithTitle:(NSString *)title
                   titleColor:(UIColor *)titleColor
                titleFontSize:(CGFloat)fontsize
                        width:(CGFloat)width
                       height:(CGFloat)height
              backgroundImage:(UIImage *)backgroundImage
              backgroundColor:(UIColor *)backgroundColor
                 cornerRadius:(CGFloat)cornerRadius
                  shadowAlpha:(CGFloat)shadowAlpha
                        alpha:(CGFloat)alpha
                  contentView:(UIView *)contentView
                          type:(NSString *)type;
@end