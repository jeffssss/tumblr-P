//
//  DashboardPhotoCell.h
//  tumblr-p
//
//  Created by JiFeng on 16/1/23.
//  Copyright © 2016年 jeffsss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashboardTableViewCell : UITableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier Data:(NSDictionary *)data;

-(void)loadData:(NSDictionary *)data;

-(CGFloat)getHeight;

@end
