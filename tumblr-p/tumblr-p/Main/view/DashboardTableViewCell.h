//
//  DashboardPhotoCell.h
//  tumblr-p
//
//  Created by JiFeng on 16/1/23.
//  Copyright © 2016年 jeffsss. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DashboardTableViewCell;

@protocol DashboardCellDelegate <NSObject>

-(void)onFollowBtnClick:(DashboardTableViewCell *)cell willFollow:(BOOL)willFollow;

-(void)onNotesNumberBtnClick:(DashboardTableViewCell *)cell;

-(void)onLikeBtnClick:(DashboardTableViewCell *)cell willLike:(BOOL)willLike;

-(void)onReblogBtnClick:(DashboardTableViewCell *)cell;

-(void)onImageViewTapped:(DashboardTableViewCell *)cell imageView:(UIImageView *)imageView andIndex:(NSInteger)index;
@end

@interface DashboardTableViewCell : UITableViewCell

@property(nonatomic,weak) id<DashboardCellDelegate> delegate;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier Data:(NSDictionary *)data;

-(void)loadData:(NSDictionary *)data;

-(CGFloat)getHeight;

-(void)changeToFollow:(BOOL)willFollow;

-(void)changeToLike:(BOOL)willLike;

@end
