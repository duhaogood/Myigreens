//
//  BusinessCooperateViewController.m
//  绿茵荟
//
//  Created by Mac on 17/4/5.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "BusinessCooperateViewController.h"

@interface BusinessCooperateViewController ()
@property(nonatomic,strong)UIWebView * webView;
@end

@implementation BusinessCooperateViewController
{
    NSString * content;//h5地址
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [MYTOOL RGBWithRed:247 green:247 blue:247 alpha:1];
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backToUpView)];
    //webView
    UIWebView * webView = [UIWebView new];
    webView.frame = CGRectMake(0, 0, WIDTH, HEIGHT-64);
    webView.frame = self.view.bounds;
    self.webView = webView;
    [self.view addSubview:webView];
    
}

//获取html
-(void)getHtml{
    NSString * interfaceName = @"/sys/getSysInfoBykey.intf";
    NSString * infoKey = @"business_cooperation";
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:@{@"infoKey":infoKey} andSuccess:^(NSDictionary *back_dic) {
        content = back_dic[@"info"][@"content"];
        [self.webView loadHTMLString:content baseURL:nil];
    }];
    
}
//返回上个界面
-(void)backToUpView{
    [self.navigationController popViewControllerAnimated:true];
}
#pragma mark - view隐藏和显示
-(void)viewWillAppear:(BOOL)animated{
    [MYTOOL hiddenTabBar];
    [self getHtml];
}
-(void)viewWillDisappear:(BOOL)animated{
    [MYTOOL showTabBar];
}

@end
