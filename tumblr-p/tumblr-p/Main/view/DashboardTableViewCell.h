//
//  DashboardPhotoCell.h
//  tumblr-p
//
//  Created by JiFeng on 16/1/23.
//  Copyright © 2016年 jeffsss. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DashboardCellDelegate <NSObject>

-(void)onFollowBtnClick:(id)sender willFollow:(BOOL)willFollow;

-(void)onNotesNumberBtnClick:(id)sender;

-(void)onLikeBtnClick:(id)sender willLike:(BOOL)willLike;

-(void)onReblogBtnClick:(id)sender;

@end

@interface DashboardTableViewCell : UITableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier Data:(NSDictionary *)data;

-(void)loadData:(NSDictionary *)data;

-(CGFloat)getHeight;

@end
