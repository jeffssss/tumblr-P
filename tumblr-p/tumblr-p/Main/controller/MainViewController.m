//
//  MainViewController.m
//  tumblr-p
//
//  Created by JiFeng on 16/1/19.
//  Copyright © 2016年 jeffsss. All rights reserved.
//

#import "MainViewController.h"
#import "MJRefresh.h"
#import "LoginViewController.h"
#import "DashboardTableViewCell.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVPlayerViewController.h>
#import <BBBadgeBarButtonItem/BBBadgeBarButtonItem.h>
#import "VideoPlayerViewController.h"
#import <VKVideoPlayer/VKVideoPlayerViewController.h>

//当用sinceid拉数据的个数到达该值时，重新拉取所有数据。
#define refreshDataLimitLine 30

@interface MainViewController ()<UITableViewDataSource,UITableViewDelegate,DashboardCellDelegate>
//主tableview
@property(nonatomic,strong) UITableView     *mainTableView;
//当前的offset，用于计算下拉
@property(nonatomic,assign) NSInteger       offset;//暂时是不需要offset参数
//当前的每页数量
@property(nonatomic,assign) NSInteger       limit;//默认为20
//当前接收的种类
@property(nonatomic,copy)   NSString        *currentType;//TODO:暂时仅photo
//当前最近一个post的id
@property(nonatomic,assign) NSInteger       sinceId;

//tableview数据源
@property(nonatomic,strong) NSMutableArray  *dataArray;

//menu
@property(nonatomic,strong) NSArray         *menuCellArray;
@property(nonatomic,assign) BOOL            menuCellHidden;
@property(nonatomic,strong) UIView          *maskView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    NSLog(@"main view did load;");
    [super viewDidLoad];
    //设置bar style
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = NO;
    
    self.title = @"Tumblr-P";
    self.view.backgroundColor = [UIColor redColor];
    
    //注销
    UIImage *logoutImg = [UIImage imageNamed:@"logout_icon"];
    UIBarButtonItem *logoutBtn = [[UIBarButtonItem alloc] initWithImage:logoutImg style:UIBarButtonItemStylePlain target:self action:@selector(onlogoutBtnClick)];
    //选种类
    BBBadgeBarButtonItem *typeBtn = [[BBBadgeBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"type_all"] style:UIBarButtonItemStylePlain target:self action:@selector(onTypeBtnClick:)];
    [self.navigationItem setRightBarButtonItems:@[typeBtn,logoutBtn]];
    
    
    
    //初始化参数在这里：
    self.offset = 0;
    self.limit = 20;
    self.currentType = @"";
    self.dataArray = [[NSMutableArray alloc] init];
    self.menuCellHidden = YES;
    [self mainTableView];
    //打印一下token
    NSLog(@"token:%@\nsecret:%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"],[[NSUserDefaults standardUserDefaults] objectForKey:@"access_token_secret"]);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@" main viewWillAppear");
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@" main viewDidAppear");
}
#pragma mark - getter
-(UITableView *)mainTableView{
    if(nil == _mainTableView){
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64) style:UITableViewStylePlain];
        _mainTableView.backgroundColor = UIColorHex(0x36465d);
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.allowsSelection = NO;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_mainTableView];
        
        //设置下拉刷新,拉取since当前最新的数据。
        //规则：1.如果since_id为空，则正常拉取数据.
        //2.用since_id拉取30条，如果拉满30条，则需要更新数据源，这时候重新用offset=0去拉数据。否则直接加上数据。
        WeakSelf
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            StrongSelf
            if(!sSelf.sinceId){
                //sinceid不存在,即之前没有数据
                NSDictionary *params = [sSelf buildDashBoardInfoParamsWithLimit:sSelf.limit
                                                                         Offset:0
                                                                           Type:sSelf.currentType
                                                                        SinceId:0];
                
                
                [[TMAPIClient sharedInstance] dashboard:params callback:^(id result, NSError *error) {
                    StrongSelf
                    
                    [sSelf.mainTableView.mj_header endRefreshing];
                    
                    if(error){
                        //失败
                        //如果为401 说明没有认证。
                        if(error.code == 401){
                            [[AlertPopupManager sharedManager] postTips:@"认证过期，请重新登录" withType:@"error"];
                            [sSelf directToLoginViewController];
                        } else {
                            [[AlertPopupManager sharedManager] postTips:[NSString stringWithFormat:@"错误%d %@",(int)error.code,error.domain] withType:@"error"];
                        }
                        return;
                    }
                    //成功
                    NSArray *posts = [result objectForKey:@"posts"];
                    
                    sSelf.offset = posts.count;
                    if(posts.count > 0){
                        sSelf.sinceId = [posts[0][@"id"] integerValue];
                    }
                    sSelf.dataArray = [posts mutableCopy];
                    [sSelf.mainTableView reloadData];
                }];
                return;
            }
            //之前已经有数据了。用sinceid拉取新的，limit设为30
            NSDictionary *params = [sSelf buildDashBoardInfoParamsWithLimit:refreshDataLimitLine
                                                                     Offset:0
                                                                       Type:sSelf.currentType
                                                                    SinceId:sSelf.sinceId];
            [[TMAPIClient sharedInstance] dashboard:params callback:^(id result, NSError *error) {
                StrongSelf
                
                
                
                if(error){
                    
                    [sSelf.mainTableView.mj_header endRefreshing];
                    
                    if(error.code == 401){
                        [[AlertPopupManager sharedManager] postTips:@"认证过期，请重新登录" withType:@"error"];
                        [sSelf directToLoginViewController];
                    }
                    return ;
                }
                //成功
                NSArray *posts = [result objectForKey:@"posts"];
                if(posts.count<refreshDataLimitLine){
                    
                    //正常的在前面加内容
                    sSelf.offset = sSelf.offset + posts.count;
                    if(posts.count > 0){
                        sSelf.sinceId = [posts[0][@"id"] integerValue];
                    }
                    [sSelf.dataArray insertObjects:posts atIndex:0];
                    
                    [sSelf.mainTableView reloadData];
                    
                    [sSelf.mainTableView.mj_header endRefreshing];
                    
                } else {
                    //重新加载数据源
                    NSDictionary *newparams = [sSelf buildDashBoardInfoParamsWithLimit:sSelf.limit
                                                                                Offset:0
                                                                                  Type:sSelf.currentType
                                                                               SinceId:0];
                    [[TMAPIClient sharedInstance] dashboard:newparams callback:^(id result, NSError *error) {
                        StrongSelf
                        
                        [sSelf.mainTableView.mj_header endRefreshing];
                        
                        //失败
                        if(error){
                            if(error.code == 401){
                                [[AlertPopupManager sharedManager] postTips:@"认证过期，请重新登录" withType:@"error"];
                                [sSelf directToLoginViewController];
                            }
                            return ;
                        }
                        
                        //成功
                        NSArray *posts = [result objectForKey:@"posts"];
                        
                        sSelf.offset = posts.count;
                        if(posts.count > 0){
                            sSelf.sinceId = [posts[0][@"id"] integerValue];
                        } else {
                            sSelf.sinceId = 0;
                        }
                        sSelf.dataArray = [posts mutableCopy];
                        
                        [sSelf.mainTableView reloadData];
                    }];
                }
            }];
        }];
        header.stateLabel.textColor = [UIColor whiteColor];
        header.lastUpdatedTimeLabel.textColor = [UIColor whiteColor];
        _mainTableView.mj_header = header;
        
        //设置上拉继续加载
        MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            StrongSelf
            NSDictionary *params = [sSelf buildDashBoardInfoParamsWithLimit:sSelf.limit
                                                                     Offset:sSelf.offset
                                                                       Type:sSelf.currentType
                                                                    SinceId:0];
            [[TMAPIClient sharedInstance] dashboard:params callback:^(id result, NSError *error) {
                StrongSelf
                
                [sSelf.mainTableView.mj_footer endRefreshing];
                
                if(error){
                    //失败
                    if(error.code == 401){
                        [[AlertPopupManager sharedManager] postTips:@"认证过期，请重新登录" withType:@"error"];
                        [sSelf directToLoginViewController];
                    }
                    return ;
                }
                
                //成功
                NSArray *posts = [result objectForKey:@"posts"];
                sSelf.offset = sSelf.offset + posts.count;
                [sSelf.dataArray addObjectsFromArray:posts];
                [sSelf.mainTableView reloadData];
                
            }];
        }];
        footer.stateLabel.textColor = [UIColor whiteColor];
        _mainTableView.mj_footer = footer;
        
    }
    return _mainTableView;
}

-(NSArray *)menuCellArray{
    if(nil == _menuCellArray){
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:2];
        //暂时就仅仅选photo和video all
        UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth*2.0/3.0 -20, -50, kScreenWidth/3.0 + 20, 50)];
        [btn1 setTitle:@"Photo" forState:UIControlStateNormal];
        [btn1 setTarget:self action:@selector(onMenuCellClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn1 setBackgroundColor:UIColorHex(0x4F94CD)];
        btn1.layer.cornerRadius = 4.0;
        [self.view addSubview:btn1];
        
        UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth*2.0/3.0 -20, -50, kScreenWidth/3.0 + 20, 50)];
        [btn2 setTitle:@"Video" forState:UIControlStateNormal];
        [btn2 setTarget:self action:@selector(onMenuCellClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn2 setBackgroundColor:UIColorHex(0x8B0A50)];
        btn2.layer.cornerRadius = 4.0;
        [self.view addSubview:btn2];
        
        UIButton *btn3 = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth*2.0/3.0 -20, -50, kScreenWidth/3.0 + 20, 50)];
        [btn3 setTitle:@"All" forState:UIControlStateNormal];
        [btn3 setTarget:self action:@selector(onMenuCellClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn3 setBackgroundColor:UIColorHex(0x36465d)];
        btn3.layer.cornerRadius = 4.0;
        [self.view addSubview:btn3];
        
        [array addObject:btn1];
        [array addObject:btn2];
        [array addObject:btn3];
        
        _menuCellArray = [array copy];
        self.menuCellHidden = YES;
    }
    return _menuCellArray;
}

-(UIView *)maskView{
    if(nil == _maskView){
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _maskView.backgroundColor = RGBA(0, 0, 0, 0.4);
        _maskView.userInteractionEnabled = YES;
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
            [self hideMenu];
            [self.maskView removeFromSuperview];
        }]];
    }
    return _maskView;
}
#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"dashboardCell";
    DashboardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[DashboardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID Data:self.dataArray[indexPath.row]];
    }
    [cell loadData:self.dataArray[indexPath.row]];
    cell.delegate = self;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [(DashboardTableViewCell *)[self tableView:self.mainTableView cellForRowAtIndexPath:indexPath] getHeight];
}

#pragma mark - DashboardCellDelegate

-(void)onFollowBtnClick:(DashboardTableViewCell *)cell willFollow:(BOOL)willFollow{
    NSIndexPath *indexPath = [self.mainTableView indexPathForCell:cell];
    NSMutableDictionary *post = [self.dataArray[indexPath.row] mutableCopy];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WeakSelf
    if(willFollow){
        //调用关注接口
        [[TMAPIClient sharedInstance] follow:post[@"blog_name"] callback:^(id result, NSError *error) {
            StrongSelf
            [MBProgressHUD hideHUDForView:sSelf.view animated:YES];
            if(error){
                //失败
                //如果为401 说明没有认证。
                if(error.code == 401){
                    [[AlertPopupManager sharedManager] postTips:@"认证过期，请重新登录" withType:@"error"];
                    [sSelf directToLoginViewController];
                } else {
                    [[AlertPopupManager sharedManager] postTips:[NSString stringWithFormat:@"错误%d",(int)error.code] withType:@"error"];
                }
                return;
            }
            //成功
            NSLog(@"%@",result);
            [[AlertPopupManager sharedManager] postTips:@"Follow成功!" withType:@"done"];
            //改变数据源
            post[@"followed"] = [NSNumber numberWithBool:YES];
            [sSelf.dataArray replaceObjectAtIndex:indexPath.row withObject:[post copy]];
            //改变UI
            [cell changeToFollow:YES];
        }];
    } else {
        //调用取关接口
        [[TMAPIClient sharedInstance] unfollow:post[@"blog_name"] callback:^(id result, NSError *error) {
            StrongSelf
            [MBProgressHUD hideHUDForView:sSelf.view animated:YES];
            if(error){
                //失败
                //如果为401 说明没有认证。
                if(error.code == 401){
                    [[AlertPopupManager sharedManager] postTips:@"认证过期，请重新登录" withType:@"error"];
                    [sSelf directToLoginViewController];
                } else {
                    [[AlertPopupManager sharedManager] postTips:[NSString stringWithFormat:@"错误%d",(int)error.code] withType:@"error"];
                }
                return;
            }
            //成功
//            NSLog(@"%@",result);
            [[AlertPopupManager sharedManager] postTips:@"Unfollow成功!" withType:@"done"];
            //改变数据源
            post[@"followed"] = [NSNumber numberWithBool:NO];
            [sSelf.dataArray replaceObjectAtIndex:indexPath.row withObject:[post copy]];
            //改变UI
            [cell changeToFollow:NO];
        }];
    }
    
    
}

-(void)onNotesNumberBtnClick:(DashboardTableViewCell *)cell{
    
}

-(void)onLikeBtnClick:(DashboardTableViewCell *)cell willLike:(BOOL)willLike{
    NSIndexPath *indexPath = [self.mainTableView indexPathForCell:cell];
    NSMutableDictionary *post = [self.dataArray[indexPath.row] mutableCopy];
    WeakSelf
    if(willLike){
        //关注
        [[TMAPIClient sharedInstance] like:post[@"id"] reblogKey:post[@"reblog_key"] callback:^(id result, NSError *error) {
            StrongSelf
            if(error){
                //失败
                //如果为401 说明没有认证。
                if(error.code == 401){
                    [[AlertPopupManager sharedManager] postTips:@"认证过期，请重新登录" withType:@"error"];
                    [sSelf directToLoginViewController];
                } else {
                    [[AlertPopupManager sharedManager] postTips:[NSString stringWithFormat:@"错误%d",(int)error.code] withType:@"error"];
                }
                return;
            }
            
            //成功
            //改变数据源
            post[@"liked"] = [NSNumber numberWithBool:YES];
            [sSelf.dataArray replaceObjectAtIndex:indexPath.row withObject:[post copy]];
            //改变ui
            [cell changeToLike:YES];
        }];
    } else {
        //取关
        [[TMAPIClient sharedInstance] unlike:post[@"id"] reblogKey:post[@"reblog_key"] callback:^(id result, NSError *error) {
            StrongSelf
            if(error){
                //失败
                //如果为401 说明没有认证。
                if(error.code == 401){
                    [[AlertPopupManager sharedManager] postTips:@"认证过期，请重新登录" withType:@"error"];
                    [sSelf directToLoginViewController];
                } else {
                    [[AlertPopupManager sharedManager] postTips:[NSString stringWithFormat:@"错误%d",(int)error.code] withType:@"error"];
                }
                return;
            }
            
            //成功
            //改变数据源
            post[@"liked"] = [NSNumber numberWithBool:NO];
            [sSelf.dataArray replaceObjectAtIndex:indexPath.row withObject:[post copy]];
            //改变ui
            [cell changeToLike:NO];
        }];
    }
}

-(void)onReblogBtnClick:(DashboardTableViewCell *)cell{
    
}

-(void)onImageViewTapped:(DashboardTableViewCell *)cell imageView:(UIImageView *)imageView andIndex:(NSInteger)index{
    NSIndexPath *indexPath = [self.mainTableView indexPathForCell:cell];
    NSArray *photos = self.dataArray[indexPath.row][@"photos"];
    
    NSInteger count = [photos count];
    // 1.封装图片数据
    NSMutableArray *newPhotos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0 ; i < count; i++) {
        //获取origin size
        NSString *originUrl = photos[i][@"original_size"][@"url"];
        
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:originUrl]; // 图片路径
        photo.srcImageView = imageView; // 来源于哪个UIImageView
        [newPhotos addObject:photo];
    }
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = index; // 弹出相册时显示的第一张图片是？
    browser.photos = newPhotos; // 设置所有的图片
    [browser show];
}

-(void)onTextSeeDetailBtnClick:(DashboardTableViewCell *)cell{
        //TODO:点击跳转到详细页面
}

-(void)onVideoImageTapped:(DashboardTableViewCell *)cell{
    NSIndexPath *indexPath = [self.mainTableView indexPathForCell:cell];
    NSDictionary *post = self.dataArray[indexPath.row];

    if(nil == post[@"video_url"] || [post[@"video_url"] isEqualToString:@""]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:post[@"permalink_url"]]];
    } else {
        AVPlayerViewController *moviePlayer = [[AVPlayerViewController alloc] init];
        AVPlayer *player = [AVPlayer playerWithURL:[NSURL URLWithString:post[@"video_url"]]];
        moviePlayer.player = player;
        [self presentViewController:moviePlayer animated:YES completion:^{
            [moviePlayer.player play];
        }];
    }
}

#pragma mark - SEL
-(void)onlogoutBtnClick{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"access_token"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"access_token_secret"];
    [[AlertPopupManager sharedManager] postTips:@"已退出账号" withType:@"none"];
    [self directToLoginViewController];
}

-(void)onTypeBtnClick:(UIButton *)sender{
    if(self.menuCellHidden){
        [self showMenu];
    } else {
        [self hideMenu];
    }
}
-(void)onMenuCellClick:(UIButton *)sender{
    self.offset = 0;
    self.limit = 20;
    self.sinceId = 0;
    if([sender.titleLabel.text isEqualToString:@"All"]){
        self.currentType = @"";
    } else if([sender.titleLabel.text isEqualToString:@"Photo"]){
        self.currentType = @"photo";
    } else if([sender.titleLabel.text isEqualToString:@"Video"]){
        self.currentType = @"video";
    }
    self.mainTableView.backgroundColor = sender.backgroundColor;
    [self hideMenu];
    [self.mainTableView.mj_header beginRefreshing];
}

-(void)showMenu {
    [self.view addSubview:self.maskView];
    self.menuCellHidden = NO;

    for(int i = 0 ; i < self.menuCellArray.count ; i++){
        UIButton *button = self.menuCellArray[i];
        [UIView animateWithDuration:0.4
                              delay:0.1*i
             usingSpringWithDamping:1.0
              initialSpringVelocity:4.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect frame = button.frame;
                             frame.origin.y =i*50;
                             button.frame = frame;
                             [self.view bringSubviewToFront:button];
                         }
                         completion:^(BOOL finished){
                         }];
    }
    [UIView commitAnimations];
    
}

- (void) hideMenu {
    self.menuCellHidden = YES;
    [self.maskView removeFromSuperview];
    for(int i = 0 ; i < self.menuCellArray.count ; i++){
        UIButton *button = self.menuCellArray[i];
        [UIView animateWithDuration:0.4
                              delay:0.0
             usingSpringWithDamping:1.0
              initialSpringVelocity:4.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect frame = button.frame;
                             frame.origin.y = -50;
                             button.frame = frame;
                         }
                         completion:^(BOOL finished){
                         }];
    }
    [UIView commitAnimations];
    
}

#pragma mark - private
//构建请求参数
-(NSDictionary *)buildDashBoardInfoParamsWithLimit:(NSInteger)limit Offset:(NSInteger)offset Type:(NSString *)type SinceId:(NSInteger)sinceId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(limit){
        [params setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    }
    if(offset){
        [params setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    }
    if(nil != type && ![type isEqualToString:@""]){
        [params setObject:type forKey:@"type"];
    }
    if(sinceId){
        [params setObject:[NSNumber numberWithInteger:sinceId] forKey:@"since_id"];
    }
    NSLog(@"********************\ndashboard params:%@\n********************\n",params);
    return [params copy];
}

-(void)directToLoginViewController{
    //跳转到注册页面
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    UINavigationController *loginVCNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [UIView transitionFromView:self.view
                        toView:loginVC.view
                      duration:1
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:^(BOOL finished){
                        [[UIApplication sharedApplication].delegate window].rootViewController = loginVCNav;
                    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
