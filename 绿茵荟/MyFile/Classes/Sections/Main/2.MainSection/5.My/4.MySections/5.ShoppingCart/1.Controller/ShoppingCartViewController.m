//
//  ShoppingCartViewController.m
//  绿茵荟
//
//  Created by mac_hao on 2017/3/21.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "ShoppingCartViewController.h"

@interface ShoppingCartViewController ()

@end

@implementation ShoppingCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
}

#pragma mark - 重写返回按钮事件
//返回上一个页面
-(void)popUpViewController{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - tabbar显示与隐藏
//此view出现时隐藏tabBar
- (void)viewWillAppear: (BOOL)animated{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSArray *views = [app.window.rootViewController.view subviews];
    for(id v in views){
        if([v isKindOfClass:[UITabBar class]]){
            [(UITabBar *)v setHidden:YES];
        }
    }
    
}
//此view消失时还原tabBar
- (void)viewWillDisappear: (BOOL)animated{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSArray *views = [app.window.rootViewController.view subviews];
    for(id v in views){
        if([v isKindOfClass:[UITabBar class]]){
            [(UITabBar *)v setHidden:NO];
        }
    }
    
}

@end
