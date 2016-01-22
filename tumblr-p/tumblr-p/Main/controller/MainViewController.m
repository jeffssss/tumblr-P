//
//  MainViewController.m
//  tumblr-p
//
//  Created by JiFeng on 16/1/19.
//  Copyright © 2016年 jeffsss. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()



@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置bar style
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = NO;
    
    self.title = @"Tumblr-P";
    self.view.backgroundColor = [UIColor redColor];
    
}


-(void)getDashBoardInfo{
    
    [[TMAPIClient sharedInstance] dashboard:<#(NSDictionary *)#> callback:^(id, NSError *error) {
        //
    }]
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
