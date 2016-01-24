//
//  CMAlertPopupManager.m
//  canmou_c
//
//  Created by JiFeng on 15/11/5.
//  Copyright © 2015年 Canmou. All rights reserved.
//

#import "AlertPopupManager.h"



@interface AlertPopupManager ()

@end

@implementation AlertPopupManager

+(AlertPopupManager *)sharedManager{
    static AlertPopupManager * managerInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        managerInstance = [[AlertPopupManager alloc] init];
    });
    
    return managerInstance;
}

-(void)postTips:(NSString *)title withType:(NSString *)type{
    AlertPopupView *popupView = [AlertPopupView alertViewWithTitle:title
                                                        titleColor:[UIColor whiteColor]
                                                     titleFontSize:20.0
                                                             width:150
                                                            height:150
                                                   backgroundImage:nil
                                                   backgroundColor:[UIColor blackColor]
                                                      cornerRadius:10.0
                                                       shadowAlpha:0.1
                                                             alpha:0.8
                                                       contentView:nil type:@"done"];
    KLCPopup *pop = [KLCPopup popupWithContentView:popupView
                                            showType:KLCPopupShowTypeGrowIn
                                         dismissType:KLCPopupDismissTypeGrowOut
                                            maskType:KLCPopupMaskTypeDimmed
                            dismissOnBackgroundTouch:NO
                               dismissOnContentTouch:NO];
    [pop showWithDuration:1.5];
}

@end


@interface AlertPopupView ()


@end

@implementation AlertPopupView

+ (AlertPopupView *)alertViewWithTitle:(NSString *)title
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
                      type:(NSString *)type{
    //get window size and position
    CGRect windowRect = [[UIScreen mainScreen] bounds];
    //create the main alert view centered
    //with custom width and height
    //and custom background
    //and custom corner radius
    //and custom opacity
    AlertPopupView *alertView = [[AlertPopupView alloc] initWithFrame:CGRectMake(windowRect.size.width/2.0 - width/2.0,
                                                                 windowRect.size.height/2.0 - height/2.0,
                                                                 width, height)];
    //set background color
    //if a background image is used, use the image instead.
    alertView.backgroundColor = backgroundColor;
    if (backgroundImage) {
        alertView.backgroundColor = [[UIColor alloc] initWithPatternImage:backgroundImage];
    }
    alertView.layer.cornerRadius = cornerRadius;
    alertView.alpha = alpha;
    
    //create the title label centered with multiple lines
    //and custom color
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = titleColor;
    titleLabel.font = [UIFont systemFontOfSize:fontsize];
    //set the number of lines to 0 (unlimited)
    //set a maximum size to the label
    //then get the size that fits the maximum size
    titleLabel.numberOfLines = 0;
    CGSize requiredSize = [titleLabel sizeThatFits:CGSizeMake(width - 8, height - 8)];
    titleLabel.frame = CGRectMake(width/2.0 - requiredSize.width / 2.0, height - requiredSize.height - 8, requiredSize.width, requiredSize.height);
    [alertView addSubview:titleLabel];

    if(nil == type || [type isEqualToString:@""] || [type isEqualToString:@"none"]){
        titleLabel.center = CGPointMake(width/2.0, height/2.0);
        return alertView;
    }
    //if it is, set the custom view
    UIView *content = contentView ? contentView : [self contentViewFromType:type];
    CGFloat newSize = (titleLabel.top)/2;
    content.frame = CGRectMake( (width - newSize)/2.0, newSize/2.0, newSize, newSize);
    content.centerY = (titleLabel.top)/2.0;
//    content.frame = CGRectApplyAffineTransform(content.frame, CGAffineTransformMakeTranslation(width/2 - content.frame.size.width/2, titleLabel.frame.origin.y + titleLabel.frame.size.height + 8));
    
    [alertView addSubview:content];
    return alertView;
}

+ (UIView *)contentViewFromType:(NSString *)type {
    UIImageView *content = [[UIImageView alloc] init];
    content.frame = CGRectMake(0, 6, 30, 30);
    if([type isEqualToString:@"done"]){
        content.image = [UIImage imageNamed:@"checkmark"];
    } else if([type isEqualToString:@"error"]){
        content.image = [UIImage imageNamed:@"cross"];
    } else if([type isEqualToString:@"warning"]){
        content.image = [UIImage imageNamed:@"warning"];
    } else {
        content.image = [UIImage imageNamed:@"pic_placeholder.png"];
    }
    return content;
}

@end
