//
//  DashboardPhotoCell.m
//  tumblr-p
//
//  Created by JiFeng on 16/1/23.
//  Copyright © 2016年 jeffsss. All rights reserved.
//

#import "DashboardTableViewCell.h"

#define topViewHeight 40
#define cardWidth kScreenWidth - 8*2//两边留8的空
#define pictureCutLineWidth 2
#define sourceTagViewHeight 20
#define bottomBarHeight 30

@interface DashboardTableViewCell ()

//所有内容放在卡片里面
@property(nonatomic,strong) UIView          *cardView;

//上方的view
@property(nonatomic,strong) UIView          *topView;
@property(nonatomic,strong) UIImageView     *posterAvatar;
@property(nonatomic,strong) UILabel         *blogNameLabel;
@property(nonatomic,strong) UIButton        *followBtn;

//中间的内容view,暂时只有picture
@property(nonatomic,strong) UIView          *middleContentView;

////tag label暂时不允许点击
//@property(nonatomic,strong) UILabel         *tagLabel;
////source label 暂时不允许点击
//@property(nonatomic,strong) UILabel         *sourceLabel;
@property(nonatomic,strong) UILabel         *sourceAndTagLabel;

@property(nonatomic,strong) UIView          *bottomBarView;
@property(nonatomic,strong) UIButton        *notesNumberBtn;
@property(nonatomic,strong) UIButton        *reblogBtn;
@property(nonatomic,strong) UIButton        *likeBtn;

@end

@implementation DashboardTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier Data:(NSDictionary *)data{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        //根据内容计算高度
        
        //cardView 先不指定frame大小
        _cardView = [[UIView alloc] init];
        _cardView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_cardView];
        
        /* topview相关 */
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cardWidth, topViewHeight)];
        [_cardView addSubview:_topView];
        
        _posterAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
        [_topView addSubview:_posterAvatar];
        
        _blogNameLabel = [[UILabel alloc] init];
        _blogNameLabel.textColor = UIColorHex(0x3b3b3b);
        _blogNameLabel.font = [UIFont systemFontOfSize:16.0];
        _blogNameLabel.textAlignment = NSTextAlignmentCenter;
        [_topView addSubview:_blogNameLabel];
        
        _followBtn = [[UIButton alloc] initWithFrame:CGRectMake(cardWidth -8 - 60, 8, 60, topViewHeight - 8*2)];
        _followBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_followBtn setTitleColor:UIColorHex(0x696969) forState:UIControlStateNormal];
        [_followBtn setTitleColor:UIColorHex(0xcfcfcf) forState:UIControlStateHighlighted];
        [_topView addSubview:_followBtn];
        
        /* middleview相关 */
        _middleContentView = [[UIView alloc] init];//高度需要计算
        [_cardView addSubview:_middleContentView];
        
        /* middleview下方的label */
        _sourceAndTagLabel = [[UILabel alloc] init];
        _sourceAndTagLabel.textColor = UIColorHex(0xB5B5B5);
        _sourceAndTagLabel.font = [UIFont systemFontOfSize:14.0];
        [_cardView addSubview:_sourceAndTagLabel];
        
        /* bottomBarView相关 */
        _bottomBarView = [[UIView alloc] init];
//        _bottomBarView.backgroundColor = UIColorHex(0xCFCFCF);
        [_cardView addSubview:_bottomBarView];
        
        _notesNumberBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, bottomBarHeight)];
        [_notesNumberBtn setTitleColor:UIColorHex(0x9C9C9C) forState:UIControlStateNormal];
        [_notesNumberBtn setTitleColor:UIColorHex(0xcfcfcf) forState:UIControlStateHighlighted];
        [_notesNumberBtn setTarget:self action:@selector(onNotesNumberBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomBarView addSubview:_notesNumberBtn];
        
        _likeBtn = [[UIButton alloc] initWithFrame:CGRectMake(cardWidth - 30, 5, 20, 20)];
        [_bottomBarView addSubview:_likeBtn];
        
        _reblogBtn = [[UIButton alloc] initWithFrame:CGRectMake(_likeBtn.left - 30, 5, 20, 20)];
        [_reblogBtn setBackgroundImage:[UIImage imageNamed:@"reblog"] forState:UIControlStateNormal];
        [_reblogBtn setTarget:self action:@selector(onReblogBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomBarView addSubview:_reblogBtn];
        
        [self loadData:data];
    }
    return self;
}

-(void)loadData:(NSDictionary *)data{
    //topview
    [self.posterAvatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.tumblr.com/v2/blog/%@.tumblr.com/avatar",data[@"blog_name"]]] placeholderImage:[UIImage imageNamed:@"avatar_placeholder.jpg"]];
    
    self.blogNameLabel.text = data[@"blog_name"];
    CGSize blogNameLabelSize = [_blogNameLabel sizeThatFits:CGSizeMake(MAXFLOAT, topViewHeight)];
    self.blogNameLabel.frame = CGRectMake(self.posterAvatar.right, 0, blogNameLabelSize.width + 16, topViewHeight);
    
    if([data[@"followed"] boolValue]){
        [self changeToFollow:YES];
    } else {
        [self changeToFollow:NO];
    }
    
    //middleView
    if([data[@"type"] isEqualToString:@"photo"]){
        //修改middleview的frame
        CGFloat middelHeight = [self getHeightAndcreateImageViews:self.middleContentView WithData:data];
        self.middleContentView.frame = CGRectMake(0, self.topView.bottom, self.topView.width, middelHeight);
        
        //取出每个imageview，放图片
        NSArray *photos = data[@"photos"];
        for(UIImageView *imageview in self.middleContentView.subviews){
            NSInteger index = imageview.tag - CommonTagBase;
            NSArray *alt_sizes =photos[index][@"alt_sizes"];
            //选择适当大小的图并放进imageview
            [self setImageWithImageView:imageview AndAltSizes:alt_sizes];
        }
    } else {
        NSLog(@"获取到其他type的内容");
    }
    
    //source tag label
    NSMutableString *labelText = [[NSMutableString alloc] init];
    if(data[@"source_title"]){
        [labelText appendFormat:@"Source: %@ ",data[@"source_title"]];
    }
    for(NSString *tag in data[@"tags"]){
        [labelText appendFormat:@"#%@ ",tag];
    }
    self.sourceAndTagLabel.text = [labelText copy];
    self.sourceAndTagLabel.frame = CGRectMake(5, self.middleContentView.bottom, self.middleContentView.width, sourceTagViewHeight);
    
    //bottomBarView
    self.bottomBarView.frame = CGRectMake(0, self.sourceAndTagLabel.bottom, self.sourceAndTagLabel.width, bottomBarHeight);
    
    [self.notesNumberBtn setTitle:[NSString stringWithFormat:@"%@ notes",data[@"note_count"]] forState:UIControlStateNormal];
    
    if([data[@"liked"] boolValue]){
        [self changeToLike:YES];
    } else {
        [self changeToLike:NO];
    }
    
    //改变cardView高度
    self.cardView.frame = CGRectMake(8, 8, cardWidth, self.bottomBarView.bottom);
    self.cardView.layer.cornerRadius = 4.0;
    //改变self的高度
    self.frame = CGRectMake(0, 0, kScreenWidth, self.cardView.bottom + 2);
    
}

-(CGFloat)getHeight{
    return self.height ;
}

-(void)changeToFollow:(BOOL)willFollow{
    if(willFollow){
        [self.followBtn setTitle:@"Unfollow" forState:UIControlStateNormal];
        [self.followBtn setTarget:self action:@selector(onUnfollowBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.followBtn setTitle:@"Follow" forState:UIControlStateNormal];
        [self.followBtn setTarget:self action:@selector(onFollowBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)changeToLike:(BOOL)willLike{
    if(willLike){
        [self.likeBtn setBackgroundImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
        [self.likeBtn setTarget:self action:@selector(onUnLikeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.likeBtn setBackgroundImage:[UIImage imageNamed:@"like_outline"] forState:UIControlStateNormal];
        [self.likeBtn setTarget:self action:@selector(onLikeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - SEL

-(void)onUnfollowBtnClick:(id)sender{
    if([self.delegate respondsToSelector:@selector(onFollowBtnClick:willFollow:)]){
        [self.delegate onFollowBtnClick:self willFollow:NO];
    }
//    [[AlertPopupManager sharedManager] postTips:@"unfollow!" withType:@"done"];
}

-(void)onFollowBtnClick:(id)sender{
    if([self.delegate respondsToSelector:@selector(onFollowBtnClick:willFollow:)]){
        [self.delegate onFollowBtnClick:self willFollow:YES];
    }
}

-(void)onNotesNumberBtnClick:(id)sender{
    //TODO:使用delegate
}

-(void)onLikeBtnClick:(id)sender{
    //TODO:使用delegate
}

-(void)onUnLikeBtnClick:(id)sender{
    //TODO:使用delegate
}

-(void)onReblogBtnClick:(id)sender{
    //TODO:使用delegate
}

-(void)tapImage:(UITapGestureRecognizer *)sender{
    if([self.delegate respondsToSelector:@selector(onImageViewTapped:imageView:andIndex:)]){
        [self.delegate onImageViewTapped:self imageView:(UIImageView *)sender.view andIndex:(sender.view.tag - CommonTagBase)];
    }
}
#pragma mark - private
-(CGFloat)getHeightAndcreateImageViews:(UIView *)parentView WithData:(NSDictionary *)data{
    //清除原有的
    [parentView removeAllSubviews];
    
    //解析string
    NSString *layoutString = data[@"photoset_layout"];
    
    //如果只有一张图，则没有photoset_layout参数
    if(nil == layoutString){
        layoutString = @"1";
    }
    
    __block CGFloat currentHeight = 0;
    __block int currentImage = 0;
    NSArray *photos = data[@"photos"];
    
    // 遍历字符串，按字符来遍历。每个字符将通过block参数中的substring传出
    [layoutString enumerateSubstringsInRange:NSMakeRange(0, layoutString.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        
        //当前行有多少个图
        int imageViewNumber = [substring intValue];
        //计算当前行的图的宽度
        CGFloat imageWidth = (cardWidth - (imageViewNumber - 1) * pictureCutLineWidth ) / imageViewNumber;
        //计算当前行的图的高度
        CGFloat imageHeight = imageWidth * [photos[currentImage][@"original_size"][@"height"] floatValue] / [photos[currentImage][@"original_size"][@"width"] floatValue];
        //创建一行的imageview,给予正确的frame以及tag。
        for(int i = 0 ; i<imageViewNumber ; i++){
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*(imageWidth + pictureCutLineWidth), currentHeight, imageWidth, imageHeight)];
            imageView.tag = CommonTagBase + currentImage;
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
            // 内容模式
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            
            currentImage ++ ;
            [parentView addSubview:imageView];
        }
        //当进行下一行时，更改currentHeight的值
        currentHeight += imageHeight + pictureCutLineWidth;
    }];
    
    //返回高度
    return currentHeight - pictureCutLineWidth;
}

//选出和imageview相近大小的alt_size,然后设置imageview的图
-(void)setImageWithImageView:(UIImageView *)imageView AndAltSizes:(NSArray *)altSizes{

    //只有一个altsize，直接使用咯
    if(altSizes.count == 1){
        [imageView sd_setImageWithURL:[NSURL URLWithString:altSizes[0][@"url"]] placeholderImage:[UIImage imageNamed:@"pic_placeholder.png"]];
        return;
    }
    
    
    //策略，使用第一个小于等于imageview的width
    NSDictionary *smallerImage;
    for(int i = 0 ; i < altSizes.count ; i++){
        smallerImage = altSizes[i];
        
        //如果imageView的width比smallerImage大了，说明上一个image，即biggerimage是合适的
        if([smallerImage[@"width"] floatValue] <= 2*imageView.width){
            [imageView sd_setImageWithURL:[NSURL URLWithString:smallerImage[@"url"]] placeholderImage:[UIImage imageNamed:@"pic_placeholder.png"]];
            return;
        }
    }
    
    //只能使用最小的咯
    [imageView sd_setImageWithURL:[NSURL URLWithString:smallerImage[@"url"]] placeholderImage:[UIImage imageNamed:@"pic_placeholder.png"]];
}


@end
