//
//  SettingViewController.m
//  tumblr-p
//
//  Created by JiFeng on 16/6/27.
//  Copyright © 2016年 jeffsss. All rights reserved.
//

#import "SettingViewController.h"
#import "ShadowsocksRunner.h"

@interface SettingViewController ()

@property(nonatomic,strong) UISwitch *proxySwitch;

@property(nonatomic,strong) UITextField *proxyIp;

@property(nonatomic,strong) UITextField *proxyPort;

@property(nonatomic,strong) UITextField *proxyPassword;

@property(nonatomic,strong) UITextField *proxyEncryption;//之后换成选择

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置bar style
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = NO;
    //    [self.navigationController setNavigationBarHidden:YES];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneBtnClick)];
    self.title = @"设置";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationItem setRightBarButtonItems:@[doneBtn]];
    [self initLayout];
}

-(void)initLayout{
    self.proxySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(20, 70, 60, 30)];
    [self.proxySwitch setOn:NO];
    [self.proxySwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.proxySwitch];
    
    self.proxyIp = [[UITextField alloc] initWithFrame:CGRectMake(20, self.proxySwitch.bottom + 20, 200, 30)];
    self.proxyIp.placeholder = @"input your ip";
    [self.view addSubview:self.proxyIp];
    
    self.proxyPort = [[UITextField alloc] initWithFrame:CGRectMake(20, self.proxyIp.bottom + 20, 200, 30)];
    self.proxyPort.placeholder = @"input your port";
    [self.view addSubview:self.proxyPort];
    
    self.proxyPassword = [[UITextField alloc] initWithFrame:CGRectMake(20, self.proxyPort.bottom + 20, 200, 30)];
    self.proxyPassword.placeholder = @"input your password";
    [self.view addSubview:self.proxyPassword];
    
    self.proxyEncryption = [[UITextField alloc] initWithFrame:CGRectMake(20, self.proxyPassword.bottom + 20, 200, 30)];
    self.proxyEncryption.placeholder = @"input your encryption";
    [self.view addSubview:self.proxyEncryption];

}

-(void)switchAction:(UISwitch *)uiswitch{
    BOOL isButtonOn = [uiswitch isOn];
    if(isButtonOn){
        
    } else {
        
    }
}

-(void)onDoneBtnClick{
    //保存设置
    [[NSUserDefaults standardUserDefaults] setObject:self.proxyIp.text forKey:kShadowsocksIPKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.proxyPort.text forKey:kShadowsocksPortKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.proxyPassword.text forKey:kShadowsocksPasswordKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.proxyEncryption.text forKey:kShadowsocksEncryptionKey];
    
    //如果代理正在运行 可能需要修改配置啥的
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
