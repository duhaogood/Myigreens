//
//  CheckUpdateVC.m
//  绿茵荟
//
//  Created by mac on 2017/6/24.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import "CheckUpdateVC.h"
#import "MainVC.h"
#import "StartViewController.h"
#import "AFNetworking.h"
@interface CheckUpdateVC ()

@end


#define MY_APP_ID @"1238065310"//应用对应appid-开票:1178537125====绿茵荟-1238065310
@implementation CheckUpdateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    UIImageView * imgV = [UIImageView new];
    imgV.frame = self.view.bounds;
    [self.view addSubview:imgV];
    imgV.image = [UIImage imageNamed:@"LaunchImg"];
    [self goNextVC];
}
//不用更新
-(void)goNextVC{
    MainVC * main = [MainVC new];
    [main preferredStatusBarStyle];
    StartViewController * start = [StartViewController new];
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([self isFirstStarThisApp]) {
        delegate.window.rootViewController = start;
    }else{
        delegate.window.rootViewController = main;
    }
}
/**
 是不是第一次进入app
 
 @return 是否是第一次进入app
 */
-(BOOL)isFirstStarThisApp{
    NSString * value = [[NSUserDefaults standardUserDefaults] valueForKey:@"isFirstStarThisApp"];
    
    return ![value boolValue];
}
//程序进入前台

-(void)viewWillAppear:(BOOL)animated{
    
}
-(void)viewWillDisappear:(BOOL)animated{
    
}
@end
