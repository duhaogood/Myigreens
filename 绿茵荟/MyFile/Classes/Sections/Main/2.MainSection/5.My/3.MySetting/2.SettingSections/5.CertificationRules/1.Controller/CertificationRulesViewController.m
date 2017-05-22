//
//  CertificationRulesViewController.m
//  绿茵荟
//
//  Created by Mac on 17/4/5.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "CertificationRulesViewController.h"

@interface CertificationRulesViewController ()

@end

@implementation CertificationRulesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [MYTOOL RGBWithRed:247 green:247 blue:247 alpha:1];
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backToUpView)];
    //webView
    UIWebView * webView = [UIWebView new];
    webView.frame = CGRectMake(0, 0, WIDTH, HEIGHT-64);
    webView.frame = self.view.bounds;
    NSURL *url = [NSURL URLWithString:@"https://baidu.com"];
    
    // 2. 把URL告诉给服务器,请求,从m.baidu.com请求数据
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    
}


//返回上个界面
-(void)backToUpView{
    [self.navigationController popViewControllerAnimated:true];
}
#pragma mark - view隐藏和显示
-(void)viewWillAppear:(BOOL)animated{
    [MYTOOL hiddenTabBar];
}
-(void)viewWillDisappear:(BOOL)animated{
    [MYTOOL showTabBar];
}

@end
