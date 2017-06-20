//
//  ScoreRuleViewController.m
//  绿茵荟
//
//  Created by Mac on 17/4/5.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "ScoreRuleViewController.h"

@interface ScoreRuleViewController ()
@property(nonatomic,copy)NSString * url_string;
@property(nonatomic,strong)UIWebView * webView;
@end

@implementation ScoreRuleViewController

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
    NSString * infoKey = @"integral_rule";
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:@{@"infoKey":infoKey} andSuccess:^(NSDictionary *back_dic) {
        NSString * content = back_dic[@"info"][@"url"];
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:content]];
        [self.webView loadRequest:request];
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
