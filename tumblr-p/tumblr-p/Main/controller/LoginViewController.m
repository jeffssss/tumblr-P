//
//  LoginViewController.m
//  tumblr-p
//
//  Created by JiFeng on 16/1/19.
//  Copyright © 2016年 jeffsss. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"
#import "SettingViewController.h"

@interface LoginViewController ()<UIWebViewDelegate, NJKWebViewProgressDelegate>

@property(nonatomic,strong) UIView          *loginView;

@property(nonatomic,strong) UITextField     *usernameTextField;
@property(nonatomic,strong) UITextField     *passwordTextField;

@property(nonatomic,strong) UIButton        *loginBtn;

@property(nonatomic,strong) UIButton        *oatuhBtn;

@property(nonatomic,strong) UIWebView       *webView;

@property(nonatomic,strong) NJKWebViewProgressView *progressView;

@property(nonatomic,strong) NJKWebViewProgress *progressProxy;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置bar style
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = NO;
//    [self.navigationController setNavigationBarHidden:YES];
    UIBarButtonItem *settingBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onSettingBtnClick)];
    self.title = @"登陆";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationItem setRightBarButtonItems:@[settingBtn]];
    [self loginView];
}

#pragma mark - getter
-(UIView *)loginView{
    if(nil == _loginView){
        _loginView = [[UIView alloc] initWithFrame:CGRectMake(10, 30, kScreenWidth - 20, 100)];
        [self.view addSubview:_loginView];
        
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        CGColorRef color = CGColorCreate(colorSpaceRef, (CGFloat[]){0x0/255.0, 0x0/255.0, 0x0/255.0,1});
        
        //添加两个输入框
        _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, _loginView.width, 30)];
        _usernameTextField.placeholder = @" 请输入您的登陆账号";
        _usernameTextField.textColor = UIColorHex(0x3b3b3b);
        _usernameTextField.layer.borderColor = color;
        _usernameTextField.layer.borderWidth = 1.0;
        _usernameTextField.layer.cornerRadius = 4.0;
        [_loginView addSubview:_usernameTextField];
        
        _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, _usernameTextField.bottom + 20, _loginView.width, 30)];
        _passwordTextField.placeholder = @" 请输入密码";
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.layer.borderColor = color;
        _passwordTextField.layer.borderWidth = 1.0;
        _passwordTextField.layer.cornerRadius = 4.0;
        [_loginView addSubview:_passwordTextField];
        
        //添加按钮
        _loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(_loginView.left, _loginView.bottom + 10, _loginView.width, 40)];
        [_loginBtn setTitle:@"登陆" forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_loginBtn setTarget:self action:@selector(onLoginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [_loginBtn.layer setBorderColor:color];
        [_loginBtn.layer setBorderWidth:1.0];
        _loginBtn.layer.cornerRadius = 4.0;
        [self.view addSubview:_loginBtn];
        
        //oatuhBtn
        _oatuhBtn = [[UIButton alloc] initWithFrame:CGRectMake(_loginView.left, _loginBtn.bottom + 30, _loginView.width, 40)];
        [_oatuhBtn setTitle:@"Tumblr登陆" forState:UIControlStateNormal];
        [_oatuhBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_oatuhBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_oatuhBtn setTarget:self action:@selector(onOauthBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [_oatuhBtn.layer setBorderColor:color];
        [_oatuhBtn.layer setBorderWidth:1.0];
        _oatuhBtn.layer.cornerRadius = 4.0;
        [self.view addSubview:_oatuhBtn];
        
    }
    return _loginView;
}

#pragma mark - sel
-(void)onLoginBtnClick:(id)sender{
    NSLog(@"login");
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"暂时无法使用此方法登陆" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [alert show];
    return;
//    //检查是否输入
//    if([self.usernameTextField.text isEqualToString:@""]){
//        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入用户名" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alert show];
//        return;
//    }
//    if([self.passwordTextField.text isEqualToString:@""]){
//        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入密码" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alert show];
//        return;
//    }
//    //菊花滚起来
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    
//    [[TMAPIClient sharedInstance] xAuth:self.usernameTextField.text password:self.passwordTextField.text callback:^(NSError *error) {
//        NSLog(@"登陆失败,%@",error);
//        
//        //取消菊花
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        });
//    }];
}

-(void)onOauthBtnClick:(id)sender{
    NSLog(@"oauth login");

    CGFloat progressBarHeight = 2.f;
    
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, progressBarHeight, kScreenWidth, kScreenHeight - 64 - progressBarHeight)];
    self.webView.scalesPageToFit = YES;//自动对页面进行缩放以适应屏幕
    [self.view addSubview:self.webView];
    
    self.progressProxy = [[NJKWebViewProgress alloc] init];
    self.progressProxy.webViewProxyDelegate = self;
    self.progressProxy.progressDelegate = self;
    self.webView.delegate = self.progressProxy;
    self.progressView = [[NJKWebViewProgressView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, progressBarHeight)];
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.progressView];
    
    WeakSelf
    [[TMAPIClient sharedInstance] authenticate:@"jeffssss.tumblrp" webView:self.webView callback:^(NSError *error) {
        //无论成功与否，都要先去掉webview
        StrongSelf
        [sSelf.webView removeFromSuperview];
        sSelf.webView = nil;
        [sSelf.progressView removeFromSuperview];
        sSelf.webView = nil;
        
        if (error){
            NSLog(@"Authentication failed: %@ %@", error, [error description]);

            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"登陆失败！" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        else{
            NSLog(@"Authentication successful!");
            [[AlertPopupManager sharedManager] postTips:@"登陆成功" withType:@"done"];
            
            //暂存用户的 token
            [[NSUserDefaults standardUserDefaults] setObject:[TMAPIClient sharedInstance].OAuthToken forKey:@"access_token"];
            [[NSUserDefaults standardUserDefaults] setObject:[TMAPIClient sharedInstance].OAuthTokenSecret forKey:@"access_token_secret"];
            
            //跳转到main
            MainViewController *mainViewController = [[MainViewController alloc] init];
            UINavigationController *mainControllerNav =  [[UINavigationController alloc] initWithRootViewController:mainViewController];
            
            [[UIApplication sharedApplication].delegate window].rootViewController = mainControllerNav;
        }

    }];
    
}


#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [self.progressView setProgress:progress animated:YES];
    NSLog(@"progress:%f",progress);
}

-(void)onSettingBtnClick{
    [self.navigationController pushViewController:[[SettingViewController alloc] init] animated:YES];
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
